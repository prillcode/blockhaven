---
spec_id: 04-05
story_ids: [04, 05]
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Start and Stop Server API Endpoints
status: ready_for_implementation
complexity: simple
parent_stories:
  - ../../stories/epic-BG-WEB-002-02/story-04.md
  - ../../stories/epic-BG-WEB-002-02/story-05.md
created: 2026-01-25
---

# Technical Spec 04-05: Start and Stop Server API Endpoints

## Overview

**User stories:**
- [Story 04: Create Start Server API](../../stories/epic-BG-WEB-002-02/story-04.md)
- [Story 05: Create Stop Server API](../../stories/epic-BG-WEB-002-02/story-05.md)

**Goal:** Create API endpoints to start and stop the EC2 instance. Both endpoints are protected by authentication, log the action for auditing, and return appropriate status messages.

**Approach:** Create two POST endpoints that use AWS SDK StartInstancesCommand and StopInstancesCommand. Handle idempotent cases (starting an already running server) gracefully.

## Technical Design

### API Endpoints

| Endpoint | Method | Action | AWS Command |
|----------|--------|--------|-------------|
| `/api/admin/server/start` | POST | Start EC2 instance | StartInstancesCommand |
| `/api/admin/server/stop` | POST | Stop EC2 instance | StopInstancesCommand |

### Response Structure

```typescript
interface ActionResponse {
  success: boolean;
  message: string;
  currentState?: string;  // "running", "stopped", "pending", etc.
  error?: string;         // Only on failure
}
```

### State Transitions

```
Start Server:
  stopped → pending → running
  (API returns immediately; takes 30-60 seconds to fully start)

Stop Server:
  running → stopping → stopped
  (API returns immediately; takes 30-60 seconds to fully stop)
```

## Implementation Details

### Files to Create

#### 1. Start Server API

**`web/src/pages/api/admin/server/start.ts`**

```typescript
// src/pages/api/admin/server/start.ts
// Start server API endpoint
//
// Starts the EC2 instance. Protected by auth middleware.
// Returns immediately; use status endpoint to poll for state changes.

import type { APIRoute } from "astro";
import { StartInstancesCommand } from "@aws-sdk/client-ec2";
import { getEC2Client, getInstanceId } from "../../../../lib/aws";
import { getSession } from "../../../../lib/auth-helpers";

export const POST: APIRoute = async ({ request }) => {
  const ec2Client = getEC2Client();
  const instanceId = getInstanceId();

  // Get session for audit logging
  const session = await getSession(request);
  const username = session?.user?.githubUsername || session?.user?.name || "unknown";

  try {
    const command = new StartInstancesCommand({
      InstanceIds: [instanceId],
    });

    const response = await ec2Client.send(command);
    const stateChange = response.StartingInstances?.[0];
    const currentState = stateChange?.CurrentState?.Name;
    const previousState = stateChange?.PreviousState?.Name;

    // Log the action
    console.log(
      `[AUDIT] Server START by ${username} at ${new Date().toISOString()} - ` +
      `Previous: ${previousState}, Current: ${currentState}`
    );

    // Determine message based on state
    let message: string;
    if (currentState === "running") {
      message = "Server is already running";
    } else if (currentState === "pending") {
      message = "Server is starting. This may take 30-60 seconds.";
    } else {
      message = `Server state changed to ${currentState}`;
    }

    return new Response(
      JSON.stringify({
        success: true,
        message,
        currentState,
        previousState,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error(`[AUDIT] Server START FAILED by ${username}:`, error);

    return new Response(
      JSON.stringify({
        success: false,
        error: "Failed to start server",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
```

#### 2. Stop Server API

**`web/src/pages/api/admin/server/stop.ts`**

```typescript
// src/pages/api/admin/server/stop.ts
// Stop server API endpoint
//
// Stops the EC2 instance gracefully. Protected by auth middleware.
// Uses graceful shutdown (not force) to allow Minecraft to save world data.

import type { APIRoute } from "astro";
import { StopInstancesCommand } from "@aws-sdk/client-ec2";
import { getEC2Client, getInstanceId } from "../../../../lib/aws";
import { getSession } from "../../../../lib/auth-helpers";

export const POST: APIRoute = async ({ request }) => {
  const ec2Client = getEC2Client();
  const instanceId = getInstanceId();

  // Get session for audit logging
  const session = await getSession(request);
  const username = session?.user?.githubUsername || session?.user?.name || "unknown";

  try {
    const command = new StopInstancesCommand({
      InstanceIds: [instanceId],
      // Force: false (default) - allows graceful shutdown
      // This gives Minecraft time to save the world before the instance stops
    });

    const response = await ec2Client.send(command);
    const stateChange = response.StoppingInstances?.[0];
    const currentState = stateChange?.CurrentState?.Name;
    const previousState = stateChange?.PreviousState?.Name;

    // Log the action
    console.log(
      `[AUDIT] Server STOP by ${username} at ${new Date().toISOString()} - ` +
      `Previous: ${previousState}, Current: ${currentState}`
    );

    // Determine message based on state
    let message: string;
    if (currentState === "stopped") {
      message = "Server is already stopped";
    } else if (currentState === "stopping") {
      message = "Server is stopping. World data is being saved.";
    } else {
      message = `Server state changed to ${currentState}`;
    }

    return new Response(
      JSON.stringify({
        success: true,
        message,
        currentState,
        previousState,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error(`[AUDIT] Server STOP FAILED by ${username}:`, error);

    return new Response(
      JSON.stringify({
        success: false,
        error: "Failed to stop server",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
```

### Directory Structure

```
web/src/pages/api/admin/server/
├── status.ts   # GET - from spec-02-03
├── start.ts    # POST - this spec
└── stop.ts     # POST - this spec
```

## Acceptance Criteria Mapping

### Story 04: Start Server API

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Starts stopped instance | StartInstancesCommand | Test with stopped EC2 |
| Returns success: true | Response includes success flag | Check response |
| Handles already running | Returns "already running" message | Start when running |
| Protected by auth | Middleware protects POST | Test unauthenticated |
| Handles AWS errors | try/catch with 500 response | Test with bad credentials |
| Logs the action | console.log with [AUDIT] | Check logs |
| < 3 second response | API returns before instance starts | Measure time |

### Story 05: Stop Server API

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Stops running instance | StopInstancesCommand | Test with running EC2 |
| Returns success: true | Response includes success flag | Check response |
| Handles already stopped | Returns "already stopped" message | Stop when stopped |
| Uses graceful shutdown | Force: false (default) | Check code |
| Protected by auth | Middleware protects POST | Test unauthenticated |
| Handles AWS errors | try/catch with 500 response | Test with bad credentials |
| Logs the action | console.log with [AUDIT] | Check logs |

## Testing Requirements

### Manual Testing Checklist

**Start Server (stopped → running):**
```bash
curl -X POST http://localhost:4321/api/admin/server/start \
  -H "Cookie: authjs.session-token=..."
```

Expected response:
```json
{
  "success": true,
  "message": "Server is starting. This may take 30-60 seconds.",
  "currentState": "pending",
  "previousState": "stopped"
}
```

**Start Server (already running):**
```json
{
  "success": true,
  "message": "Server is already running",
  "currentState": "running",
  "previousState": "running"
}
```

**Stop Server (running → stopped):**
```bash
curl -X POST http://localhost:4321/api/admin/server/stop \
  -H "Cookie: authjs.session-token=..."
```

Expected response:
```json
{
  "success": true,
  "message": "Server is stopping. World data is being saved.",
  "currentState": "stopping",
  "previousState": "running"
}
```

**Unauthenticated Request:**
```bash
curl -X POST http://localhost:4321/api/admin/server/start
# Expected: 401 Unauthorized
```

**GET Request (wrong method):**
```bash
curl http://localhost:4321/api/admin/server/start
# Expected: 405 Method Not Allowed (only POST defined)
```

### Audit Log Verification

After start/stop actions, check server logs for entries like:
```
[AUDIT] Server START by prillcode at 2026-01-25T15:30:00.000Z - Previous: stopped, Current: pending
[AUDIT] Server STOP by prillcode at 2026-01-25T16:30:00.000Z - Previous: running, Current: stopping
```

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; no TypeScript errors.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Accidental stop while players online | Medium | High | UI will show confirmation dialog |
| Double-click starts/stops | Low | Low | Commands are idempotent |
| AWS rate limiting | Low | Low | Users won't click that fast |
| Data loss on stop | Low | High | Graceful shutdown (Force: false) |

## Security Considerations

- **Protected by middleware:** Only authenticated users can start/stop
- **Audit logging:** All actions logged with username and timestamp
- **No force stop:** Graceful shutdown prevents data loss
- **POST only:** Prevents accidental triggers via GET/prefetch

## Success Verification

After implementation:

- [ ] POST `/api/admin/server/start` starts the instance
- [ ] POST `/api/admin/server/stop` stops the instance
- [ ] Both return `success: true` with state info
- [ ] Both handle already-in-state gracefully
- [ ] Both log actions with `[AUDIT]` prefix
- [ ] Both reject unauthenticated requests (401)
- [ ] Response time < 3 seconds

## Traceability

**Parent stories:**
- [Story 04: Create Start Server API](../../stories/epic-BG-WEB-002-02/story-04.md)
- [Story 05: Create Stop Server API](../../stories/epic-BG-WEB-002-02/story-05.md)

**Parent epic:** [Epic BG-WEB-002-02: Server Controls](../../epics/epic-BG-WEB-002-02-server-controls.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-04-05-start-stop-apis.md`
