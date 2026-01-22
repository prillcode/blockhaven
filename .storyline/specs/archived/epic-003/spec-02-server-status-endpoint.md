---
spec_id: 02
story_id: 02
epic_id: 003
title: Server Status Endpoint with Caching
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 02: Server Status Endpoint with Caching

## Overview
Create GET /api/server-status endpoint that queries mcstatus.io API with 30-second caching.

## Files to Create
```
src/routes/status.ts
src/utils/cache.ts
src/types/server.ts
```

## Implementation

### src/types/server.ts
```typescript
export interface ServerStatus {
  online: boolean;
  players?: {
    online: number;
    max: number;
  };
  version?: string;
  latency?: number;
  error?: string;
}
```

### src/utils/cache.ts
```typescript
interface CacheEntry<T> {
  data: T;
  expiresAt: number;
}

class SimpleCache {
  private cache = new Map<string, CacheEntry<any>>();

  set<T>(key: string, data: T, ttlSeconds: number): void {
    this.cache.set(key, {
      data,
      expiresAt: Date.now() + ttlSeconds * 1000,
    });
  }

  get<T>(key: string): T | null {
    const entry = this.cache.get(key);
    if (!entry) return null;

    if (Date.now() > entry.expiresAt) {
      this.cache.delete(key);
      return null;
    }

    return entry.data;
  }

  clear(): void {
    this.cache.clear();
  }
}

export const cache = new SimpleCache();
```

### src/routes/status.ts
```typescript
import { Hono } from 'hono';
import { cache } from '../utils/cache';
import type { ServerStatus } from '../types/server';

const status = new Hono();

const MC_SERVER_HOST = process.env.MC_SERVER_HOST || '5.161.69.191';
const MC_SERVER_PORT = process.env.MC_SERVER_PORT || '25565';
const CACHE_KEY = 'minecraft-server-status';
const CACHE_TTL = 30; // seconds

async function fetchServerStatus(): Promise<ServerStatus> {
  try {
    const url = `https://api.mcstatus.io/v2/status/java/${MC_SERVER_HOST}:${MC_SERVER_PORT}`;
    const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
    
    if (!response.ok) {
      throw new Error(`mcstatus.io returned ${response.status}`);
    }

    const data = await response.json();

    if (!data.online) {
      return { online: false, error: 'Server is offline' };
    }

    return {
      online: true,
      players: {
        online: data.players?.online || 0,
        max: data.players?.max || 100,
      },
      version: data.version?.name_clean || 'Unknown',
      latency: data.latency || 0,
    };
  } catch (error) {
    console.error('Error fetching server status:', error);
    return {
      online: false,
      error: 'Unable to fetch server status',
    };
  }
}

status.get('/', async (c) => {
  // Check cache first
  const cached = cache.get<ServerStatus>(CACHE_KEY);
  if (cached) {
    return c.json({ ...cached, cached: true });
  }

  // Fetch fresh data
  const serverStatus = await fetchServerStatus();
  
  // Cache for 30 seconds
  cache.set(CACHE_KEY, serverStatus, CACHE_TTL);

  return c.json({ ...serverStatus, cached: false });
});

export default status;
```

### Update src/index.ts
```typescript
// Add import
import status from './routes/status';

// Add route
app.route('/api/server-status', status);
```

## Testing Checklist
- [ ] GET /api/server-status returns server status
- [ ] Response includes online, players, version, latency
- [ ] Cached responses have cached: true
- [ ] Fresh responses have cached: false
- [ ] Cache expires after 30 seconds
- [ ] Offline server returns online: false with error
- [ ] Request timeout after 5 seconds

## Dependencies
**Depends on:** Spec 01 (Hono server)
**Enables:** Epic 004 ServerStatus widget

---

**Next:** `/dev-story .storyline/specs/epic-003/spec-02-server-status-endpoint.md`
