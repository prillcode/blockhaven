---
spec_id: 06-07-08
story_ids: [06, 07, 08]
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Dashboard Components - Status Card, Controls, and Auto-Refresh
status: ready_for_implementation
complexity: medium
parent_stories:
  - ../../stories/epic-BG-WEB-002-02/story-06.md
  - ../../stories/epic-BG-WEB-002-02/story-07.md
  - ../../stories/epic-BG-WEB-002-02/story-08.md
created: 2026-01-25
---

# Technical Spec 06-07-08: Dashboard Components

## Overview

**User stories:**
- [Story 06: Build ServerStatusCard Component](../../stories/epic-BG-WEB-002-02/story-06.md)
- [Story 07: Build ServerControls Component](../../stories/epic-BG-WEB-002-02/story-07.md)
- [Story 08: Implement Auto-Refresh](../../stories/epic-BG-WEB-002-02/story-08.md)

**Goal:** Build React components for the dashboard that display server status, provide start/stop controls with confirmation dialogs, and automatically refresh data on an interval.

**Approach:** Use React (via Astro islands) for interactive components. Create a custom hook for status polling that handles normal (30s) and transitioning (5s) refresh intervals.

## Technical Design

### Component Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  Dashboard Page (dashboard.astro)                                    │
│  ├── DashboardContent (React island, client:load)                   │
│  │   ├── useServerStatus() hook                                     │
│  │   │   ├── status state                                           │
│  │   │   ├── loading state                                          │
│  │   │   ├── lastUpdated state                                      │
│  │   │   └── refresh() function                                     │
│  │   │                                                               │
│  │   ├── ServerStatusCard                                           │
│  │   │   ├── State indicator (green/red/yellow)                     │
│  │   │   ├── IP address                                             │
│  │   │   ├── Uptime                                                 │
│  │   │   ├── Player count                                           │
│  │   │   └── Manual refresh button                                  │
│  │   │                                                               │
│  │   └── ServerControls                                             │
│  │       ├── Start button (when stopped)                            │
│  │       ├── Stop button (when running)                             │
│  │       └── ConfirmDialog (for stop action)                        │
└─────────────────────────────────────────────────────────────────────┘
```

### State Management

```typescript
interface ServerStatus {
  ec2: {
    state: "running" | "stopped" | "starting" | "stopping" | "pending";
    publicIp: string | null;
    instanceId: string;
    launchTime: string | null;
    uptimeSeconds: number | null;
  };
  minecraft: {
    online: boolean;
    players: { online: number; max: number; list: string[] };
    version: string | null;
  } | null;
  timestamp: string;
}
```

## Implementation Details

### Files to Create

#### 1. Server Status Hook

**`web/src/hooks/useServerStatus.ts`**

```typescript
// src/hooks/useServerStatus.ts
// React hook for fetching and auto-refreshing server status

import { useState, useEffect, useCallback, useRef } from "react";

interface ServerStatus {
  ec2: {
    state: string;
    publicIp: string | null;
    instanceId: string;
    launchTime: string | null;
    uptimeSeconds: number | null;
  };
  minecraft: {
    online: boolean;
    players: { online: number; max: number; list: string[] };
    version: string | null;
    motd: string | null;
  } | null;
  timestamp: string;
}

interface UseServerStatusResult {
  status: ServerStatus | null;
  loading: boolean;
  error: string | null;
  lastUpdated: Date | null;
  refresh: () => Promise<void>;
}

// Refresh intervals
const NORMAL_INTERVAL = 30000;      // 30 seconds
const TRANSITION_INTERVAL = 5000;   // 5 seconds during state changes

export function useServerStatus(): UseServerStatusResult {
  const [status, setStatus] = useState<ServerStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null);

  // Use ref to track if component is mounted
  const isMounted = useRef(true);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const fetchStatus = useCallback(async () => {
    try {
      setLoading(true);
      const response = await fetch("/api/admin/server/status");

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();

      if (isMounted.current) {
        setStatus(data);
        setError(null);
        setLastUpdated(new Date());
      }
    } catch (err) {
      if (isMounted.current) {
        setError(err instanceof Error ? err.message : "Failed to fetch status");
      }
    } finally {
      if (isMounted.current) {
        setLoading(false);
      }
    }
  }, []);

  // Determine refresh interval based on state
  const getRefreshInterval = useCallback(() => {
    const state = status?.ec2?.state;
    if (state === "starting" || state === "stopping" || state === "pending") {
      return TRANSITION_INTERVAL;
    }
    return NORMAL_INTERVAL;
  }, [status?.ec2?.state]);

  // Setup auto-refresh
  useEffect(() => {
    isMounted.current = true;
    fetchStatus();

    return () => {
      isMounted.current = false;
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [fetchStatus]);

  // Update interval when state changes
  useEffect(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    const interval = getRefreshInterval();
    intervalRef.current = setInterval(fetchStatus, interval);

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [fetchStatus, getRefreshInterval]);

  // Pause when tab is hidden, refresh when visible
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        fetchStatus();
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [fetchStatus]);

  return { status, loading, error, lastUpdated, refresh: fetchStatus };
}
```

#### 2. Server Status Card Component

**`web/src/components/admin/ServerStatusCard.tsx`**

```tsx
// src/components/admin/ServerStatusCard.tsx
// Displays server status with state indicator, IP, uptime, and players

import React from "react";

interface ServerStatusCardProps {
  status: {
    ec2: {
      state: string;
      publicIp: string | null;
      uptimeSeconds: number | null;
    };
    minecraft: {
      online: boolean;
      players: { online: number; max: number; list: string[] };
    } | null;
  } | null;
  loading: boolean;
  error: string | null;
  lastUpdated: Date | null;
  onRefresh: () => void;
}

const STATE_COLORS: Record<string, string> = {
  running: "bg-mc-green",
  stopped: "bg-accent-redstone",
  starting: "bg-accent-gold",
  stopping: "bg-accent-gold",
  pending: "bg-accent-gold",
};

const STATE_LABELS: Record<string, string> = {
  running: "Running",
  stopped: "Stopped",
  starting: "Starting...",
  stopping: "Stopping...",
  pending: "Pending...",
};

function formatUptime(seconds: number | null): string {
  if (!seconds) return "—";

  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  if (hours >= 24) {
    const days = Math.floor(hours / 24);
    const remainingHours = hours % 24;
    return `${days}d ${remainingHours}h`;
  }

  return `${hours}h ${minutes}m`;
}

function formatLastUpdated(date: Date | null): string {
  if (!date) return "";
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 5) return "Just now";
  if (seconds < 60) return `${seconds}s ago`;
  return `${Math.floor(seconds / 60)}m ago`;
}

export function ServerStatusCard({
  status,
  loading,
  error,
  lastUpdated,
  onRefresh,
}: ServerStatusCardProps) {
  const state = status?.ec2?.state || "unknown";
  const stateColor = STATE_COLORS[state] || "bg-secondary-stone";
  const stateLabel = STATE_LABELS[state] || state;
  const isTransitioning = state === "starting" || state === "stopping" || state === "pending";

  // Loading skeleton
  if (loading && !status) {
    return (
      <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6 animate-pulse">
        <div className="h-6 bg-secondary-stone/30 rounded w-1/3 mb-4" />
        <div className="space-y-3">
          <div className="h-4 bg-secondary-stone/30 rounded w-2/3" />
          <div className="h-4 bg-secondary-stone/30 rounded w-1/2" />
          <div className="h-4 bg-secondary-stone/30 rounded w-3/4" />
        </div>
      </div>
    );
  }

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      {/* Header */}
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-semibold text-text-light">Server Status</h2>
        <button
          onClick={onRefresh}
          disabled={loading}
          className="p-2 hover:bg-secondary-stone/30 rounded-lg transition-colors disabled:opacity-50"
          title="Refresh status"
        >
          <svg
            className={`w-5 h-5 text-text-muted ${loading ? "animate-spin" : ""}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
        </button>
      </div>

      {/* Error State */}
      {error && (
        <div className="mb-4 p-3 bg-accent-redstone/20 border border-accent-redstone/40 rounded-lg">
          <p className="text-accent-redstone text-sm">{error}</p>
        </div>
      )}

      {/* Status Grid */}
      <div className="space-y-3">
        {/* State */}
        <div className="flex justify-between items-center">
          <span className="text-text-muted">State</span>
          <div className="flex items-center gap-2">
            <span className={`w-3 h-3 rounded-full ${stateColor} ${isTransitioning ? "animate-pulse" : ""}`} />
            <span className="text-text-light font-medium">{stateLabel}</span>
          </div>
        </div>

        {/* IP Address */}
        <div className="flex justify-between items-center">
          <span className="text-text-muted">IP Address</span>
          <span className="text-text-light font-mono text-sm">
            {status?.ec2?.publicIp || "—"}
          </span>
        </div>

        {/* Uptime */}
        <div className="flex justify-between items-center">
          <span className="text-text-muted">Uptime</span>
          <span className="text-text-light">
            {formatUptime(status?.ec2?.uptimeSeconds || null)}
          </span>
        </div>

        {/* Players */}
        {status?.minecraft && (
          <div className="flex justify-between items-center">
            <span className="text-text-muted">Players</span>
            <span className="text-text-light">
              {status.minecraft.online
                ? `${status.minecraft.players.online} / ${status.minecraft.players.max}`
                : "Offline"}
            </span>
          </div>
        )}
      </div>

      {/* Player List */}
      {status?.minecraft?.players?.list && status.minecraft.players.list.length > 0 && (
        <div className="mt-4 pt-4 border-t border-secondary-stone/30">
          <p className="text-text-muted text-sm mb-2">Online Players:</p>
          <div className="flex flex-wrap gap-2">
            {status.minecraft.players.list.map((player) => (
              <span
                key={player}
                className="px-2 py-1 bg-mc-green/20 text-mc-green text-sm rounded"
              >
                {player}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Last Updated */}
      {lastUpdated && (
        <div className="mt-4 pt-4 border-t border-secondary-stone/30">
          <p className="text-text-muted text-xs">
            Updated {formatLastUpdated(lastUpdated)}
          </p>
        </div>
      )}
    </div>
  );
}
```

#### 3. Server Controls Component

**`web/src/components/admin/ServerControls.tsx`**

```tsx
// src/components/admin/ServerControls.tsx
// Start/Stop server buttons with confirmation dialog

import React, { useState } from "react";

interface ServerControlsProps {
  serverState: string | null;
  loading: boolean;
  onStart: () => Promise<void>;
  onStop: () => Promise<void>;
}

export function ServerControls({
  serverState,
  loading,
  onStart,
  onStop,
}: ServerControlsProps) {
  const [actionLoading, setActionLoading] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

  const isRunning = serverState === "running";
  const isStopped = serverState === "stopped";
  const isTransitioning = serverState === "starting" || serverState === "stopping" || serverState === "pending";

  const handleStart = async () => {
    setActionLoading(true);
    setMessage(null);
    try {
      await onStart();
      setMessage({ type: "success", text: "Server is starting..." });
    } catch (err) {
      setMessage({ type: "error", text: "Failed to start server" });
    } finally {
      setActionLoading(false);
    }
  };

  const handleStop = async () => {
    setShowConfirm(false);
    setActionLoading(true);
    setMessage(null);
    try {
      await onStop();
      setMessage({ type: "success", text: "Server is stopping..." });
    } catch (err) {
      setMessage({ type: "error", text: "Failed to stop server" });
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 className="text-lg font-semibold text-text-light mb-4">Server Controls</h2>

      {/* Action Buttons */}
      <div className="flex gap-4">
        {isStopped && (
          <button
            onClick={handleStart}
            disabled={actionLoading || loading}
            className="flex-1 px-6 py-3 bg-mc-green hover:bg-mc-dark-green text-white font-medium rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {actionLoading ? (
              <LoadingSpinner />
            ) : (
              <>
                <PlayIcon />
                Start Server
              </>
            )}
          </button>
        )}

        {isRunning && (
          <button
            onClick={() => setShowConfirm(true)}
            disabled={actionLoading || loading}
            className="flex-1 px-6 py-3 bg-accent-redstone hover:bg-accent-redstone/80 text-white font-medium rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <StopIcon />
            Stop Server
          </button>
        )}

        {isTransitioning && (
          <div className="flex-1 px-6 py-3 bg-accent-gold/20 text-accent-gold font-medium rounded-lg flex items-center justify-center gap-2">
            <LoadingSpinner />
            Server is {serverState}...
          </div>
        )}
      </div>

      {/* Message */}
      {message && (
        <div
          className={`mt-4 p-3 rounded-lg ${
            message.type === "success"
              ? "bg-mc-green/20 text-mc-green"
              : "bg-accent-redstone/20 text-accent-redstone"
          }`}
        >
          {message.text}
        </div>
      )}

      {/* Confirmation Dialog */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-bg-dark border border-secondary-stone/30 rounded-lg p-6 max-w-md w-full">
            <h3 className="text-xl font-bold text-text-light mb-2">Stop Server?</h3>
            <p className="text-text-muted mb-6">
              This will disconnect all players. The world data will be saved before shutdown.
            </p>
            <div className="flex gap-4">
              <button
                onClick={() => setShowConfirm(false)}
                className="flex-1 px-4 py-2 bg-secondary-stone/30 hover:bg-secondary-stone/50 text-text-light rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleStop}
                disabled={actionLoading}
                className="flex-1 px-4 py-2 bg-accent-redstone hover:bg-accent-redstone/80 text-white rounded-lg transition-colors disabled:opacity-50"
              >
                {actionLoading ? <LoadingSpinner /> : "Stop Server"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Icons
function PlayIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}

function StopIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M6 6h12v12H6z" />
    </svg>
  );
}

function LoadingSpinner() {
  return (
    <svg className="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );
}
```

#### 4. Dashboard Content Component

**`web/src/components/admin/DashboardContent.tsx`**

```tsx
// src/components/admin/DashboardContent.tsx
// Main dashboard content with server status and controls

import React from "react";
import { useServerStatus } from "../../hooks/useServerStatus";
import { ServerStatusCard } from "./ServerStatusCard";
import { ServerControls } from "./ServerControls";

export function DashboardContent() {
  const { status, loading, error, lastUpdated, refresh } = useServerStatus();

  const handleStart = async () => {
    const response = await fetch("/api/admin/server/start", { method: "POST" });
    if (!response.ok) {
      throw new Error("Failed to start server");
    }
    // Refresh status after action
    setTimeout(refresh, 1000);
  };

  const handleStop = async () => {
    const response = await fetch("/api/admin/server/stop", { method: "POST" });
    if (!response.ok) {
      throw new Error("Failed to stop server");
    }
    // Refresh status after action
    setTimeout(refresh, 1000);
  };

  return (
    <div className="grid gap-6 md:grid-cols-2">
      <ServerStatusCard
        status={status}
        loading={loading}
        error={error}
        lastUpdated={lastUpdated}
        onRefresh={refresh}
      />
      <ServerControls
        serverState={status?.ec2?.state || null}
        loading={loading}
        onStart={handleStart}
        onStop={handleStop}
      />
    </div>
  );
}
```

### Files to Modify

#### Update Dashboard Page

**`web/src/pages/dashboard.astro`** - Replace placeholder with React component:

```astro
---
// src/pages/dashboard.astro
export const prerender = false;

import { getSession } from "../lib/auth-helpers";
import DashboardLayout from "../layouts/DashboardLayout.astro";
import { DashboardContent } from "../components/admin/DashboardContent";

const session = await getSession(Astro.request);
if (!session || !session.user) {
  return Astro.redirect("/login");
}

const { user } = session;
---

<DashboardLayout title="Dashboard - BlockHaven Admin" user={user}>
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-primary-gold">Server Dashboard</h1>
    <p class="text-text-muted mt-2">Manage your Minecraft server from anywhere</p>
  </div>

  <DashboardContent client:load />

  <!-- Future components will go here (Cost, Logs, Quick Actions) -->
</DashboardLayout>
```

## Acceptance Criteria Mapping

### Story 06: ServerStatusCard

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Displays running state | Green indicator + "Running" | Visual check |
| Displays stopped state | Red indicator + "Stopped" | Visual check |
| Displays transitioning states | Yellow + animated pulse | Visual check |
| Shows IP address | `status.ec2.publicIp` | Visual check |
| Shows uptime | `formatUptime()` | Visual check |
| Shows player count | `minecraft.players.online/max` | Visual check |
| Shows player names | Player list badges | Visual check |
| Loading skeleton | Animated placeholder | Visual check |
| Mobile responsive | Single column on mobile | Test at 320px |

### Story 07: ServerControls

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Start button when stopped | Green button with play icon | Visual check |
| Stop button when running | Red button with stop icon | Visual check |
| Confirmation dialog for stop | Modal with cancel/confirm | Click stop |
| Loading state during action | Spinner replaces icon | Click and watch |
| Success feedback | Green message | Complete action |
| Error feedback | Red message | Trigger error |
| Disabled during transition | Buttons disabled | During start/stop |
| Mobile-friendly buttons | Min 44px height | Test on mobile |

### Story 08: Auto-Refresh

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| 30-second normal refresh | `NORMAL_INTERVAL = 30000` | Wait and observe |
| 5-second transition refresh | `TRANSITION_INTERVAL = 5000` | Start/stop and observe |
| Pause when tab hidden | `visibilitychange` listener | Switch tabs |
| Refresh on tab visible | `fetchStatus()` on visible | Switch back |
| Manual refresh resets timer | `clearInterval` + restart | Click refresh |
| Shows last updated time | `formatLastUpdated()` | Visual check |

## Testing Requirements

### Manual Testing Checklist

**ServerStatusCard:**
- [ ] Shows loading skeleton on initial load
- [ ] Shows green indicator when running
- [ ] Shows red indicator when stopped
- [ ] Shows yellow pulsing indicator during transitions
- [ ] Shows IP address when running
- [ ] Shows "—" for IP when stopped
- [ ] Shows formatted uptime (e.g., "2h 30m")
- [ ] Shows player count (e.g., "3 / 20")
- [ ] Shows player names in badges
- [ ] Shows "Updated X seconds ago"
- [ ] Refresh button spins while loading

**ServerControls:**
- [ ] Shows Start button when stopped
- [ ] Shows Stop button when running
- [ ] Shows "Server is starting..." during start
- [ ] Shows "Server is stopping..." during stop
- [ ] Stop button opens confirmation dialog
- [ ] Cancel closes dialog without action
- [ ] Confirm stops server
- [ ] Success message appears after action
- [ ] Buttons are disabled during transitions

**Auto-Refresh:**
- [ ] Status refreshes every 30 seconds normally
- [ ] Status refreshes every 5 seconds during transitions
- [ ] Switching tabs pauses refresh
- [ ] Returning to tab triggers immediate refresh
- [ ] Manual refresh works
- [ ] "Last updated" updates in real-time

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; React components bundled correctly.

## Success Verification

After implementation:

- [ ] Dashboard shows live server status
- [ ] Start/stop buttons work correctly
- [ ] Confirmation dialog prevents accidental stops
- [ ] Auto-refresh keeps data current
- [ ] Mobile layout is usable
- [ ] No console errors

## Traceability

**Parent stories:**
- [Story 06: Build ServerStatusCard Component](../../stories/epic-BG-WEB-002-02/story-06.md)
- [Story 07: Build ServerControls Component](../../stories/epic-BG-WEB-002-02/story-07.md)
- [Story 08: Implement Auto-Refresh](../../stories/epic-BG-WEB-002-02/story-08.md)

**Parent epic:** [Epic BG-WEB-002-02: Server Controls](../../epics/epic-BG-WEB-002-02-server-controls.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-06-07-08-dashboard-components.md`
