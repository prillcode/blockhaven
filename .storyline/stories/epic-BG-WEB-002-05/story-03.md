---
story_id: 03
epic_id: BG-WEB-002-05
identifier: BG-WEB-002
title: Build QuickActions Component
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-05-quick-actions.md
created: 2026-01-25
---

# Story 03: Build QuickActions Component

## User Story

**As an** authenticated admin,
**I want** a panel with quick action buttons for common server commands,
**so that** I can manage players and server operations with a few clicks.

## Acceptance Criteria

### Scenario 1: Command selector
**Given** the quick actions panel is displayed
**When** I view the command dropdown
**Then** I see options for all allowed commands
**And** each option has a description

### Scenario 2: Argument input
**Given** I select "Whitelist Add"
**When** the command requires an argument
**Then** an input field appears
**And** placeholder indicates expected input (e.g., "Username")

### Scenario 3: Execute button
**Given** I've selected a command and entered arguments
**When** I click "Execute"
**Then** loading state shows during execution
**And** button is disabled during execution

### Scenario 4: Output display
**Given** a command completes
**When** output is returned
**Then** output displays in a monospace box
**And** previous output is replaced

### Scenario 5: Error handling
**Given** a command fails
**When** error is returned
**Then** error message displays in red
**And** I can retry

### Scenario 6: Disabled when offline
**Given** the server is stopped
**When** I view the quick actions panel
**Then** controls are disabled
**And** message indicates "Server must be running"

### Scenario 7: Input validation
**Given** I enter an invalid username
**When** I try to execute
**Then** validation error shows immediately
**And** API is not called

### Scenario 8: Mobile responsive
**Given** I'm on a mobile device
**When** I view the quick actions panel
**Then** controls are touch-friendly
**And** layout adapts to narrow screens

## Business Value

**Why this matters:** Quick actions provide a user-friendly interface for common server operations, eliminating the need for command-line knowledge.

**Impact:** Any authorized admin can manage the whitelist and server.

**Success metric:** Commands can be executed in under 5 clicks.

## Technical Considerations

**Component Structure:**
```tsx
// src/components/admin/QuickActions.tsx
interface QuickActionsProps {
  serverState: string | null
}

interface Command {
  id: string
  name: string
  command: string
  description: string
  requiresArg: boolean
  argPlaceholder?: string
  argValidation?: RegExp
}

const COMMANDS: Command[] = [
  {
    id: "whitelist-add",
    name: "Whitelist Add",
    command: "whitelist add",
    description: "Add a player to the whitelist",
    requiresArg: true,
    argPlaceholder: "Minecraft username",
    argValidation: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: "whitelist-remove",
    name: "Whitelist Remove",
    command: "whitelist remove",
    description: "Remove a player from the whitelist",
    requiresArg: true,
    argPlaceholder: "Minecraft username",
    argValidation: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: "whitelist-list",
    name: "View Whitelist",
    command: "whitelist list",
    description: "Show all whitelisted players",
    requiresArg: false,
  },
  {
    id: "list",
    name: "Online Players",
    command: "list",
    description: "Show currently online players",
    requiresArg: false,
  },
  {
    id: "save-all",
    name: "Save World",
    command: "save-all",
    description: "Force save all worlds",
    requiresArg: false,
  },
  {
    id: "say",
    name: "Broadcast Message",
    command: "say",
    description: "Send a message to all players",
    requiresArg: true,
    argPlaceholder: "Message to broadcast",
    argValidation: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/,
  },
]

export function QuickActions({ serverState }: QuickActionsProps) {
  const [selectedCommand, setSelectedCommand] = useState<Command | null>(null)
  const [args, setArgs] = useState("")
  const [output, setOutput] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const isServerRunning = serverState === "running"
  const canExecute = isServerRunning && selectedCommand &&
    (!selectedCommand.requiresArg || (args && selectedCommand.argValidation?.test(args)))

  const handleExecute = async () => {
    if (!selectedCommand || !canExecute) return

    setLoading(true)
    setError(null)
    setOutput(null)

    try {
      const res = await fetch("/api/admin/rcon", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          command: selectedCommand.command,
          args: selectedCommand.requiresArg ? args : undefined,
        }),
      })
      const data = await res.json()

      if (data.success) {
        setOutput(data.output)
        setArgs("")
      } else {
        setError(data.error)
      }
    } catch (err) {
      setError("Failed to execute command")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="bg-secondary-darkGray rounded-lg p-6">
      <h2>Quick Actions</h2>

      {!isServerRunning && (
        <div className="text-yellow-400 mb-4">
          Server must be running to execute commands
        </div>
      )}

      <div className="space-y-4">
        <select
          value={selectedCommand?.id || ""}
          onChange={e => {
            setSelectedCommand(COMMANDS.find(c => c.id === e.target.value) || null)
            setArgs("")
          }}
          disabled={!isServerRunning}
        >
          <option value="">Select command...</option>
          {COMMANDS.map(cmd => (
            <option key={cmd.id} value={cmd.id}>
              {cmd.name}
            </option>
          ))}
        </select>

        {selectedCommand?.description && (
          <p className="text-sm text-gray-400">{selectedCommand.description}</p>
        )}

        {selectedCommand?.requiresArg && (
          <input
            type="text"
            placeholder={selectedCommand.argPlaceholder}
            value={args}
            onChange={e => setArgs(e.target.value)}
            disabled={!isServerRunning || loading}
          />
        )}

        <button
          onClick={handleExecute}
          disabled={!canExecute || loading}
          className="w-full"
        >
          {loading ? "Executing..." : "Execute"}
        </button>
      </div>

      {output && (
        <div className="mt-4 p-3 bg-gray-900 rounded font-mono text-sm text-green-400">
          {output}
        </div>
      )}

      {error && (
        <div className="mt-4 p-3 bg-red-900/30 rounded text-red-400">
          {error}
        </div>
      )}
    </div>
  )
}
```

## Dependencies

**Depends on stories:**
- Story 02: RCON API Endpoint
- Epic 2: Server Status (serverState prop)

**Enables stories:** None (completes Epic 5)

## Out of Scope

- Command history
- Favorite commands
- Keyboard shortcuts
- Custom command builder

## Notes

- Input validation happens client-side for immediate feedback
- Server-side validation is the source of truth
- Output area shows command results in monospace
- Consider adding a "clear output" button

## Traceability

**Parent epic:** [epic-BG-WEB-002-05-quick-actions.md](../../epics/epic-BG-WEB-002-05-quick-actions.md)

**Related stories:** Story 01-02 (Backend)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-05/story-03.md`
