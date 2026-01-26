---
story_id: 02
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Create Server Status API
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 02: Create Server Status API

## User Story

**As an** authenticated admin,
**I want** an API endpoint that returns the EC2 instance status,
**so that** the dashboard can display the current server state.

## Acceptance Criteria

### Scenario 1: Returns running instance status
**Given** the EC2 instance is running
**When** I call `GET /api/admin/server/status`
**Then** response includes `state: "running"`
**And** response includes the public IP address
**And** response includes the launch time
**And** response includes calculated uptime

### Scenario 2: Returns stopped instance status
**Given** the EC2 instance is stopped
**When** I call `GET /api/admin/server/status`
**Then** response includes `state: "stopped"`
**And** `publicIp` is null or undefined
**And** `uptime` is null or 0

### Scenario 3: Returns transitioning states
**Given** the EC2 instance is starting or stopping
**When** I call `GET /api/admin/server/status`
**Then** response includes `state: "starting"` or `state: "stopping"`

### Scenario 4: Protected by authentication
**Given** a user is NOT authenticated
**When** they call `GET /api/admin/server/status`
**Then** response is 401 Unauthorized

### Scenario 5: Handles AWS errors
**Given** AWS API returns an error
**When** I call the status endpoint
**Then** response includes appropriate error message
**And** response status is 500 or 503

### Scenario 6: Response time is acceptable
**Given** the API is called
**When** AWS responds
**Then** total response time is < 2 seconds

## Business Value

**Why this matters:** Server status is the core information displayed on the dashboard. This API provides the data needed to show whether the server is running, its IP, and how long it's been up.

**Impact:** Enables real-time visibility into server state.

**Success metric:** Accurate status returned in < 2 seconds.

## Technical Considerations

**API Route:**
```typescript
// src/pages/api/admin/server/status.ts
import type { APIRoute } from "astro"
import { DescribeInstancesCommand } from "@aws-sdk/client-ec2"
import { ec2Client } from "../../../lib/aws"

export const GET: APIRoute = async ({ request }) => {
  const instanceId = import.meta.env.EC2_INSTANCE_ID

  try {
    const command = new DescribeInstancesCommand({
      InstanceIds: [instanceId],
    })
    const response = await ec2Client.send(command)
    const instance = response.Reservations?.[0]?.Instances?.[0]

    if (!instance) {
      return new Response(JSON.stringify({ error: "Instance not found" }), {
        status: 404,
      })
    }

    const launchTime = instance.LaunchTime
    const uptime = launchTime
      ? Math.floor((Date.now() - launchTime.getTime()) / 1000)
      : null

    return new Response(JSON.stringify({
      state: instance.State?.Name,
      publicIp: instance.PublicIpAddress,
      instanceId: instance.InstanceId,
      launchTime: launchTime?.toISOString(),
      uptimeSeconds: uptime,
    }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: "Failed to get status" }), {
      status: 500,
    })
  }
}
```

**Response Shape:**
```typescript
interface ServerStatus {
  state: "running" | "stopped" | "starting" | "stopping" | "pending"
  publicIp: string | null
  instanceId: string
  launchTime: string | null
  uptimeSeconds: number | null
}
```

## Dependencies

**Depends on stories:**
- Story 01: AWS SDK Setup
- Epic 1: Auth Middleware

**Enables stories:**
- Story 03: mcstatus.io Integration
- Story 06: ServerStatusCard Component

## Out of Scope

- Minecraft server status (Story 03)
- Caching (can add later if needed)
- Historical status data

## Notes

- Auth middleware handles authentication check
- Uptime is calculated from EC2 LaunchTime, not Minecraft start
- Consider adding caching to reduce AWS API calls (10-second cache)

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 01 (AWS SDK), Story 03 (mcstatus)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-02.md`
