# Epic 2: Server Status & Controls

**Epic ID:** BG-WEB-002-02
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md

---

## Business Goal

Provide real-time visibility into EC2 instance and Minecraft server status with one-click start/stop controls, enabling server management from any device without requiring SSH or AWS Console access.

## User Value

**Who Benefits:** Authorized admins

**How They Benefit:**
- Instant visibility: See if server is running, player count, uptime at a glance
- One-click actions: Start/stop server in < 3 seconds response time
- Mobile management: Control server from phone/tablet
- No technical knowledge needed: No SSH commands or AWS Console navigation
- Cost awareness: Know when server is running and consuming resources

## Success Criteria

- [ ] Server status displays EC2 state (running/stopped/starting/stopping)
- [ ] Minecraft status shows online/offline and player count when running
- [ ] Server IP and instance ID displayed
- [ ] Uptime calculated from EC2 LaunchTime
- [ ] Status auto-refreshes every 30 seconds
- [ ] Manual refresh button available
- [ ] Start button initiates EC2 instance start
- [ ] Stop button shows confirmation dialog before stopping
- [ ] Loading states display during API calls
- [ ] Success/error messages are clear and actionable
- [ ] Response time from button click to status update < 3 seconds

## Scope

### In Scope
- AWS SDK integration (`@aws-sdk/client-ec2`)
- IAM user creation with minimal permissions (documented)
- Server status API route (`GET /api/admin/server/status`)
- Start server API route (`POST /api/admin/server/start`)
- Stop server API route (`POST /api/admin/server/stop`)
- ServerStatusCard component (status, IP, players, uptime)
- ServerControls component (start/stop buttons)
- Auto-refresh mechanism (30 second interval)
- Manual refresh button
- Loading states and spinners
- Success/error toast notifications
- Stop confirmation dialog
- Disabled button states during operations
- mcstatus.io integration for Minecraft status

### Out of Scope
- EC2 instance termination or modification
- Changing instance type
- Security group modifications
- Multiple server support (single instance only)
- Scheduled start/stop
- Cost calculations (Epic 3)
- Server logs (Epic 4)
- RCON commands (Epic 5)

## Technical Notes

**Key Technologies:**
- `@aws-sdk/client-ec2` v3
- mcstatus.io API for Minecraft server status
- Cloudflare Workers for API routes

**AWS SDK Integration:**
```typescript
// src/lib/aws.ts
import { EC2Client, DescribeInstancesCommand, StartInstancesCommand, StopInstancesCommand } from "@aws-sdk/client-ec2"

const ec2Client = new EC2Client({
  region: import.meta.env.AWS_REGION,
  credentials: {
    accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
  },
})

export async function getInstanceStatus(instanceId: string) {
  const command = new DescribeInstancesCommand({
    InstanceIds: [instanceId],
  })
  const response = await ec2Client.send(command)
  const instance = response.Reservations?.[0]?.Instances?.[0]
  return {
    state: instance?.State?.Name, // running, stopped, stopping, starting
    publicIp: instance?.PublicIpAddress,
    launchTime: instance?.LaunchTime,
  }
}

export async function startInstance(instanceId: string) {
  const command = new StartInstancesCommand({ InstanceIds: [instanceId] })
  return ec2Client.send(command)
}

export async function stopInstance(instanceId: string) {
  const command = new StopInstancesCommand({ InstanceIds: [instanceId] })
  return ec2Client.send(command)
}
```

**Minecraft Status Integration:**
```typescript
// src/lib/minecraft.ts
export async function getMinecraftStatus(serverIp: string) {
  const response = await fetch(`https://api.mcstatus.io/v2/status/java/${serverIp}`)
  if (!response.ok) return { online: false, players: { online: 0, max: 0 } }
  return response.json()
}
```

**API Routes:**
```typescript
// GET /api/admin/server/status
// Returns: { ec2State, publicIp, launchTime, uptime, minecraft: { online, players } }

// POST /api/admin/server/start
// Returns: { success: boolean, message: string }

// POST /api/admin/server/stop
// Returns: { success: boolean, message: string }
```

**IAM Policy (Least Privilege):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "arn:aws:ec2:us-east-2:*:instance/i-026059416cf185c9f"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
```

## Dependencies

**Depends On:**
- Epic 1: Authentication (all routes must be protected)
- AWS IAM user with appropriate permissions

**Blocks:**
- Epic 3: Cost Estimation (needs uptime data)
- Epic 4: Server Logs Viewer (needs server status)
- Epic 5: Quick Actions Panel (needs server running check)
- Epic 6: Polish & Security Audit

## Risks & Mitigations

**Risk:** AWS API rate limits
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** 30-second refresh interval well within limits, implement exponential backoff on errors

**Risk:** AWS SDK bundle size in Cloudflare Workers
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Use modular SDK v3 imports, only import needed commands

**Risk:** mcstatus.io API availability
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Graceful fallback to "Minecraft status unavailable" with EC2 status still showing

**Risk:** Instance already in requested state
- **Likelihood:** High
- **Impact:** Low
- **Mitigation:** Return appropriate message, no error (idempotent operation)

**Risk:** Slow EC2 state transitions
- **Likelihood:** High
- **Impact:** Low
- **Mitigation:** Show "Starting..." or "Stopping..." intermediate states, continue polling

## Acceptance Criteria

### AWS SDK Integration
- [ ] `@aws-sdk/client-ec2` installed and configured
- [ ] IAM user created with minimal permissions
- [ ] Credentials stored in environment variables
- [ ] AWS calls work from Cloudflare Workers

### Server Status API (`GET /api/admin/server/status`)
- [ ] Returns EC2 instance state (running, stopped, starting, stopping)
- [ ] Returns public IP address when running
- [ ] Returns launch time and calculated uptime
- [ ] Returns Minecraft server status (online, players) via mcstatus.io
- [ ] Handles EC2 API errors gracefully
- [ ] Handles mcstatus.io API errors gracefully
- [ ] Response time < 2 seconds
- [ ] Protected by auth middleware

### Start Server API (`POST /api/admin/server/start`)
- [ ] Calls AWS `startInstances` API
- [ ] Returns success message when instance starts
- [ ] Returns appropriate message if already running
- [ ] Handles AWS errors with clear messages
- [ ] Protected by auth middleware
- [ ] Logs action with timestamp and user

### Stop Server API (`POST /api/admin/server/stop`)
- [ ] Calls AWS `stopInstances` API
- [ ] Returns success message when instance stops
- [ ] Returns appropriate message if already stopped
- [ ] Handles AWS errors with clear messages
- [ ] Protected by auth middleware
- [ ] Logs action with timestamp and user

### ServerStatusCard Component
- [ ] Displays EC2 state with appropriate styling (green=running, red=stopped, yellow=transitioning)
- [ ] Shows public IP address (or "Not available" when stopped)
- [ ] Shows server domain (play.bhsmp.com)
- [ ] Displays player count when Minecraft is online
- [ ] Shows uptime in human-readable format (e.g., "3 hours, 45 minutes")
- [ ] Shows loading skeleton during data fetch
- [ ] Shows last refresh timestamp
- [ ] Responsive design (works on mobile)

### ServerControls Component
- [ ] Start button visible when server is stopped
- [ ] Stop button visible when server is running
- [ ] Buttons disabled during transitioning states (starting/stopping)
- [ ] Buttons disabled during API call (with spinner)
- [ ] Stop button shows confirmation dialog: "Stop server? Players will be disconnected."
- [ ] Success toast on successful action
- [ ] Error toast on failed action
- [ ] Large, touch-friendly buttons for mobile

### Auto-Refresh Mechanism
- [ ] Status refreshes every 30 seconds automatically
- [ ] Manual refresh button triggers immediate refresh
- [ ] Refresh indicator shows when refreshing
- [ ] Auto-refresh pauses during user interaction (button clicks)
- [ ] Refresh continues after tab becomes visible again

### Error Handling
- [ ] AWS throttling errors: show message, retry with backoff
- [ ] Network errors: show message, allow manual retry
- [ ] Permission errors: show message about IAM configuration
- [ ] mcstatus.io unavailable: show EC2 status, note Minecraft status unavailable

### Environment Variables
```bash
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2
EC2_INSTANCE_ID=i-026059416cf185c9f
MC_SERVER_IP=play.bhsmp.com
```

### Directory Structure Additions
```
/web/src/
├── pages/
│   └── api/
│       └── admin/
│           └── server/
│               ├── status.ts   # GET server status
│               ├── start.ts    # POST start server
│               └── stop.ts     # POST stop server
├── components/
│   └── admin/
│       ├── ServerStatusCard.tsx    # Status display
│       └── ServerControls.tsx      # Start/stop buttons
└── lib/
    ├── aws.ts                      # AWS SDK helpers
    └── minecraft.ts                # mcstatus.io integration
```

### Verification Checklist
- [ ] Dashboard shows server status after login
- [ ] Status shows "running" when EC2 is running
- [ ] Status shows "stopped" when EC2 is stopped
- [ ] Player count displays when Minecraft is online
- [ ] Click Start: button spins, then status updates to "starting", then "running"
- [ ] Click Stop: confirmation dialog, then button spins, then status updates to "stopping", then "stopped"
- [ ] Auto-refresh: status updates every 30 seconds without interaction
- [ ] Manual refresh: clicking refresh button updates status immediately
- [ ] Error state: unplug network, see error message, plug back in, see recovery
- [ ] Mobile: all controls work on touch devices

## Related User Stories

From PRD:
- User Story 2: "As the admin, I want to see the current server status so I know the server state"
- User Story 3: "As the admin, I want to start the EC2 instance with one click"
- User Story 4: "As the admin, I want to stop the EC2 instance with one click"
- User Story 5: "As the admin, I want to see the server IP address"
- User Story 7: "As the admin, I want to see server uptime"
- User Story 10: "As the admin, I want to see who's currently online"
- User Story 11: "As the admin, I want to receive feedback (loading states, success/error messages)"

## Notes

- This is the core functionality of the admin dashboard
- AWS SDK v3 is modular and tree-shakeable for smaller bundle sizes
- mcstatus.io is free and reliable for Minecraft server status
- IAM policy follows principle of least privilege - only one specific instance can be controlled
- Uptime is calculated from EC2 LaunchTime, not Minecraft server start time
- Stop confirmation dialog prevents accidental disconnection of players

---

**Next Epic:** Epic 3 - Cost Estimation
