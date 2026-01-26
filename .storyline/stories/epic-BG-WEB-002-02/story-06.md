---
story_id: 06
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Build ServerStatusCard Component
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 06: Build ServerStatusCard Component

## User Story

**As an** authenticated admin,
**I want** to see a status card showing server state, IP, players, and uptime,
**so that** I have visibility into the server at a glance.

## Acceptance Criteria

### Scenario 1: Displays running state
**Given** the server is running
**When** I view the status card
**Then** status shows "Running" with green indicator
**And** the public IP address is displayed
**And** uptime is shown in human-readable format

### Scenario 2: Displays stopped state
**Given** the server is stopped
**When** I view the status card
**Then** status shows "Stopped" with red indicator
**And** IP shows "Not available"
**And** uptime shows "-"

### Scenario 3: Displays transitioning states
**Given** the server is starting or stopping
**When** I view the status card
**Then** status shows "Starting" or "Stopping" with yellow indicator
**And** a loading spinner is visible

### Scenario 4: Shows player count
**Given** the server is running and players are online
**When** I view the status card
**Then** player count displays (e.g., "3 / 20 players")
**And** player names are listed if available

### Scenario 5: Shows loading skeleton
**Given** status data is being fetched
**When** I view the status card
**Then** a loading skeleton is displayed
**And** layout matches final state to prevent shift

### Scenario 6: Mobile responsive
**Given** I'm on a mobile device
**When** I view the status card
**Then** the layout adapts to narrow screens
**And** all information is readable

## Business Value

**Why this matters:** The status card is the primary information display. Admins need to quickly see if the server is running and who's online.

**Impact:** Instant visibility into server state without checking AWS Console.

**Success metric:** All server info visible within 2 seconds of page load.

## Technical Considerations

**Component Structure:**
```tsx
// src/components/admin/ServerStatusCard.tsx
interface ServerStatusCardProps {
  status: ServerStatus | null
  loading: boolean
  error: string | null
  onRefresh: () => void
}

export function ServerStatusCard({ status, loading, error, onRefresh }: ServerStatusCardProps) {
  if (loading && !status) {
    return <StatusSkeleton />
  }

  const stateColor = {
    running: "bg-green-500",
    stopped: "bg-red-500",
    starting: "bg-yellow-500",
    stopping: "bg-yellow-500",
  }[status?.state || "stopped"]

  return (
    <div className="bg-secondary-darkGray rounded-lg p-6">
      <div className="flex justify-between items-center mb-4">
        <h2>Server Status</h2>
        <button onClick={onRefresh} disabled={loading}>
          <RefreshIcon className={loading ? "animate-spin" : ""} />
        </button>
      </div>

      <div className="grid gap-4">
        <StatusItem label="State" value={status?.state} indicator={stateColor} />
        <StatusItem label="IP" value={status?.publicIp || "Not available"} />
        <StatusItem label="Uptime" value={formatUptime(status?.uptimeSeconds)} />
        <StatusItem label="Players" value={formatPlayers(status?.minecraft)} />
      </div>

      {status?.minecraft?.players?.list?.length > 0 && (
        <PlayerList players={status.minecraft.players.list} />
      )}

      {error && <ErrorMessage message={error} />}
    </div>
  )
}
```

**Uptime Formatting:**
```typescript
function formatUptime(seconds: number | null): string {
  if (!seconds) return "-"
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  if (hours > 24) {
    const days = Math.floor(hours / 24)
    return `${days}d ${hours % 24}h`
  }
  return `${hours}h ${minutes}m`
}
```

**Styling:**
- Use Tailwind with Minecraft theme colors
- Green for running, red for stopped, yellow for transitioning
- Loading skeleton matches final layout dimensions
- Mobile: stack items vertically

## Dependencies

**Depends on stories:**
- Story 02: Server Status API
- Story 03: mcstatus.io Integration

**Enables stories:**
- Story 08: Auto-Refresh

## Out of Scope

- Start/stop controls (Story 07)
- Cost estimation (Epic 3)
- Historical data or graphs

## Notes

- Component receives data from parent; doesn't fetch directly
- Use React for interactivity or Astro islands
- Loading skeleton prevents layout shift
- Consider showing "Last updated" timestamp

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 02 (Status API), Story 07 (Controls), Story 08 (Auto-Refresh)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-06.md`
