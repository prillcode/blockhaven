---
spec_id: 02-03
story_ids: [02, 03]
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Server Status API with EC2 and Minecraft Status
status: ready_for_implementation
complexity: medium
parent_stories:
  - ../../stories/epic-BG-WEB-002-02/story-02.md
  - ../../stories/epic-BG-WEB-002-02/story-03.md
created: 2026-01-25
---

# Technical Spec 02-03: Server Status API with EC2 and Minecraft Status

## Overview

**User stories:**
- [Story 02: Create Server Status API](../../stories/epic-BG-WEB-002-02/story-02.md)
- [Story 03: Integrate mcstatus.io for Minecraft Status](../../stories/epic-BG-WEB-002-02/story-03.md)

**Goal:** Create an API endpoint that returns combined EC2 instance status (state, IP, uptime) and Minecraft server status (online, players) from mcstatus.io.

**Approach:** Create `/api/admin/server/status` endpoint that queries EC2 DescribeInstances and (if running) queries mcstatus.io API for Minecraft-specific data.

## Technical Design

### API Response Structure

```typescript
interface ServerStatusResponse {
  // EC2 Status
  ec2: {
    state: "running" | "stopped" | "starting" | "stopping" | "pending";
    publicIp: string | null;
    instanceId: string;
    launchTime: string | null;  // ISO 8601
    uptimeSeconds: number | null;
  };

  // Minecraft Status (null if EC2 not running)
  minecraft: {
    online: boolean;
    players: {
      online: number;
      max: number;
      list: string[];  // Player names
    };
    version: string | null;
    motd: string | null;
  } | null;

  // Metadata
  timestamp: string;  // ISO 8601
}
```

### Data Flow

```
┌────────────────────────────────────────────────────────────────────┐
│  GET /api/admin/server/status                                       │
└────────────────────────────────────┬───────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────┐
│  1. Query AWS EC2 DescribeInstances                                 │
│     └── Get state, publicIp, launchTime                            │
└────────────────────────────────────┬───────────────────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
              EC2 Running                       EC2 Not Running
                    │                                 │
                    ▼                                 ▼
┌────────────────────────────────────┐    ┌──────────────────────────┐
│  2. Query mcstatus.io API          │    │  minecraft: null         │
│     └── Get players, version, etc. │    │  (skip mcstatus query)   │
└────────────────────────────────────┘    └──────────────────────────┘
                    │                                 │
                    └────────────────┬────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────┐
│  3. Return combined response                                        │
└────────────────────────────────────────────────────────────────────┘
```

## Implementation Details

### Files to Create

#### 1. Minecraft Status Helper

**`web/src/lib/minecraft.ts`**

```typescript
// src/lib/minecraft.ts
// Minecraft server status via mcstatus.io API
//
// Uses the free mcstatus.io API to get Minecraft-specific server info
// including player count, version, and MOTD.

/**
 * Minecraft server status from mcstatus.io
 */
export interface MinecraftStatus {
  online: boolean;
  players: {
    online: number;
    max: number;
    list: string[];
  };
  version: string | null;
  motd: string | null;
}

/**
 * mcstatus.io API response type (partial)
 */
interface MCStatusResponse {
  online: boolean;
  players?: {
    online: number;
    max: number;
    list?: Array<{
      name_raw: string;
      name_clean: string;
      uuid: string;
    }>;
  };
  version?: {
    name_raw: string;
    name_clean: string;
  };
  motd?: {
    raw: string;
    clean: string;
  };
}

/**
 * Get Minecraft server status from mcstatus.io
 *
 * @param serverAddress - Minecraft server address (IP or hostname)
 * @returns Minecraft status or offline status on error
 */
export async function getMinecraftStatus(serverAddress: string): Promise<MinecraftStatus> {
  const offlineStatus: MinecraftStatus = {
    online: false,
    players: { online: 0, max: 0, list: [] },
    version: null,
    motd: null,
  };

  try {
    // Use AbortController for timeout (5 seconds)
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    const response = await fetch(
      `https://api.mcstatus.io/v2/status/java/${encodeURIComponent(serverAddress)}`,
      { signal: controller.signal }
    );

    clearTimeout(timeoutId);

    if (!response.ok) {
      console.log(`[Minecraft] mcstatus.io returned ${response.status} for ${serverAddress}`);
      return offlineStatus;
    }

    const data: MCStatusResponse = await response.json();

    if (!data.online) {
      return offlineStatus;
    }

    return {
      online: true,
      players: {
        online: data.players?.online || 0,
        max: data.players?.max || 0,
        list: data.players?.list?.map((p) => p.name_clean) || [],
      },
      version: data.version?.name_clean || null,
      motd: data.motd?.clean || null,
    };
  } catch (error) {
    // Timeout or network error - server likely offline or mcstatus.io unavailable
    if (error instanceof Error && error.name === "AbortError") {
      console.log(`[Minecraft] mcstatus.io timeout for ${serverAddress}`);
    } else {
      console.log(`[Minecraft] Error fetching status:`, error);
    }
    return offlineStatus;
  }
}
```

#### 2. Server Status API Route

**`web/src/pages/api/admin/server/status.ts`**

```typescript
// src/pages/api/admin/server/status.ts
// Server status API endpoint
//
// Returns combined EC2 instance status and Minecraft server status.
// Protected by auth middleware (requires authentication).

import type { APIRoute } from "astro";
import { DescribeInstancesCommand } from "@aws-sdk/client-ec2";
import { getEC2Client, getInstanceId } from "../../../../lib/aws";
import { getMinecraftStatus } from "../../../../lib/minecraft";

export const GET: APIRoute = async () => {
  const ec2Client = getEC2Client();
  const instanceId = getInstanceId();
  const mcServerAddress = import.meta.env.MC_SERVER_IP || "play.bhsmp.com";

  try {
    // Query EC2 for instance status
    const command = new DescribeInstancesCommand({
      InstanceIds: [instanceId],
    });
    const response = await ec2Client.send(command);
    const instance = response.Reservations?.[0]?.Instances?.[0];

    if (!instance) {
      return new Response(
        JSON.stringify({
          error: "Instance not found",
          instanceId,
        }),
        {
          status: 404,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Extract EC2 status
    const state = instance.State?.Name || "unknown";
    const publicIp = instance.PublicIpAddress || null;
    const launchTime = instance.LaunchTime?.toISOString() || null;

    // Calculate uptime in seconds
    let uptimeSeconds: number | null = null;
    if (launchTime && state === "running") {
      uptimeSeconds = Math.floor((Date.now() - new Date(launchTime).getTime()) / 1000);
    }

    // Get Minecraft status only if EC2 is running
    let minecraft = null;
    if (state === "running" && publicIp) {
      minecraft = await getMinecraftStatus(mcServerAddress);
    }

    // Return combined status
    return new Response(
      JSON.stringify({
        ec2: {
          state,
          publicIp,
          instanceId: instance.InstanceId,
          launchTime,
          uptimeSeconds,
        },
        minecraft,
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("[Status API] Error:", error);

    return new Response(
      JSON.stringify({
        error: "Failed to get server status",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
```

### Directory Structure

```
web/src/
├── lib/
│   ├── aws/
│   │   ├── ec2.ts        # EC2 client (from spec-01)
│   │   └── index.ts      # Exports
│   └── minecraft.ts      # mcstatus.io helper
└── pages/
    └── api/
        └── admin/
            └── server/
                └── status.ts  # Status API endpoint
```

## Acceptance Criteria Mapping

### Story 02: Server Status API

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Returns running instance status | DescribeInstances command | Test with running EC2 |
| Includes public IP | `instance.PublicIpAddress` | Check response |
| Includes launch time | `instance.LaunchTime` | Check response |
| Calculates uptime | Math from launchTime | Check uptimeSeconds |
| Returns stopped status | state: "stopped" | Test with stopped EC2 |
| Protected by auth | Middleware protects `/api/admin/*` | Test unauthenticated |
| Handles AWS errors | try/catch with 500 response | Test with bad credentials |
| < 2 second response | EC2 API is fast | Measure response time |

### Story 03: mcstatus.io Integration

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Returns Minecraft online status | `minecraft.online` | Test with running server |
| Returns player count | `minecraft.players.online/max` | Check response |
| Returns player list | `minecraft.players.list` | Check response |
| Handles Minecraft offline | `minecraft.online: false` | Stop Minecraft, test |
| Handles EC2 stopped | `minecraft: null` | Stop EC2, test |
| Handles mcstatus.io errors | Graceful fallback | Block mcstatus.io, test |
| 5 second timeout | `AbortController` | Test slow response |

## Testing Requirements

### Manual Testing Checklist

**EC2 Running + Minecraft Online:**
```bash
curl http://localhost:4321/api/admin/server/status
```

Expected response:
```json
{
  "ec2": {
    "state": "running",
    "publicIp": "1.2.3.4",
    "instanceId": "i-xxx",
    "launchTime": "2026-01-25T10:00:00.000Z",
    "uptimeSeconds": 3600
  },
  "minecraft": {
    "online": true,
    "players": {
      "online": 2,
      "max": 20,
      "list": ["Player1", "Player2"]
    },
    "version": "1.21.1",
    "motd": "Welcome to BlockHaven!"
  },
  "timestamp": "2026-01-25T11:00:00.000Z"
}
```

**EC2 Stopped:**
```json
{
  "ec2": {
    "state": "stopped",
    "publicIp": null,
    "instanceId": "i-xxx",
    "launchTime": null,
    "uptimeSeconds": null
  },
  "minecraft": null,
  "timestamp": "..."
}
```

**Unauthenticated Request:**
```bash
curl -i http://localhost:4321/api/admin/server/status
# Expected: 401 Unauthorized (middleware blocks)
```

### Performance Testing

```bash
# Measure response time
time curl http://localhost:4321/api/admin/server/status
```

Expected: < 2 seconds (typically < 500ms for EC2 + mcstatus.io)

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; no TypeScript errors.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| mcstatus.io rate limiting | Low | Medium | Rate limit: 600 req/10min is generous |
| EC2 API throttling | Low | Medium | Status endpoint won't exceed limits |
| Slow mcstatus.io response | Medium | Low | 5-second timeout + graceful fallback |
| Instance not found | Low | Medium | Clear 404 error message |

## Security Considerations

- **Protected by middleware:** Only authenticated users can access
- **No sensitive data exposed:** Only server state (no credentials)
- **External API (mcstatus.io):** Public API, no auth required
- **AWS credentials:** Never included in response

## Success Verification

After implementation:

- [ ] `/api/admin/server/status` returns EC2 status
- [ ] Response includes `ec2.state`, `ec2.publicIp`, `ec2.uptimeSeconds`
- [ ] Response includes `minecraft` when EC2 is running
- [ ] `minecraft` is `null` when EC2 is stopped
- [ ] mcstatus.io timeout doesn't break the endpoint
- [ ] Response time < 2 seconds

## Traceability

**Parent stories:**
- [Story 02: Create Server Status API](../../stories/epic-BG-WEB-002-02/story-02.md)
- [Story 03: Integrate mcstatus.io](../../stories/epic-BG-WEB-002-02/story-03.md)

**Parent epic:** [Epic BG-WEB-002-02: Server Controls](../../epics/epic-BG-WEB-002-02-server-controls.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-02-03-status-api.md`
