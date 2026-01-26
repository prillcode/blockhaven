---
story_id: 08
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Implement Auto-Refresh
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 08: Implement Auto-Refresh

## User Story

**As an** authenticated admin,
**I want** the server status to automatically refresh,
**so that** I always see current information without manual refresh.

## Acceptance Criteria

### Scenario 1: Auto-refresh every 30 seconds
**Given** I'm viewing the dashboard
**When** 30 seconds pass
**Then** the status automatically refreshes
**And** the UI updates with new data

### Scenario 2: Manual refresh available
**Given** I'm viewing the dashboard
**When** I click the refresh button
**Then** status refreshes immediately
**And** auto-refresh timer resets

### Scenario 3: Pause during actions
**Given** I click start or stop
**When** the action is in progress
**Then** auto-refresh pauses
**And** resumes after action completes

### Scenario 4: Faster refresh during transitions
**Given** the server is "starting" or "stopping"
**When** auto-refresh runs
**Then** refresh interval decreases to 5 seconds
**And** returns to 30 seconds when stable

### Scenario 5: Pause when tab hidden
**Given** I switch to another browser tab
**When** the tab becomes inactive
**Then** auto-refresh pauses
**And** immediately refreshes when tab becomes visible

### Scenario 6: Shows refresh indicator
**Given** auto-refresh is running
**When** data is being fetched
**Then** a subtle loading indicator shows
**And** UI doesn't flash or jump

### Scenario 7: Shows last updated time
**Given** the status has been fetched
**When** I view the dashboard
**Then** "Last updated: X seconds ago" is displayed
**And** updates in real-time

## Business Value

**Why this matters:** Automatic refresh keeps information current without user action. Admins can trust the displayed state is accurate.

**Impact:** No need to manually refresh to see state changes.

**Success metric:** Status is never more than 30 seconds stale.

## Technical Considerations

**Hook Implementation:**
```tsx
// src/hooks/useServerStatus.ts
export function useServerStatus() {
  const [status, setStatus] = useState<ServerStatus | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null)

  const fetchStatus = useCallback(async () => {
    try {
      setLoading(true)
      const response = await fetch("/api/admin/server/status")
      if (!response.ok) throw new Error("Failed to fetch status")
      const data = await response.json()
      setStatus(data)
      setError(null)
      setLastUpdated(new Date())
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error")
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchStatus()

    // Determine interval based on state
    const interval = ["starting", "stopping"].includes(status?.state || "")
      ? 5000   // 5 seconds during transitions
      : 30000  // 30 seconds normally

    const timer = setInterval(fetchStatus, interval)

    // Pause when tab hidden
    const handleVisibility = () => {
      if (document.visibilityState === "visible") {
        fetchStatus()
      }
    }
    document.addEventListener("visibilitychange", handleVisibility)

    return () => {
      clearInterval(timer)
      document.removeEventListener("visibilitychange", handleVisibility)
    }
  }, [fetchStatus, status?.state])

  return { status, loading, error, lastUpdated, refresh: fetchStatus }
}
```

**Last Updated Display:**
```tsx
function LastUpdated({ date }: { date: Date | null }) {
  const [, forceUpdate] = useState(0)

  useEffect(() => {
    const timer = setInterval(() => forceUpdate(n => n + 1), 1000)
    return () => clearInterval(timer)
  }, [])

  if (!date) return null

  const seconds = Math.floor((Date.now() - date.getTime()) / 1000)
  const text = seconds < 5 ? "Just now" : `${seconds}s ago`

  return <span className="text-sm text-gray-400">Updated {text}</span>
}
```

**Considerations:**
- Use `visibilitychange` API to pause when tab is hidden
- Faster polling during state transitions catches changes quickly
- Reset timer on manual refresh
- Loading indicator should be subtle (don't flash entire card)

## Dependencies

**Depends on stories:**
- Story 02: Server Status API
- Story 06: ServerStatusCard Component
- Story 07: ServerControls Component

**Enables stories:** None (completes Epic 2)

## Out of Scope

- WebSocket real-time updates
- Push notifications
- Configurable refresh interval

## Notes

- 30-second interval balances freshness with API load
- Faster refresh during transitions improves UX
- Page visibility API prevents wasted requests
- Consider exponential backoff on repeated errors

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 02 (API), Story 06-07 (Components)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-08.md`
