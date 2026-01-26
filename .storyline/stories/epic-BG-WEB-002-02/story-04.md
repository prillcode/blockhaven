---
story_id: 04
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Create Start Server API
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 04: Create Start Server API

## User Story

**As an** authenticated admin,
**I want** an API endpoint to start the EC2 instance,
**so that** I can turn on the Minecraft server with one click.

## Acceptance Criteria

### Scenario 1: Successfully starts stopped instance
**Given** the EC2 instance is stopped
**When** I call `POST /api/admin/server/start`
**Then** the EC2 StartInstances API is called
**And** response includes `success: true`
**And** response includes a success message

### Scenario 2: Returns appropriate message if already running
**Given** the EC2 instance is already running
**When** I call `POST /api/admin/server/start`
**Then** response includes `success: true`
**And** message indicates instance is already running

### Scenario 3: Protected by authentication
**Given** a user is NOT authenticated
**When** they call `POST /api/admin/server/start`
**Then** response is 401 Unauthorized

### Scenario 4: Handles AWS errors
**Given** AWS API returns an error
**When** I call the start endpoint
**Then** response includes error message
**And** response status is 500

### Scenario 5: Logs the action
**Given** an authenticated admin starts the server
**When** the action completes
**Then** the action is logged with timestamp and username
**And** log is stored for audit purposes

### Scenario 6: Response time is acceptable
**Given** the API is called
**When** AWS responds
**Then** total response time is < 3 seconds

## Business Value

**Why this matters:** One-click server start eliminates the need for AWS Console or CLI access, enabling management from any device including mobile.

**Impact:** Server can be started in seconds instead of navigating AWS Console.

**Success metric:** Server starts within 3 seconds of button click.

## Technical Considerations

**API Route:**
```typescript
// src/pages/api/admin/server/start.ts
import type { APIRoute } from "astro"
import { StartInstancesCommand } from "@aws-sdk/client-ec2"
import { ec2Client } from "../../../lib/aws"
import { getSession } from "auth-astro/server"

export const POST: APIRoute = async ({ request }) => {
  const session = await getSession(request)
  const instanceId = import.meta.env.EC2_INSTANCE_ID

  try {
    const command = new StartInstancesCommand({
      InstanceIds: [instanceId],
    })
    const response = await ec2Client.send(command)
    const state = response.StartingInstances?.[0]?.CurrentState?.Name

    // Log the action
    console.log(`[AUDIT] Server started by ${session?.user?.name} at ${new Date().toISOString()}`)

    return new Response(JSON.stringify({
      success: true,
      message: state === "running"
        ? "Server is already running"
        : "Server is starting",
      currentState: state,
    }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("Failed to start server:", error)
    return new Response(JSON.stringify({
      success: false,
      error: "Failed to start server",
    }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
}
```

**Response Shape:**
```typescript
interface StartResponse {
  success: boolean
  message: string
  currentState?: string
  error?: string
}
```

**AWS State Transitions:**
- stopped → pending → running
- API returns quickly, instance takes 30-60 seconds to fully start

## Dependencies

**Depends on stories:**
- Story 01: AWS SDK Setup
- Epic 1: Auth Middleware

**Enables stories:**
- Story 07: ServerControls Component

## Out of Scope

- Waiting for instance to fully start (use polling)
- Starting Minecraft within the instance (automatic via Docker)
- Scheduled starts

## Notes

- StartInstances is idempotent - calling on running instance is safe
- EC2 start takes 30-60 seconds; API returns immediately
- Dashboard should poll status to see state transition
- Audit logging will be enhanced in Epic 6

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 05 (Stop API), Story 07 (Controls Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-04.md`
