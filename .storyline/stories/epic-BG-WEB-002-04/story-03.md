---
story_id: 03
epic_id: BG-WEB-002-04
identifier: BG-WEB-002
title: Build LogsViewer Component
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-04-logs-viewer.md
created: 2026-01-25
---

# Story 03: Build LogsViewer Component

## User Story

**As an** authenticated admin,
**I want** to view server logs in a terminal-style display,
**so that** I can troubleshoot issues and monitor server activity.

## Acceptance Criteria

### Scenario 1: Terminal-style display
**Given** logs are loaded
**When** I view the logs viewer
**Then** logs display in monospace font
**And** background is dark (terminal-like)
**And** text is light colored

### Scenario 2: Log level highlighting
**Given** logs are displayed
**When** I look at different log entries
**Then** INFO entries are green/default
**And** WARN entries are yellow/orange
**And** ERROR entries are red
**And** DEBUG entries are gray

### Scenario 3: Timestamp display
**Given** logs are displayed
**When** I look at entries
**Then** each entry shows formatted timestamp
**And** timestamps are in local timezone

### Scenario 4: Line count selector
**Given** the logs viewer is displayed
**When** I change the line count selector
**Then** options include 100, 250, 500
**And** changing reloads logs with new count

### Scenario 5: Refresh button
**Given** the logs viewer is displayed
**When** I click refresh
**Then** latest logs are fetched
**And** loading indicator shows during fetch

### Scenario 6: Search/filter
**Given** logs are displayed
**When** I enter text in the search box
**Then** logs are filtered to matching entries
**And** filtering happens client-side (instant)

### Scenario 7: Auto-scroll toggle
**Given** logs are displayed
**When** I enable auto-scroll
**Then** log container scrolls to bottom
**And** stays at bottom when new logs load

### Scenario 8: Server offline message
**Given** the server is stopped
**When** I view the logs viewer
**Then** message shows "Server is offline"
**And** previous logs may still display

### Scenario 9: Mobile responsiveness
**Given** I'm on a mobile device
**When** I view the logs viewer
**Then** horizontal scroll is available for long lines
**And** controls are touch-friendly
**And** font size is readable

## Business Value

**Why this matters:** A good logs viewer enables troubleshooting without SSH access. Terminal-style display is familiar to admins.

**Impact:** Admins can diagnose issues from any device.

**Success metric:** Logs are readable and filterable with < 3 second load time.

## Technical Considerations

**Component Structure:**
```tsx
// src/components/admin/LogsViewer.tsx
interface LogsViewerProps {
  serverState: string | null
}

export function LogsViewer({ serverState }: LogsViewerProps) {
  const [logs, setLogs] = useState<LogEntry[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [lineCount, setLineCount] = useState(100)
  const [filter, setFilter] = useState("")
  const [autoScroll, setAutoScroll] = useState(true)
  const containerRef = useRef<HTMLDivElement>(null)

  const fetchLogs = async () => {
    setLoading(true)
    try {
      const res = await fetch(`/api/admin/logs?count=${lineCount}`)
      const data = await res.json()
      setLogs(data.logs)
      setError(null)
    } catch (err) {
      setError("Failed to load logs")
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchLogs()
  }, [lineCount])

  useEffect(() => {
    if (autoScroll && containerRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight
    }
  }, [logs, autoScroll])

  const filteredLogs = filter
    ? logs.filter(log => log.message.toLowerCase().includes(filter.toLowerCase()))
    : logs

  const levelColors = {
    INFO: "text-green-400",
    WARN: "text-yellow-400",
    ERROR: "text-red-400",
    DEBUG: "text-gray-500",
  }

  return (
    <div className="bg-gray-900 rounded-lg">
      {/* Controls */}
      <div className="flex flex-wrap gap-2 p-3 border-b border-gray-700">
        <select value={lineCount} onChange={e => setLineCount(+e.target.value)}>
          <option value={100}>100 lines</option>
          <option value={250}>250 lines</option>
          <option value={500}>500 lines</option>
        </select>

        <input
          type="text"
          placeholder="Filter logs..."
          value={filter}
          onChange={e => setFilter(e.target.value)}
          className="flex-1 min-w-[150px]"
        />

        <label className="flex items-center gap-1">
          <input
            type="checkbox"
            checked={autoScroll}
            onChange={e => setAutoScroll(e.target.checked)}
          />
          Auto-scroll
        </label>

        <button onClick={fetchLogs} disabled={loading}>
          {loading ? <Spinner /> : "Refresh"}
        </button>
      </div>

      {/* Logs container */}
      <div
        ref={containerRef}
        className="h-96 overflow-auto p-4 font-mono text-sm"
      >
        {serverState === "stopped" && (
          <div className="text-gray-500">Server is offline</div>
        )}

        {filteredLogs.map((log, i) => (
          <div key={i} className={`${levelColors[log.level]} whitespace-pre`}>
            <span className="text-gray-500">
              {formatTimestamp(log.timestamp)}
            </span>{" "}
            {log.message}
          </div>
        ))}

        {!loading && filteredLogs.length === 0 && serverState !== "stopped" && (
          <div className="text-gray-500">No logs available</div>
        )}
      </div>
    </div>
  )
}
```

**Styling:**
- Dark background (#111827 or similar)
- Monospace font (font-mono)
- Color-coded log levels
- Horizontal scroll for long lines (overflow-x-auto, whitespace-pre)
- Fixed height with vertical scroll

## Dependencies

**Depends on stories:**
- Story 02: Logs API Endpoint
- Epic 2: Server Status (serverState prop)

**Enables stories:** None (completes Epic 4)

## Out of Scope

- Real-time log streaming (WebSocket)
- Log file download
- Date range selection
- Regex search

## Notes

- Client-side filtering is instant and doesn't require API calls
- Auto-scroll improves UX when monitoring live
- Consider virtual scrolling for very long log lists
- Mobile horizontal scroll is intentional for long log lines

## Traceability

**Parent epic:** [epic-BG-WEB-002-04-logs-viewer.md](../../epics/epic-BG-WEB-002-04-logs-viewer.md)

**Related stories:** Story 01-02 (Backend)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-04/story-03.md`
