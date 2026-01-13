---
story_id: 002
epic_id: 004
title: Live Server Status Widget
status: ready_for_spec
created: 2026-01-12
---

# Story 002: Live Server Status Widget

## User Story

**As a** potential player visiting the website,
**I want** to see the current server status (online/offline) and player count,
**so that** I can decide if now is a good time to join the server.

## Acceptance Criteria

### Scenario 1: Server is online with players
**Given** the server is online with 15 players out of 100 max
**When** I view the ServerStatus widget
**Then** I see a green "Online" indicator with pulsing animation
**And** I see "15/100 players online" displayed prominently
**And** the data updates automatically every 30 seconds

### Scenario 2: Server is offline
**Given** the server is offline or unreachable
**When** I view the ServerStatus widget
**Then** I see a red "Offline" indicator
**And** I see "Server is currently offline" message
**And** no player count is displayed

### Scenario 3: Loading state
**Given** the server status is being fetched for the first time
**When** I view the ServerStatus widget
**Then** I see a loading skeleton or spinner
**And** no incomplete data is displayed
**And** the loading state lasts no more than 2 seconds

### Scenario 4: Error state
**Given** the API request fails or times out
**When** the error occurs
**Then** I see an error message: "Unable to fetch server status"
**And** a retry happens automatically after 30 seconds
**And** the widget doesn't crash the page

## Business Value

**Why this matters:** Real-time server status is the #1 feature requested by players. It reduces uncertainty and shows transparency, building trust with potential players.

**Impact:** Visitors can see proof of active community before investing time to download Minecraft and join. Reduces "is this server dead?" friction that causes 40%+ bounce rates on static server sites.

**Success metric:** Server status visible on homepage, updates every 30 seconds, shows accurate player counts matching actual server state.

## Technical Considerations

**Potential approaches:**
- React component using the `useServerStatus` hook (Story 01)
- Conditional rendering based on loading/error/success states
- Tailwind CSS for styling with pulsing animation for online indicator
- Display component with no business logic (hook handles data fetching)

**Constraints:**
- Must be responsive (mobile and desktop)
- Must integrate with dark mode theme (from Epic 001)
- Must handle all states: loading, error, success (online/offline)
- Pulsing animation should be subtle, not distracting

**Data requirements:**
- Consumes data from `useServerStatus` hook (Story 01)
- Server IP: 5.161.69.191:25565 (displayed for context)

## Dependencies

**Depends on stories:**
- Story 01: Server Status Polling Hook - provides the data source

**Enables stories:**
- No downstream dependencies (can be completed independently)

## Out of Scope

- Server IP copy button (handled in Story 05)
- Historical player count graphs
- Server performance metrics (TPS, RAM usage)
- Join button that launches Minecraft
- Player list (who is currently online)

## Notes

- This widget will be embedded on the homepage hero section (from Epic 002)
- The pulsing animation should use CSS animations, not JavaScript (performance)
- Consider using React.memo() to prevent unnecessary re-renders when parent components update
- Should gracefully handle missing data fields in API response

## Traceability

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

**Related stories:** Story 01 (useServerStatus hook), Story 05 (CopyIPButton)

---

**Next step:** Run `/spec-story .storyline/stories/epic-004/story-02-live-server-status-widget.md`
