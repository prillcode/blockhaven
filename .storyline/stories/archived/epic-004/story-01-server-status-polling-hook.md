---
story_id: 001
epic_id: 004
title: Server Status Polling Hook
status: ready_for_spec
created: 2026-01-12
---

# Story 001: Server Status Polling Hook

## User Story

**As a** website visitor,
**I want** the server status to automatically refresh every 30 seconds,
**so that** I always see up-to-date player counts and server availability without manually refreshing the page.

## Acceptance Criteria

### Scenario 1: Initial server status fetch
**Given** I am on any page with the ServerStatus widget
**When** the page loads
**Then** the hook fetches server status from `/api/server-status`
**And** returns the data (online status, player count, max players)

### Scenario 2: Automatic polling
**Given** the initial fetch succeeded
**When** 30 seconds have elapsed
**Then** the hook automatically fetches fresh server status
**And** updates the returned data
**And** continues polling every 30 seconds

### Scenario 3: Error handling
**Given** the API request fails (network error, 500 error)
**When** the error occurs
**Then** the hook returns an error state
**And** retries after the next polling interval
**And** does not crash the application

### Scenario 4: Cleanup on unmount
**Given** the component using the hook unmounts
**When** the unmount occurs
**Then** the polling interval is cleared
**And** any in-flight requests are aborted via AbortController
**And** no memory leaks occur

## Business Value

**Why this matters:** Live server status is a key trust signal for potential players. Showing real-time player counts proves the server is active and builds confidence in joining.

**Impact:** Website visitors can make informed decisions about joining based on current server activity, reducing bounce rate and increasing player conversion.

**Success metric:** Server status updates every 30 seconds without user interaction, matching backend cache TTL.

## Technical Considerations

**Potential approaches:**
- Use `setInterval` with `useEffect` for polling logic
- Implement AbortController to cancel in-flight requests on unmount
- Use `useState` for data, loading, and error states
- Consider `document.visibilityState` API to pause polling when tab is inactive (battery optimization)

**Constraints:**
- Must poll every 30 seconds (matches backend cache TTL from Epic 003)
- Must clean up intervals and abort requests on unmount
- Must handle network errors gracefully
- Must work with React 19's concurrent features

**Data requirements:**
- Backend API endpoint: `/api/server-status` (from Epic 003, Story 02)
- Response shape: `{ online: boolean, playerCount: number, maxPlayers: number, timestamp: string }`

## Dependencies

**Depends on stories:**
- Epic 003, Story 02: Server Status Endpoint - provides the API this hook consumes

**Enables stories:**
- Story 02: Live Server Status Widget - uses this hook to display server data

**No blocking dependencies within this epic**

## Out of Scope

- UI rendering (handled by Story 02: ServerStatus widget)
- Toast notifications for status changes
- Historical player count tracking
- WebSocket real-time updates (polling is sufficient for MVP)
- Manual refresh button (auto-polling is sufficient)

## Notes

- The 30-second polling interval aligns with the backend's 30-second cache TTL (redis caching from Epic 003)
- Consider implementing tab visibility detection to pause polling when tab is inactive (saves battery/bandwidth)
- This hook should be reusable - any component can use it, not just ServerStatus widget
- TypeScript types for hook return value should be exported for reuse

## Traceability

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

**Related stories:** Story 02 (ServerStatus Widget)

---

**Next step:** Run `/spec-story .storyline/stories/epic-004/story-01-server-status-polling-hook.md`
