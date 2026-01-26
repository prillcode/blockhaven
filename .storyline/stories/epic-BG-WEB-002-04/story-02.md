---
story_id: 02
epic_id: BG-WEB-002-04
identifier: BG-WEB-002
title: Create Logs API Endpoint
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-04-logs-viewer.md
created: 2026-01-25
---

# Story 02: Create Logs API Endpoint

## User Story

**As an** authenticated admin,
**I want** an API endpoint to retrieve server logs,
**so that** I can view Minecraft logs in the dashboard.

## Acceptance Criteria

### Scenario 1: Returns logs when server running
**Given** the EC2 instance is running
**And** CloudWatch has logs available
**When** I call `GET /api/admin/logs?count=100`
**Then** response includes array of log entries
**And** each entry has timestamp, message, and level

### Scenario 2: Accepts count parameter
**Given** I call the logs API
**When** I specify `count=250`
**Then** up to 250 log entries are returned
**And** default count is 100 if not specified

### Scenario 3: Returns empty when server stopped
**Given** the EC2 instance is stopped
**When** I call the logs API
**Then** response includes empty array or informative message
**And** response status is 200 (not an error)

### Scenario 4: Protected by authentication
**Given** a user is NOT authenticated
**When** they call `GET /api/admin/logs`
**Then** response is 401 Unauthorized

### Scenario 5: Handles CloudWatch errors
**Given** CloudWatch is unavailable or unconfigured
**When** I call the logs API
**Then** response includes appropriate error message
**And** response status is 503 Service Unavailable

### Scenario 6: Response time acceptable
**Given** I call the logs API
**When** CloudWatch responds
**Then** total response time is < 3 seconds

## Business Value

**Why this matters:** The logs API provides the data needed to display server logs in the dashboard without SSH access.

**Impact:** Enables troubleshooting and monitoring from the web interface.

**Success metric:** Logs returned in < 3 seconds.

## Technical Considerations

**API Route:**
```typescript
// src/pages/api/admin/logs.ts
import type { APIRoute } from "astro"
import { getServerLogs } from "../../../lib/logs"

const VALID_COUNTS = [100, 250, 500]

export const GET: APIRoute = async ({ request }) => {
  const url = new URL(request.url)
  const countParam = url.searchParams.get("count")
  const count = countParam ? parseInt(countParam, 10) : 100

  // Validate count
  if (!VALID_COUNTS.includes(count)) {
    return new Response(JSON.stringify({
      error: `Invalid count. Must be one of: ${VALID_COUNTS.join(", ")}`,
    }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  try {
    const logs = await getServerLogs(count)

    return new Response(JSON.stringify({
      logs,
      count: logs.length,
      timestamp: new Date().toISOString(),
    }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("Failed to fetch logs:", error)

    // Check if it's a "log group not found" error
    if (error?.name === "ResourceNotFoundException") {
      return new Response(JSON.stringify({
        logs: [],
        message: "CloudWatch logs not configured",
      }), {
        headers: { "Content-Type": "application/json" },
      })
    }

    return new Response(JSON.stringify({
      error: "Failed to fetch logs",
    }), {
      status: 503,
      headers: { "Content-Type": "application/json" },
    })
  }
}
```

**Response Shape:**
```typescript
interface LogsResponse {
  logs: LogEntry[]
  count: number
  timestamp: string
  message?: string
  error?: string
}

interface LogEntry {
  timestamp: string // ISO format
  message: string
  level: "INFO" | "WARN" | "ERROR" | "DEBUG"
}
```

## Dependencies

**Depends on stories:**
- Story 01: CloudWatch Logs Integration
- Epic 1: Auth Middleware

**Enables stories:**
- Story 03: LogsViewer Component

## Out of Scope

- Filtering by log level (client-side)
- Date range queries
- Log search (client-side)
- Pagination/infinite scroll

## Notes

- Auth middleware handles authentication
- Gracefully handle missing CloudWatch setup
- Consider adding caching to reduce CloudWatch API calls
- Log timestamps should be in ISO format for easy parsing

## Traceability

**Parent epic:** [epic-BG-WEB-002-04-logs-viewer.md](../../epics/epic-BG-WEB-002-04-logs-viewer.md)

**Related stories:** Story 01 (CloudWatch), Story 03 (Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-04/story-02.md`
