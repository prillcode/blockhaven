---
story_id: 02
epic_id: BG-WEB-002-05
identifier: BG-WEB-002
title: Create RCON API Endpoint
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-05-quick-actions.md
created: 2026-01-25
---

# Story 02: Create RCON API Endpoint

## User Story

**As an** authenticated admin,
**I want** an API endpoint to execute RCON commands,
**so that** I can manage the Minecraft server from the dashboard.

## Acceptance Criteria

### Scenario 1: Executes valid command
**Given** the server is running
**And** I'm authenticated
**When** I call `POST /api/admin/rcon` with `{ command: "whitelist list" }`
**Then** response includes command output
**And** response includes `success: true`

### Scenario 2: Executes command with arguments
**Given** the server is running
**When** I call with `{ command: "whitelist add", args: "PlayerName" }`
**Then** the player is added to whitelist
**And** response includes confirmation message

### Scenario 3: Rejects disallowed commands
**Given** I call with `{ command: "stop" }`
**When** the API processes the request
**Then** response is 400 Bad Request
**And** error message indicates command not allowed

### Scenario 4: Validates arguments
**Given** I call with `{ command: "whitelist add", args: "Player;rm -rf /" }`
**When** the API validates the request
**Then** response is 400 Bad Request
**And** error message indicates invalid characters

### Scenario 5: Protected by authentication
**Given** a user is NOT authenticated
**When** they call `POST /api/admin/rcon`
**Then** response is 401 Unauthorized

### Scenario 6: Checks server state
**Given** the server is stopped
**When** I call the RCON endpoint
**Then** response is 400 Bad Request
**And** error message indicates server must be running

### Scenario 7: Rate limited
**Given** I've made 10 RCON requests in the last minute
**When** I make another request
**Then** response is 429 Too Many Requests
**And** error indicates rate limit exceeded

### Scenario 8: Logs the command
**Given** I execute a valid command
**When** the command completes
**Then** the action is logged with user, command, and timestamp

## Business Value

**Why this matters:** RCON commands enable whitelist management and server operations without SSH access.

**Impact:** Admins can manage players and server from any device.

**Success metric:** Commands execute successfully with < 5 second response time.

## Technical Considerations

**API Route:**
```typescript
// src/pages/api/admin/rcon.ts
import type { APIRoute } from "astro"
import { executeRconCommand, ALLOWED_COMMANDS } from "../../../lib/rcon"
import { getSession } from "auth-astro/server"

const COMMAND_VALIDATIONS: Record<string, RegExp> = {
  "whitelist add": /^[a-zA-Z0-9_]{3,16}$/,
  "whitelist remove": /^[a-zA-Z0-9_]{3,16}$/,
  say: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/,
}

export const POST: APIRoute = async ({ request }) => {
  const session = await getSession(request)

  // Parse body
  const body = await request.json()
  const { command, args } = body

  // Validate command is allowed
  if (!ALLOWED_COMMANDS.includes(command)) {
    return new Response(JSON.stringify({
      success: false,
      error: `Command not allowed. Allowed: ${ALLOWED_COMMANDS.join(", ")}`,
    }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  // Validate arguments if command requires them
  const validation = COMMAND_VALIDATIONS[command]
  if (validation && args && !validation.test(args)) {
    return new Response(JSON.stringify({
      success: false,
      error: "Invalid argument format",
    }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  try {
    const output = await executeRconCommand(command, args)

    // Log the action
    console.log(`[AUDIT] RCON: ${command} ${args || ""} by ${session?.user?.name} at ${new Date().toISOString()}`)

    return new Response(JSON.stringify({
      success: true,
      output,
    }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("RCON error:", error)
    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : "Command failed",
    }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
}
```

**Response Shape:**
```typescript
interface RconResponse {
  success: boolean
  output?: string
  error?: string
}
```

**Rate Limiting:**
- 10 commands per minute per user
- Tracked in Cloudflare KV
- Returns 429 when exceeded

## Dependencies

**Depends on stories:**
- Story 01: SSM Integration
- Epic 1: Auth Middleware

**Enables stories:**
- Story 03: QuickActions Component

## Out of Scope

- Custom command input (only predefined commands)
- Command history API
- Batch commands

## Notes

- Auth middleware handles authentication
- Rate limiting will be fully implemented in Epic 6
- Command output may need parsing for user-friendly display
- Consider adding server state check before executing

## Traceability

**Parent epic:** [epic-BG-WEB-002-05-quick-actions.md](../../epics/epic-BG-WEB-002-05-quick-actions.md)

**Related stories:** Story 01 (SSM), Story 03 (Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-05/story-02.md`
