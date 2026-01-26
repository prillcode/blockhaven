---
story_id: 05
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Create Stop Server API
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 05: Create Stop Server API

## User Story

**As an** authenticated admin,
**I want** an API endpoint to stop the EC2 instance,
**so that** I can turn off the Minecraft server to save costs.

## Acceptance Criteria

### Scenario 1: Successfully stops running instance
**Given** the EC2 instance is running
**When** I call `POST /api/admin/server/stop`
**Then** the EC2 StopInstances API is called
**And** response includes `success: true`
**And** response includes a success message

### Scenario 2: Returns appropriate message if already stopped
**Given** the EC2 instance is already stopped
**When** I call `POST /api/admin/server/stop`
**Then** response includes `success: true`
**And** message indicates instance is already stopped

### Scenario 3: Protected by authentication
**Given** a user is NOT authenticated
**When** they call `POST /api/admin/server/stop`
**Then** response is 401 Unauthorized

### Scenario 4: Handles AWS errors
**Given** AWS API returns an error
**When** I call the stop endpoint
**Then** response includes error message
**And** response status is 500

### Scenario 5: Logs the action
**Given** an authenticated admin stops the server
**When** the action completes
**Then** the action is logged with timestamp and username
**And** log is stored for audit purposes

### Scenario 6: Uses graceful shutdown
**Given** the server is running with players online
**When** I call stop
**Then** the API uses standard StopInstances (not force)
**And** allows graceful Docker container shutdown

## Business Value

**Why this matters:** Stopping the server when not in use saves significant AWS costs. One-click stop makes this easy to do from any device.

**Impact:** Reduces monthly EC2 costs by enabling easy shutdown.

**Success metric:** Server stops within 3 seconds of button click (API response; actual shutdown takes longer).

## Technical Considerations

**API Route:**
```typescript
// src/pages/api/admin/server/stop.ts
import type { APIRoute } from "astro"
import { StopInstancesCommand } from "@aws-sdk/client-ec2"
import { ec2Client } from "../../../lib/aws"
import { getSession } from "auth-astro/server"

export const POST: APIRoute = async ({ request }) => {
  const session = await getSession(request)
  const instanceId = import.meta.env.EC2_INSTANCE_ID

  try {
    const command = new StopInstancesCommand({
      InstanceIds: [instanceId],
      // Force: false (default) - allows graceful shutdown
    })
    const response = await ec2Client.send(command)
    const state = response.StoppingInstances?.[0]?.CurrentState?.Name

    // Log the action
    console.log(`[AUDIT] Server stopped by ${session?.user?.name} at ${new Date().toISOString()}`)

    return new Response(JSON.stringify({
      success: true,
      message: state === "stopped"
        ? "Server is already stopped"
        : "Server is stopping",
      currentState: state,
    }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("Failed to stop server:", error)
    return new Response(JSON.stringify({
      success: false,
      error: "Failed to stop server",
    }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
}
```

**Response Shape:**
```typescript
interface StopResponse {
  success: boolean
  message: string
  currentState?: string
  error?: string
}
```

**AWS State Transitions:**
- running → stopping → stopped
- Graceful shutdown allows Docker to save Minecraft world

## Dependencies

**Depends on stories:**
- Story 01: AWS SDK Setup
- Epic 1: Auth Middleware

**Enables stories:**
- Story 07: ServerControls Component

## Out of Scope

- Force stop option (use graceful always)
- Warning players before stop (UI responsibility)
- Waiting for instance to fully stop (use polling)

## Notes

- StopInstances is idempotent - calling on stopped instance is safe
- EC2 stop takes 30-60 seconds; API returns immediately
- Graceful shutdown (Force: false) allows Minecraft to save
- Dashboard should show confirmation dialog before calling this API
- Audit logging will be enhanced in Epic 6

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 04 (Start API), Story 07 (Controls Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-05.md`
