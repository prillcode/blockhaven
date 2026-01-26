---
spec_id: 01-02-03
story_ids: [01, 02, 03]
epic_id: BG-WEB-002-04
identifier: BG-WEB-002
title: CloudWatch Logs Integration with API and Viewer Component
status: ready_for_implementation
complexity: medium
parent_stories:
  - ../../stories/epic-BG-WEB-002-04/story-01.md
  - ../../stories/epic-BG-WEB-002-04/story-02.md
  - ../../stories/epic-BG-WEB-002-04/story-03.md
created: 2026-01-25
---

# Technical Spec 01-02-03: CloudWatch Logs Integration

## Overview

**User stories:**
- [Story 01: Setup CloudWatch Logs Integration](../../stories/epic-BG-WEB-002-04/story-01.md)
- [Story 02: Create Logs API Endpoint](../../stories/epic-BG-WEB-002-04/story-02.md)
- [Story 03: Build LogsViewer Component](../../stories/epic-BG-WEB-002-04/story-03.md)

**Goal:** Enable viewing Minecraft server logs from the dashboard by integrating with AWS CloudWatch Logs. Create an API endpoint to fetch logs and a terminal-style viewer component with filtering and refresh capabilities.

**Approach:** Install `@aws-sdk/client-cloudwatch-logs`, create helper functions to fetch logs, build an API endpoint at `/api/admin/logs`, and create a React component for displaying logs with color-coded log levels.

## Technical Design

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  Dashboard                                                           │
│  └── LogsViewer Component                                           │
│      ├── Line count selector (100, 250, 500)                        │
│      ├── Filter input (client-side)                                 │
│      ├── Refresh button                                             │
│      └── Terminal-style log display                                 │
└─────────────────────────────────────┬───────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│  GET /api/admin/logs?count=100                                       │
│  └── Fetches from CloudWatch Logs                                   │
└─────────────────────────────────────┬───────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│  AWS CloudWatch Logs                                                 │
│  └── Log Group: blockhaven-minecraft                                │
│      └── Log Stream: latest (by LastEventTime)                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Log Entry Format

```typescript
interface LogEntry {
  timestamp: string;   // ISO 8601
  message: string;     // Raw log line
  level: "INFO" | "WARN" | "ERROR" | "DEBUG";  // Parsed from message
}
```

## Implementation Details

### Files to Create

#### 1. CloudWatch Logs Helper

**`web/src/lib/aws/logs.ts`**

```typescript
// src/lib/aws/logs.ts
// CloudWatch Logs integration for Minecraft server logs

import {
  CloudWatchLogsClient,
  GetLogEventsCommand,
  DescribeLogStreamsCommand,
} from "@aws-sdk/client-cloudwatch-logs";

/**
 * Log entry from CloudWatch
 */
export interface LogEntry {
  timestamp: string;
  message: string;
  level: "INFO" | "WARN" | "ERROR" | "DEBUG";
}

/**
 * Get configured CloudWatch Logs client
 */
function getLogsClient(): CloudWatchLogsClient {
  return new CloudWatchLogsClient({
    region: import.meta.env.AWS_REGION || "us-east-2",
    credentials: {
      accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
    },
  });
}

/**
 * Parse log level from message content
 */
function parseLogLevel(message: string): LogEntry["level"] {
  const upper = message.toUpperCase();
  if (upper.includes("[ERROR]") || upper.includes("ERROR:") || upper.includes(" ERROR ")) {
    return "ERROR";
  }
  if (upper.includes("[WARN]") || upper.includes("WARN:") || upper.includes(" WARN ")) {
    return "WARN";
  }
  if (upper.includes("[DEBUG]") || upper.includes("DEBUG:")) {
    return "DEBUG";
  }
  return "INFO";
}

/**
 * Fetch server logs from CloudWatch
 *
 * @param lineCount - Number of log lines to fetch (default 100)
 * @returns Array of log entries, newest last
 */
export async function getServerLogs(lineCount: number = 100): Promise<LogEntry[]> {
  const logsClient = getLogsClient();
  const logGroupName = import.meta.env.CLOUDWATCH_LOG_GROUP || "blockhaven-minecraft";

  try {
    // Find the latest log stream
    const streamsCommand = new DescribeLogStreamsCommand({
      logGroupName,
      orderBy: "LastEventTime",
      descending: true,
      limit: 1,
    });

    const streamsResponse = await logsClient.send(streamsCommand);
    const latestStream = streamsResponse.logStreams?.[0];

    if (!latestStream?.logStreamName) {
      console.log("[Logs] No log streams found in group:", logGroupName);
      return [];
    }

    // Fetch log events
    const eventsCommand = new GetLogEventsCommand({
      logGroupName,
      logStreamName: latestStream.logStreamName,
      limit: lineCount,
      startFromHead: false,  // Get most recent logs
    });

    const eventsResponse = await logsClient.send(eventsCommand);

    // Transform to LogEntry format
    const logs: LogEntry[] = (eventsResponse.events || []).map((event) => ({
      timestamp: event.timestamp
        ? new Date(event.timestamp).toISOString()
        : new Date().toISOString(),
      message: event.message || "",
      level: parseLogLevel(event.message || ""),
    }));

    // Events come in reverse order (newest first), reverse to show oldest first
    return logs.reverse();
  } catch (error) {
    // Check for common errors
    if ((error as any)?.name === "ResourceNotFoundException") {
      console.log("[Logs] Log group not found:", logGroupName);
      throw new Error("Log group not configured");
    }
    throw error;
  }
}
```

#### 2. Update AWS Module Index

**`web/src/lib/aws/index.ts`**

```typescript
// Add export
export { getServerLogs } from "./logs";
export type { LogEntry } from "./logs";
```

#### 3. Logs API Endpoint

**`web/src/pages/api/admin/logs.ts`**

```typescript
// src/pages/api/admin/logs.ts
// Server logs API endpoint
//
// Returns Minecraft server logs from CloudWatch.
// Protected by auth middleware.

import type { APIRoute } from "astro";
import { getServerLogs } from "../../../lib/aws/logs";

// Valid line counts
const VALID_COUNTS = [100, 250, 500];

export const GET: APIRoute = async ({ request }) => {
  const url = new URL(request.url);
  const countParam = url.searchParams.get("count");
  const count = countParam ? parseInt(countParam, 10) : 100;

  // Validate count
  if (!VALID_COUNTS.includes(count)) {
    return new Response(
      JSON.stringify({
        error: `Invalid count. Must be one of: ${VALID_COUNTS.join(", ")}`,
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      }
    );
  }

  try {
    const logs = await getServerLogs(count);

    return new Response(
      JSON.stringify({
        logs,
        count: logs.length,
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("[Logs API] Error:", error);

    // Handle "not configured" gracefully
    if ((error as Error).message === "Log group not configured") {
      return new Response(
        JSON.stringify({
          logs: [],
          count: 0,
          message: "CloudWatch logs not configured. See setup documentation.",
          timestamp: new Date().toISOString(),
        }),
        {
          status: 200,  // Not an error - just not configured
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    return new Response(
      JSON.stringify({
        error: "Failed to fetch logs",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 503,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
```

#### 4. LogsViewer Component

**`web/src/components/admin/LogsViewer.tsx`**

```tsx
// src/components/admin/LogsViewer.tsx
// Terminal-style log viewer component

import React, { useState, useEffect, useRef } from "react";

interface LogEntry {
  timestamp: string;
  message: string;
  level: "INFO" | "WARN" | "ERROR" | "DEBUG";
}

interface LogsViewerProps {
  serverState: string | null;
}

const LEVEL_COLORS: Record<string, string> = {
  INFO: "text-mc-green",
  WARN: "text-accent-gold",
  ERROR: "text-accent-redstone",
  DEBUG: "text-text-muted",
};

const LINE_COUNTS = [100, 250, 500];

export function LogsViewer({ serverState }: LogsViewerProps) {
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lineCount, setLineCount] = useState(100);
  const [filter, setFilter] = useState("");
  const [autoScroll, setAutoScroll] = useState(true);

  const containerRef = useRef<HTMLDivElement>(null);

  const fetchLogs = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/admin/logs?count=${lineCount}`);
      const data = await response.json();

      if (data.error) {
        setError(data.error);
      } else {
        setLogs(data.logs || []);
      }
    } catch (err) {
      setError("Failed to fetch logs");
    } finally {
      setLoading(false);
    }
  };

  // Fetch logs on mount and when lineCount changes
  useEffect(() => {
    fetchLogs();
  }, [lineCount]);

  // Auto-scroll to bottom
  useEffect(() => {
    if (autoScroll && containerRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight;
    }
  }, [logs, autoScroll]);

  // Filter logs client-side
  const filteredLogs = filter
    ? logs.filter((log) =>
        log.message.toLowerCase().includes(filter.toLowerCase())
      )
    : logs;

  const formatTimestamp = (iso: string) => {
    const date = new Date(iso);
    return date.toLocaleTimeString("en-US", {
      hour12: false,
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  };

  return (
    <div className="bg-gray-900 rounded-lg overflow-hidden">
      {/* Controls */}
      <div className="flex flex-wrap items-center gap-3 p-3 bg-gray-800 border-b border-gray-700">
        {/* Line Count Selector */}
        <select
          value={lineCount}
          onChange={(e) => setLineCount(Number(e.target.value))}
          className="px-3 py-2 bg-gray-700 text-text-light rounded border border-gray-600 text-sm"
        >
          {LINE_COUNTS.map((count) => (
            <option key={count} value={count}>
              {count} lines
            </option>
          ))}
        </select>

        {/* Filter Input */}
        <input
          type="text"
          placeholder="Filter logs..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="flex-1 min-w-[150px] px-3 py-2 bg-gray-700 text-text-light rounded border border-gray-600 text-sm placeholder-text-muted"
        />

        {/* Auto-scroll Toggle */}
        <label className="flex items-center gap-2 text-sm text-text-muted cursor-pointer">
          <input
            type="checkbox"
            checked={autoScroll}
            onChange={(e) => setAutoScroll(e.target.checked)}
            className="rounded"
          />
          Auto-scroll
        </label>

        {/* Refresh Button */}
        <button
          onClick={fetchLogs}
          disabled={loading}
          className="px-4 py-2 bg-secondary-stone/50 hover:bg-secondary-stone/70 text-text-light rounded text-sm transition-colors disabled:opacity-50"
        >
          {loading ? "Loading..." : "Refresh"}
        </button>
      </div>

      {/* Log Container */}
      <div
        ref={containerRef}
        className="h-96 overflow-auto p-4 font-mono text-sm"
      >
        {/* Server Offline Message */}
        {serverState === "stopped" && (
          <div className="text-text-muted mb-4">
            Server is offline. Showing cached logs.
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="text-accent-redstone mb-4">{error}</div>
        )}

        {/* Log Lines */}
        {filteredLogs.length > 0 ? (
          filteredLogs.map((log, index) => (
            <div
              key={index}
              className={`whitespace-pre-wrap break-all ${LEVEL_COLORS[log.level]}`}
            >
              <span className="text-text-muted/70">
                {formatTimestamp(log.timestamp)}
              </span>{" "}
              {log.message}
            </div>
          ))
        ) : (
          !loading &&
          !error && (
            <div className="text-text-muted">No logs available</div>
          )
        )}

        {/* Loading Indicator */}
        {loading && logs.length === 0 && (
          <div className="text-text-muted">Loading logs...</div>
        )}
      </div>

      {/* Footer */}
      <div className="px-4 py-2 bg-gray-800 border-t border-gray-700 text-xs text-text-muted">
        Showing {filteredLogs.length} of {logs.length} logs
        {filter && ` (filtered)`}
      </div>
    </div>
  );
}
```

### Update Dashboard Content

Add LogsViewer to `DashboardContent.tsx`:

```tsx
import { LogsViewer } from "./LogsViewer";

// In the return statement, add after other components:
<div className="lg:col-span-2">
  <LogsViewer serverState={status?.ec2?.state || null} />
</div>
```

### Environment Variables

Add to `.env.example`:

```bash
# CloudWatch Logs (for logs viewer)
# Log group name created by CloudWatch agent on EC2
CLOUDWATCH_LOG_GROUP=blockhaven-minecraft
```

### IAM Policy Addition

Add to existing IAM policy:

```json
{
  "Sid": "BlockHavenCloudWatchLogs",
  "Effect": "Allow",
  "Action": [
    "logs:GetLogEvents",
    "logs:DescribeLogStreams"
  ],
  "Resource": "arn:aws:logs:us-east-2:*:log-group:blockhaven-minecraft:*"
}
```

### Dependencies to Install

```bash
npm install @aws-sdk/client-cloudwatch-logs
```

## Acceptance Criteria Mapping

### Story 01: CloudWatch Setup

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| SDK installed | `@aws-sdk/client-cloudwatch-logs` | Check package.json |
| Client configured | `getLogsClient()` | Import check |
| Log retrieval function | `getServerLogs()` | Function exists |
| Log level parsing | `parseLogLevel()` | Test with log samples |
| IAM permissions documented | JSON policy provided | Check docs |

### Story 02: Logs API

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Returns logs when running | GET `/api/admin/logs` | Test with running EC2 |
| Accepts count param | `?count=100/250/500` | Test each value |
| Returns empty when stopped | Graceful empty response | Test with stopped EC2 |
| Protected by auth | Middleware | Test unauthenticated |
| Handles CloudWatch errors | try/catch with 503 | Test with bad config |
| < 3 second response | CloudWatch is fast | Measure time |

### Story 03: LogsViewer Component

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Terminal-style display | Monospace font, dark bg | Visual check |
| Log level colors | Green/yellow/red/gray | Visual check |
| Line count selector | Dropdown with 100/250/500 | Visual check |
| Filter input | Client-side filtering | Type and verify |
| Refresh button | `fetchLogs()` on click | Click test |
| Auto-scroll toggle | Checkbox + scroll behavior | Toggle and test |
| Mobile responsive | Horizontal scroll for long lines | Test at 320px |
| Server offline message | Shows when stopped | Stop server, check |

## Testing Requirements

### Manual Testing Checklist

**API Endpoint:**
```bash
# Fetch 100 logs (default)
curl http://localhost:4321/api/admin/logs

# Fetch 250 logs
curl http://localhost:4321/api/admin/logs?count=250

# Invalid count
curl http://localhost:4321/api/admin/logs?count=999
# Expected: 400 error
```

**Component:**
- [ ] Logs display in terminal style
- [ ] INFO logs are green
- [ ] WARN logs are yellow
- [ ] ERROR logs are red
- [ ] DEBUG logs are gray
- [ ] Line count dropdown works
- [ ] Filter input filters in real-time
- [ ] Refresh button fetches new logs
- [ ] Auto-scroll scrolls to bottom
- [ ] Disabling auto-scroll allows manual scroll
- [ ] Footer shows log count

### Build Verification

```bash
npm run build
```

Expected: Build succeeds with CloudWatch SDK bundled.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CloudWatch not configured | Medium | Medium | Graceful fallback with message |
| No logs in group | Medium | Low | Return empty array |
| Large log volume | Low | Medium | Limit to 500 lines max |
| Slow CloudWatch response | Low | Low | Timeout handling |

## Success Verification

After implementation:

- [ ] `@aws-sdk/client-cloudwatch-logs` installed
- [ ] `/api/admin/logs` returns log entries
- [ ] LogsViewer displays logs with color coding
- [ ] Filter and line count controls work
- [ ] Graceful handling when CloudWatch not configured

## Traceability

**Parent stories:**
- [Story 01: Setup CloudWatch Logs Integration](../../stories/epic-BG-WEB-002-04/story-01.md)
- [Story 02: Create Logs API Endpoint](../../stories/epic-BG-WEB-002-04/story-02.md)
- [Story 03: Build LogsViewer Component](../../stories/epic-BG-WEB-002-04/story-03.md)

**Parent epic:** [Epic BG-WEB-002-04: Logs Viewer](../../epics/epic-BG-WEB-002-04-logs-viewer.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-04/spec-01-02-03-logs-viewer.md`
