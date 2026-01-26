---
spec_id: 01
story_ids: [01]
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Implement Rate Limiting for API Endpoints
status: ready_for_implementation
complexity: medium
parent_story: ../../stories/epic-BG-WEB-002-06/story-01.md
created: 2026-01-25
---

# Technical Spec 01: Implement Rate Limiting

## Overview

**User story:** [Story 01: Implement Rate Limiting](../../stories/epic-BG-WEB-002-06/story-01.md)

**Goal:** Protect API endpoints from abuse by implementing per-user rate limiting using Cloudflare KV storage. Different endpoints have different limits based on their resource intensity.

**Approach:** Create a rate limiting module that stores request counts in Cloudflare KV with TTL-based windows, integrate it into the auth middleware to check limits before processing requests.

## Technical Design

### Rate Limits

| Endpoint | Limit | Window | Rationale |
|----------|-------|--------|-----------|
| `/api/admin/server/status` | 120/min | 60s | Frequent polling OK |
| `/api/admin/server/start` | 5/min | 60s | Prevent rapid cycling |
| `/api/admin/server/stop` | 5/min | 60s | Prevent rapid cycling |
| `/api/admin/logs` | 30/min | 60s | Moderate CloudWatch usage |
| `/api/admin/rcon` | 10/min | 60s | Limit command execution |

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  Incoming Request                                                    │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Middleware                                                          │
│  1. Check authentication (existing)                                 │
│  2. Check rate limit (new)                                          │
│     └── Read from KV: ratelimit:{userId}:{endpoint}:{window}        │
│  3. If over limit → 429 Too Many Requests                           │
│  4. If under limit → increment count, proceed                       │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Cloudflare KV: BLOCKHAVEN_RATE_LIMITS                              │
│  Key: ratelimit:{userId}:{endpoint}:{windowStart}                   │
│  Value: current count (number)                                      │
│  TTL: window duration + buffer                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation Details

### Files to Create

#### 1. Rate Limiting Module

**`web/src/lib/rateLimit.ts`**

```typescript
// src/lib/rateLimit.ts
// Rate limiting using Cloudflare KV
//
// Implements sliding window rate limiting per user per endpoint.
// Stores counts in Cloudflare KV with automatic expiration.

/**
 * Rate limit configuration per endpoint
 */
export const RATE_LIMITS: Record<string, { windowMs: number; max: number }> = {
  "/api/admin/server/status": { windowMs: 60000, max: 120 },  // 120/min
  "/api/admin/server/start": { windowMs: 60000, max: 5 },     // 5/min
  "/api/admin/server/stop": { windowMs: 60000, max: 5 },      // 5/min
  "/api/admin/logs": { windowMs: 60000, max: 30 },            // 30/min
  "/api/admin/rcon": { windowMs: 60000, max: 10 },            // 10/min
};

/**
 * Default rate limit for unspecified admin endpoints
 */
const DEFAULT_LIMIT = { windowMs: 60000, max: 60 };  // 60/min

/**
 * Rate limit check result
 */
export interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetAt: number;       // Unix timestamp (ms)
  limit: number;
}

/**
 * Check rate limit for a user and endpoint
 *
 * @param kv - Cloudflare KV namespace
 * @param userId - User identifier (from session)
 * @param endpoint - API endpoint path
 * @returns Rate limit result
 */
export async function checkRateLimit(
  kv: KVNamespace,
  userId: string,
  endpoint: string
): Promise<RateLimitResult> {
  const config = RATE_LIMITS[endpoint] || DEFAULT_LIMIT;

  // Calculate window start (floor to window boundary)
  const windowStart = Math.floor(Date.now() / config.windowMs) * config.windowMs;
  const resetAt = windowStart + config.windowMs;

  // Build key
  const key = `ratelimit:${userId}:${endpoint}:${windowStart}`;

  // Get current count
  const currentStr = await kv.get(key);
  const current = currentStr ? parseInt(currentStr, 10) : 0;

  // Check if over limit
  if (current >= config.max) {
    return {
      allowed: false,
      remaining: 0,
      resetAt,
      limit: config.max,
    };
  }

  // Increment count
  const newCount = current + 1;
  const ttlSeconds = Math.ceil(config.windowMs / 1000) + 60; // Extra buffer

  await kv.put(key, String(newCount), {
    expirationTtl: ttlSeconds,
  });

  return {
    allowed: true,
    remaining: config.max - newCount,
    resetAt,
    limit: config.max,
  };
}

/**
 * Create rate limit response headers
 */
export function rateLimitHeaders(result: RateLimitResult): Record<string, string> {
  return {
    "X-RateLimit-Limit": String(result.limit),
    "X-RateLimit-Remaining": String(result.remaining),
    "X-RateLimit-Reset": String(Math.ceil(result.resetAt / 1000)),
    ...(result.allowed ? {} : {
      "Retry-After": String(Math.ceil((result.resetAt - Date.now()) / 1000)),
    }),
  };
}

/**
 * Create 429 Too Many Requests response
 */
export function rateLimitExceededResponse(result: RateLimitResult): Response {
  const retryAfter = Math.ceil((result.resetAt - Date.now()) / 1000);

  return new Response(
    JSON.stringify({
      error: "Too Many Requests",
      message: `Rate limit exceeded. Try again in ${retryAfter} seconds.`,
      retryAfter,
    }),
    {
      status: 429,
      headers: {
        "Content-Type": "application/json",
        ...rateLimitHeaders(result),
      },
    }
  );
}
```

#### 2. KV Type Definition

**`web/src/env.d.ts`** - Add KV namespace type:

```typescript
/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />

// Cloudflare KV namespace bindings
interface KVNamespace {
  get(key: string): Promise<string | null>;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void>;
  delete(key: string): Promise<void>;
}

declare namespace App {
  interface Locals {
    session?: {
      user: {
        name?: string | null;
        email?: string | null;
        image?: string | null;
        githubUsername?: string;
      };
      expires: string;
    };
    runtime: {
      env: {
        BLOCKHAVEN_RATE_LIMITS?: KVNamespace;
      };
    };
  }
}
```

### Files to Modify

#### Update Middleware

**`web/src/middleware.ts`** - Add rate limiting:

```typescript
import { defineMiddleware } from "astro:middleware";
import { getSession } from "./lib/auth-helpers";
import {
  checkRateLimit,
  rateLimitExceededResponse,
  rateLimitHeaders,
} from "./lib/rateLimit";

const PROTECTED_PAGE_PREFIXES = ["/dashboard"];
const PROTECTED_API_PREFIXES = ["/api/admin"];

function startsWithAny(path: string, prefixes: string[]): boolean {
  return prefixes.some((prefix) => path === prefix || path.startsWith(prefix + "/"));
}

export const onRequest = defineMiddleware(async (context, next) => {
  const { request, redirect, locals } = context;
  const url = new URL(request.url);
  const path = url.pathname;

  const isProtectedPage = startsWithAny(path, PROTECTED_PAGE_PREFIXES);
  const isProtectedApi = startsWithAny(path, PROTECTED_API_PREFIXES);

  if (!isProtectedPage && !isProtectedApi) {
    return next();
  }

  // Check authentication
  const session = await getSession(request);

  if (!session || !session.user) {
    if (isProtectedApi) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }
    return redirect("/login", 302);
  }

  // Rate limiting (only for API routes)
  if (isProtectedApi) {
    const kv = (locals as any).runtime?.env?.BLOCKHAVEN_RATE_LIMITS;

    if (kv) {
      const userId = session.user.githubUsername || session.user.email || "unknown";
      const result = await checkRateLimit(kv, userId, path);

      if (!result.allowed) {
        return rateLimitExceededResponse(result);
      }

      // Add rate limit headers to response
      const response = await next();
      const newHeaders = new Headers(response.headers);
      for (const [key, value] of Object.entries(rateLimitHeaders(result))) {
        newHeaders.set(key, value);
      }
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: newHeaders,
      });
    }
  }

  return next();
});
```

### Wrangler Configuration

**`web/wrangler.toml`** - Add KV namespace:

```toml
name = "blockhaven-web"
compatibility_date = "2024-01-01"
pages_build_output_dir = "./dist"

[[kv_namespaces]]
binding = "BLOCKHAVEN_RATE_LIMITS"
id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # Replace with actual KV ID

[env.production]
[[env.production.kv_namespaces]]
binding = "BLOCKHAVEN_RATE_LIMITS"
id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # Production KV ID
```

**Create KV namespace:**
```bash
wrangler kv:namespace create BLOCKHAVEN_RATE_LIMITS
# Copy the ID to wrangler.toml
```

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Status endpoint: 120/min | `RATE_LIMITS` config | Test with rapid requests |
| Start/stop: 5/min | `RATE_LIMITS` config | Test rapid clicking |
| Logs: 30/min | `RATE_LIMITS` config | Test rapid refreshes |
| RCON: 10/min | `RATE_LIMITS` config | Test command spam |
| Per-user tracking | `userId` in key | Different users have separate limits |
| 429 response | `rateLimitExceededResponse()` | Exceed limit, check response |
| Retry-After header | Included in 429 | Check headers |
| KV storage | `kv.put()` with TTL | Check KV console |

## Testing Requirements

### Manual Testing

**Exceed rate limit:**
```bash
# Rapid-fire requests to trigger limit
for i in {1..150}; do
  curl -s http://localhost:4321/api/admin/server/status &
done
wait

# Check for 429 response
curl -i http://localhost:4321/api/admin/server/status
# Should return 429 with Retry-After header
```

**Check headers:**
```bash
curl -i http://localhost:4321/api/admin/server/status

# Look for:
# X-RateLimit-Limit: 120
# X-RateLimit-Remaining: 119
# X-RateLimit-Reset: 1737900000
```

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; KV bindings configured.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| KV not available locally | Medium | Low | Graceful skip in dev |
| KV latency affects response | Low | Low | KV is edge-local, very fast |
| Wrong user ID extracted | Low | Medium | Use consistent user identifier |

## Success Verification

After implementation:

- [ ] Rate limit headers appear on all admin API responses
- [ ] Exceeding limit returns 429 with Retry-After
- [ ] Limits reset after window expires
- [ ] Different endpoints have different limits
- [ ] Per-user limits work correctly

## Traceability

**Parent story:** [Story 01: Implement Rate Limiting](../../stories/epic-BG-WEB-002-06/story-01.md)

**Parent epic:** [Epic BG-WEB-002-06: Polish & Security](../../epics/epic-BG-WEB-002-06-polish-security.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-06/spec-01-rate-limiting.md`
