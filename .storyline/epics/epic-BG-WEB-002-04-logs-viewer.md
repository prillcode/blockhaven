# Epic 4: Server Logs Viewer

**Epic ID:** BG-WEB-002-04
**Status:** Not Started
**Priority:** P1 (Should Have)
**Source:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md

---

## Business Goal

Enable admins to view recent Minecraft server logs directly from the dashboard, eliminating the need for SSH access when troubleshooting issues or monitoring server activity.

## User Value

**Who Benefits:** Authorized admins

**How They Benefit:**
- Quick troubleshooting: View errors and warnings without SSH
- Activity monitoring: See player joins, chat, and events
- Mobile access: Check logs from any device
- Reduced friction: No terminal knowledge required

## Success Criteria

- [ ] Last 100-500 log lines display in dashboard
- [ ] Logs are readable with monospace font and proper formatting
- [ ] Log levels highlighted (INFO=green, WARN=yellow, ERROR=red)
- [ ] Refresh button fetches latest logs
- [ ] Search/filter functionality for finding specific entries
- [ ] "Server offline" message when server is stopped
- [ ] Mobile view is usable (horizontal scroll, readable font)
- [ ] Logs load within 3 seconds

## Scope

### In Scope
- Logs API route (`GET /api/admin/logs`)
- CloudWatch Logs integration (recommended approach)
- LogsViewer component with terminal-style display
- Syntax highlighting for log levels
- Search/filter text input
- Auto-scroll to bottom toggle
- Refresh button
- Line count selector (100/250/500)
- Mobile-responsive horizontal scroll
- Loading and error states

### Out of Scope
- Real-time log streaming (WebSocket)
- Log file downloads
- Log persistence/history beyond CloudWatch retention
- Log analysis or alerting
- Multiple log file support
- Log rotation management

## Technical Notes

**Implementation Approach Options:**

**Option A: CloudWatch Logs (Recommended)**
- EC2 instance sends Docker logs to CloudWatch
- Query CloudWatch Logs API from dashboard
- Pros: No SSH required, serverless, reliable
- Cons: Requires CloudWatch agent setup on EC2

**Option B: SSH + Docker Logs**
- API route SSHs into EC2, runs `docker logs blockhaven-mc --tail 100`
- Pros: Works with existing setup
- Cons: SSH complexity from Cloudflare Workers, security concerns

**Recommended: Option A (CloudWatch Logs)**

**CloudWatch Setup (EC2 side):**
```bash
# Install CloudWatch agent on EC2
sudo yum install amazon-cloudwatch-agent

# Configure to capture Docker container logs
# /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "blockhaven-minecraft",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

**CloudWatch Logs API Integration:**
```typescript
// src/lib/logs.ts
import { CloudWatchLogsClient, GetLogEventsCommand } from "@aws-sdk/client-cloudwatch-logs"

const logsClient = new CloudWatchLogsClient({
  region: import.meta.env.AWS_REGION,
  credentials: {
    accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
  },
})

export async function getServerLogs(lineCount: number = 100): Promise<LogEntry[]> {
  const command = new GetLogEventsCommand({
    logGroupName: 'blockhaven-minecraft',
    logStreamName: import.meta.env.EC2_INSTANCE_ID,
    limit: lineCount,
    startFromHead: false, // Get most recent logs
  })

  const response = await logsClient.send(command)
  return response.events?.map(event => ({
    timestamp: new Date(event.timestamp || 0),
    message: event.message || '',
    level: parseLogLevel(event.message || ''),
  })) || []
}

function parseLogLevel(message: string): 'INFO' | 'WARN' | 'ERROR' | 'DEBUG' {
  if (message.includes('[ERROR]') || message.includes('ERROR')) return 'ERROR'
  if (message.includes('[WARN]') || message.includes('WARN')) return 'WARN'
  if (message.includes('[DEBUG]') || message.includes('DEBUG')) return 'DEBUG'
  return 'INFO'
}
```

**IAM Policy Addition:**
```json
{
  "Effect": "Allow",
  "Action": [
    "logs:GetLogEvents",
    "logs:DescribeLogStreams"
  ],
  "Resource": "arn:aws:logs:us-east-2:*:log-group:blockhaven-minecraft:*"
}
```

**Log Entry Interface:**
```typescript
interface LogEntry {
  timestamp: Date
  message: string
  level: 'INFO' | 'WARN' | 'ERROR' | 'DEBUG'
}
```

## Dependencies

**Depends On:**
- Epic 1: Authentication (protected routes)
- Epic 2: Server Status (know if server is running)
- CloudWatch agent configured on EC2 instance

**Blocks:**
- Epic 6: Polish & Security Audit

## Risks & Mitigations

**Risk:** CloudWatch agent not installed on EC2
- **Likelihood:** High (requires setup)
- **Impact:** High (feature won't work)
- **Mitigation:** Document CloudWatch setup in deployment docs, consider it a prerequisite

**Risk:** CloudWatch Logs API latency
- **Likelihood:** Medium
- **Impact:** Low
- **Mitigation:** Show loading state, cache results briefly

**Risk:** Large log volume causing slow loads
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Default to 100 lines, paginate if needed

**Risk:** Log format parsing issues
- **Likelihood:** Medium
- **Impact:** Low
- **Mitigation:** Graceful fallback to raw text display

## Acceptance Criteria

### Logs API Route (`GET /api/admin/logs`)
- [ ] Accepts `count` query parameter (100, 250, 500)
- [ ] Returns array of log entries with timestamp, message, level
- [ ] Returns empty array if server is stopped
- [ ] Returns error message if CloudWatch unavailable
- [ ] Protected by auth middleware
- [ ] Response time < 3 seconds

### LogsViewer Component
- [ ] Displays logs in monospace font (terminal style)
- [ ] Dark background with light text for readability
- [ ] Each log entry shows timestamp and message
- [ ] Timestamps formatted in local timezone
- [ ] Log levels color-coded:
  - INFO: Green/Default
  - WARN: Yellow/Orange
  - ERROR: Red
  - DEBUG: Gray/Dim
- [ ] Horizontal scroll for long lines (no wrapping breaks readability)
- [ ] Vertical scroll for log history

### Controls
- [ ] Line count selector: 100 / 250 / 500
- [ ] Refresh button with loading indicator
- [ ] Search/filter text input
- [ ] Filter works client-side on loaded logs
- [ ] "Auto-scroll to bottom" toggle
- [ ] Clear search button

### Server State Handling
- [ ] Shows "Server is offline" message when EC2 stopped
- [ ] Shows "No logs available" if log group doesn't exist
- [ ] Shows loading skeleton during initial load
- [ ] Shows error message with retry button on failure

### Mobile Responsiveness
- [ ] Full width on mobile
- [ ] Horizontal scroll gesture works
- [ ] Touch-friendly controls (larger tap targets)
- [ ] Font size readable but not too large
- [ ] Search input full width on mobile

### Environment Variables
```bash
# Existing AWS credentials used
# Additional config for CloudWatch
CLOUDWATCH_LOG_GROUP=blockhaven-minecraft
```

### IAM Policy Update
```json
{
  "Effect": "Allow",
  "Action": [
    "logs:GetLogEvents",
    "logs:DescribeLogStreams"
  ],
  "Resource": "arn:aws:logs:us-east-2:*:log-group:blockhaven-minecraft:*"
}
```

### Directory Structure Additions
```
/web/src/
├── pages/
│   └── api/
│       └── admin/
│           └── logs.ts           # GET server logs
├── components/
│   └── admin/
│       └── LogsViewer.tsx        # Log display component
└── lib/
    └── logs.ts                    # CloudWatch Logs utilities
```

### Verification Checklist
- [ ] Dashboard shows logs section after login
- [ ] Logs display when server is running
- [ ] "Server offline" shows when server is stopped
- [ ] Refresh button fetches new logs
- [ ] Line count selector changes number of logs shown
- [ ] Search filters logs to matching entries
- [ ] Log levels show appropriate colors
- [ ] Horizontal scroll works for long lines
- [ ] Mobile view is usable and readable
- [ ] Error state shows when CloudWatch unavailable

## Related User Stories

From PRD:
- User Story 9: "As the admin, I want to view recent server logs so I can troubleshoot issues"

## Notes

- CloudWatch Logs is the recommended approach for production reliability
- SSH-based log retrieval is more complex and has security implications from serverless environment
- CloudWatch agent setup on EC2 is a one-time prerequisite
- Consider adding CloudWatch setup instructions to EC2 deployment documentation
- Log retention in CloudWatch can be configured (default 30 days)
- Real-time streaming could be added later with WebSockets if needed

---

**Next Epic:** Epic 5 - Quick Actions Panel (RCON)
