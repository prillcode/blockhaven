---
story_id: 07
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Build ServerControls Component
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 07: Build ServerControls Component

## User Story

**As an** authenticated admin,
**I want** start and stop buttons for the server,
**so that** I can control the server with one click.

## Acceptance Criteria

### Scenario 1: Shows start button when stopped
**Given** the server is stopped
**When** I view the controls
**Then** a "Start Server" button is visible
**And** it's styled as a primary action (green)

### Scenario 2: Shows stop button when running
**Given** the server is running
**When** I view the controls
**Then** a "Stop Server" button is visible
**And** it's styled as a warning action (red)

### Scenario 3: Stop button shows confirmation
**Given** I click the stop button
**When** the confirmation dialog appears
**Then** it warns "Stop server? Players will be disconnected."
**And** has "Cancel" and "Stop" buttons
**And** "Stop" must be clicked to proceed

### Scenario 4: Loading state during action
**Given** I click start or stop
**When** the API call is in progress
**Then** the button shows a loading spinner
**And** the button is disabled
**And** other controls are disabled

### Scenario 5: Success feedback
**Given** the action completes successfully
**When** the API responds
**Then** a success toast/message is shown
**And** status begins updating via polling

### Scenario 6: Error feedback
**Given** the action fails
**When** the API responds with error
**Then** an error toast/message is shown
**And** the error message is actionable

### Scenario 7: Disabled during transitioning
**Given** the server is "starting" or "stopping"
**When** I view the controls
**Then** both buttons are disabled
**And** a message indicates the transition

### Scenario 8: Mobile-friendly buttons
**Given** I'm on a mobile device
**When** I view the controls
**Then** buttons are large and touch-friendly (min 44x44px)
**And** confirmation dialog works on touch

## Business Value

**Why this matters:** These are the primary actions of the dashboard. One-click control enables management from any device without technical knowledge.

**Impact:** Admins can manage server state in seconds instead of navigating AWS Console.

**Success metric:** Actions complete within 3 seconds; no accidental stops.

## Technical Considerations

**Component Structure:**
```tsx
// src/components/admin/ServerControls.tsx
interface ServerControlsProps {
  serverState: string | null
  onStart: () => Promise<void>
  onStop: () => Promise<void>
  loading: boolean
}

export function ServerControls({ serverState, onStart, onStop, loading }: ServerControlsProps) {
  const [showConfirm, setShowConfirm] = useState(false)
  const [actionLoading, setActionLoading] = useState(false)

  const isTransitioning = serverState === "starting" || serverState === "stopping"
  const isRunning = serverState === "running"
  const isStopped = serverState === "stopped"

  const handleStart = async () => {
    setActionLoading(true)
    try {
      await onStart()
      toast.success("Server is starting...")
    } catch (error) {
      toast.error("Failed to start server")
    } finally {
      setActionLoading(false)
    }
  }

  const handleStop = async () => {
    setShowConfirm(false)
    setActionLoading(true)
    try {
      await onStop()
      toast.success("Server is stopping...")
    } catch (error) {
      toast.error("Failed to stop server")
    } finally {
      setActionLoading(false)
    }
  }

  return (
    <div className="flex gap-4">
      {isStopped && (
        <Button
          onClick={handleStart}
          disabled={actionLoading || loading}
          variant="success"
          size="lg"
        >
          {actionLoading ? <Spinner /> : "Start Server"}
        </Button>
      )}

      {isRunning && (
        <Button
          onClick={() => setShowConfirm(true)}
          disabled={actionLoading || loading}
          variant="danger"
          size="lg"
        >
          Stop Server
        </Button>
      )}

      {isTransitioning && (
        <div className="text-yellow-400">
          Server is {serverState}...
        </div>
      )}

      <ConfirmDialog
        open={showConfirm}
        onClose={() => setShowConfirm(false)}
        onConfirm={handleStop}
        title="Stop Server?"
        message="Players will be disconnected. The world will be saved before shutdown."
        confirmText="Stop Server"
        confirmVariant="danger"
      />
    </div>
  )
}
```

**Confirmation Dialog:**
- Modal overlay
- Clear warning message
- Cancel and Confirm buttons
- Confirm styled as danger action

## Dependencies

**Depends on stories:**
- Story 04: Start Server API
- Story 05: Stop Server API
- Story 06: ServerStatusCard (shared state)

**Enables stories:**
- Story 08: Auto-Refresh

## Out of Scope

- Keyboard shortcuts
- Scheduled start/stop
- Multiple server support

## Notes

- Confirmation dialog prevents accidental stops
- Loading state provides feedback during API call
- Toast notifications give success/error feedback
- Consider optimistic UI updates for responsiveness

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 04-05 (APIs), Story 06 (StatusCard)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-07.md`
