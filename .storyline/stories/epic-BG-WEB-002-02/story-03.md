---
story_id: 03
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Integrate mcstatus.io for Minecraft Status
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 03: Integrate mcstatus.io for Minecraft Status

## User Story

**As an** authenticated admin,
**I want** to see the Minecraft server status including player count,
**so that** I know if the game server is online and who's playing.

## Acceptance Criteria

### Scenario 1: Returns Minecraft online status
**Given** the EC2 instance is running
**And** the Minecraft server is online
**When** I call the status API
**Then** response includes `minecraft.online: true`
**And** response includes current player count
**And** response includes max player count

### Scenario 2: Returns player list
**Given** players are online
**When** I call the status API
**Then** response includes list of player names

### Scenario 3: Handles Minecraft offline
**Given** the EC2 instance is running
**But** Minecraft server hasn't started yet
**When** I call the status API
**Then** response includes `minecraft.online: false`
**And** player count is 0

### Scenario 4: Handles EC2 stopped
**Given** the EC2 instance is stopped
**When** I call the status API
**Then** Minecraft check is skipped
**And** `minecraft` is null or indicates unavailable

### Scenario 5: Handles mcstatus.io errors
**Given** mcstatus.io is unavailable
**When** I call the status API
**Then** EC2 status still returns successfully
**And** `minecraft` indicates status unavailable
**And** no error is thrown

## Business Value

**Why this matters:** Knowing the Minecraft server status and player count helps admins decide when to stop the server (save costs) and see who's actively playing.

**Impact:** Provides actionable insight beyond just EC2 running state.

**Success metric:** Accurate player count displayed when server is online.

## Technical Considerations

**mcstatus.io Integration:**
```typescript
// src/lib/minecraft.ts
export interface MinecraftStatus {
  online: boolean
  players: {
    online: number
    max: number
    list: string[]
  }
  version?: string
  motd?: string
}

export async function getMinecraftStatus(serverIp: string): Promise<MinecraftStatus> {
  try {
    const response = await fetch(
      `https://api.mcstatus.io/v2/status/java/${serverIp}`,
      { signal: AbortSignal.timeout(5000) } // 5 second timeout
    )

    if (!response.ok) {
      return { online: false, players: { online: 0, max: 0, list: [] } }
    }

    const data = await response.json()
    return {
      online: data.online,
      players: {
        online: data.players?.online || 0,
        max: data.players?.max || 0,
        list: data.players?.list?.map((p: any) => p.name_clean) || [],
      },
      version: data.version?.name_clean,
      motd: data.motd?.clean,
    }
  } catch {
    return { online: false, players: { online: 0, max: 0, list: [] } }
  }
}
```

**Integrate into Status API:**
```typescript
// In /api/admin/server/status.ts
import { getMinecraftStatus } from "../../../lib/minecraft"

// Only check Minecraft if EC2 is running
let minecraft = null
if (instance.State?.Name === "running" && instance.PublicIpAddress) {
  minecraft = await getMinecraftStatus(import.meta.env.MC_SERVER_IP)
}

return { ...ec2Status, minecraft }
```

**mcstatus.io API Notes:**
- Free API, no authentication required
- Rate limit: 600 requests per 10 minutes
- Returns player list (if server exposes it)
- Supports Java and Bedrock servers

## Dependencies

**Depends on stories:**
- Story 02: Server Status API

**Enables stories:**
- Story 06: ServerStatusCard Component

## Out of Scope

- Direct Minecraft server query (use mcstatus.io)
- Player history tracking
- Server performance metrics

## Notes

- mcstatus.io is free and reliable
- Graceful fallback if API is down - don't break EC2 status
- Consider caching mcstatus response briefly (30 seconds)
- Player list may be empty if server hides it

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 02 (Status API), Story 06 (StatusCard)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-03.md`
