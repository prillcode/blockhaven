---
story_id: 01
epic_id: BG-WEB-002-04
identifier: BG-WEB-002
title: Setup CloudWatch Logs Integration
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-04-logs-viewer.md
created: 2026-01-25
---

# Story 01: Setup CloudWatch Logs Integration

## User Story

**As a** developer,
**I want** to configure AWS SDK for CloudWatch Logs,
**so that** the dashboard can retrieve server logs.

## Acceptance Criteria

### Scenario 1: CloudWatch SDK installed
**Given** the web project exists
**When** I install the CloudWatch SDK
**Then** `@aws-sdk/client-cloudwatch-logs` is added to dependencies
**And** packages install without errors

### Scenario 2: CloudWatch client configured
**Given** the SDK is installed
**When** I create the CloudWatch client helper
**Then** `src/lib/logs.ts` exports a configured CloudWatchLogsClient
**And** it uses existing AWS credentials from environment

### Scenario 3: Log retrieval function implemented
**Given** the client is configured
**When** I call `getServerLogs(count)`
**Then** it queries the `blockhaven-minecraft` log group
**And** returns the most recent `count` log entries

### Scenario 4: Log level parsing
**Given** a log entry is retrieved
**When** it's processed
**Then** log level is parsed from message (INFO, WARN, ERROR, DEBUG)
**And** timestamp is converted to Date object

### Scenario 5: IAM policy documented
**Given** the integration is implemented
**When** I check documentation
**Then** required IAM permissions are documented:
  - `logs:GetLogEvents`
  - `logs:DescribeLogStreams`

## Business Value

**Why this matters:** CloudWatch Logs provides a reliable, serverless way to access Minecraft logs without SSH access.

**Impact:** Enables log viewing in the dashboard.

**Success metric:** Logs can be retrieved from CloudWatch in < 3 seconds.

## Technical Considerations

**SDK Setup:**
```typescript
// src/lib/logs.ts
import {
  CloudWatchLogsClient,
  GetLogEventsCommand,
  DescribeLogStreamsCommand,
} from "@aws-sdk/client-cloudwatch-logs"

const logsClient = new CloudWatchLogsClient({
  region: import.meta.env.AWS_REGION || "us-east-2",
  credentials: {
    accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
  },
})

export interface LogEntry {
  timestamp: Date
  message: string
  level: "INFO" | "WARN" | "ERROR" | "DEBUG"
}

export async function getServerLogs(lineCount: number = 100): Promise<LogEntry[]> {
  const logGroupName = import.meta.env.CLOUDWATCH_LOG_GROUP || "blockhaven-minecraft"

  // Get the latest log stream
  const streamsCommand = new DescribeLogStreamsCommand({
    logGroupName,
    orderBy: "LastEventTime",
    descending: true,
    limit: 1,
  })
  const streamsResponse = await logsClient.send(streamsCommand)
  const latestStream = streamsResponse.logStreams?.[0]?.logStreamName

  if (!latestStream) {
    return []
  }

  // Get log events
  const eventsCommand = new GetLogEventsCommand({
    logGroupName,
    logStreamName: latestStream,
    limit: lineCount,
    startFromHead: false,
  })
  const eventsResponse = await logsClient.send(eventsCommand)

  return (eventsResponse.events || []).map(event => ({
    timestamp: new Date(event.timestamp || 0),
    message: event.message || "",
    level: parseLogLevel(event.message || ""),
  }))
}

function parseLogLevel(message: string): "INFO" | "WARN" | "ERROR" | "DEBUG" {
  const upper = message.toUpperCase()
  if (upper.includes("ERROR") || upper.includes("[ERROR]")) return "ERROR"
  if (upper.includes("WARN") || upper.includes("[WARN]")) return "WARN"
  if (upper.includes("DEBUG") || upper.includes("[DEBUG]")) return "DEBUG"
  return "INFO"
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

**Prerequisites (Server-Side):**
- CloudWatch agent installed on EC2
- Agent configured to send Docker logs to CloudWatch
- Log group `blockhaven-minecraft` exists

## Dependencies

**Depends on stories:**
- Epic 1: Authentication (AWS credentials)

**Enables stories:**
- Story 02: Logs API Endpoint
- Story 03: LogsViewer Component

## Out of Scope

- CloudWatch agent setup on EC2 (documented prerequisite)
- Real-time log streaming
- Log retention configuration

## Notes

- CloudWatch agent setup is a one-time server-side task
- If CloudWatch isn't set up, this feature gracefully degrades
- Consider caching results briefly to reduce API calls
- Log group name should be configurable via env var

## Traceability

**Parent epic:** [epic-BG-WEB-002-04-logs-viewer.md](../../epics/epic-BG-WEB-002-04-logs-viewer.md)

**Related stories:** Story 02 (API), Story 03 (Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-04/story-01.md`
