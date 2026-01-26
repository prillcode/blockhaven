---
story_id: 01
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Implement Rate Limiting
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-06-polish-security.md
created: 2026-01-25
---

# Story 01: Implement Rate Limiting

## User Story

**As a** system,
**I want** to rate limit API requests,
**so that** the system is protected from abuse and accidental overload.

## Acceptance Criteria

### Scenario 1: Status endpoint rate limited
**Given** rate limiting is configured
**When** `/api/admin/server/status` receives > 120 requests/minute
**Then** additional requests return 429 Too Many Requests

### Scenario 2: Start/stop endpoints rate limited
**Given** rate limiting is configured
**When** `/api/admin/server/start` or `/stop` receives > 5 requests/minute
**Then** additional requests return 429 Too Many Requests

### Scenario 3: Logs endpoint rate limited
**Given** rate limiting is configured
**When** `/api/admin/logs` receives > 30 requests/minute
**Then** additional requests return 429 Too Many Requests

### Scenario 4: RCON endpoint rate limited
**Given** rate limiting is configured
**When** `/api/admin/rcon` receives > 10 requests/minute
**Then** additional requests return 429 Too Many Requests

### Scenario 5: Rate limit tracked per user
**Given** two different authenticated users
**When** they make requests
**Then** each user has independent rate limits

### Scenario 6: Clear error message
**Given** a user is rate limited
**When** they make another request
**Then** error message indicates rate limit exceeded
**And** response includes `Retry-After` header

### Scenario 7: Rate limit stored in KV
**Given** the system uses Cloudflare KV
**When** rate limits are tracked
**Then** counts are stored in KV with appropriate TTL
**And** distributed across edge locations

## Business Value

**Why this matters:** Rate limiting prevents abuse, protects AWS API quotas, and ensures fair usage across users.

**Impact:** System remains stable under load and protects against both malicious and accidental overuse.

**Success metric:** No AWS API throttling due to dashboard usage.

## Technical Considerations

**Rate Limit Configuration:**
```typescript
// src/lib/rateLimit.ts
export const RATE_LIMITS: Record<string, { windowMs: number; max: number }> = {
  "/api/admin/server/status": { windowMs: 60000, max: 120 },
  "/api/admin/server/start": { windowMs: 60000, max: 5 },
  "/api/admin/server/stop": { windowMs: 60000, max: 5 },
  "/api/admin/logs": { windowMs: 60000, max: 30 },
  "/api/admin/rcon": { windowMs: 60000, max: 10 },
}
```

**Rate Limit Implementation:**
```typescript
// src/lib/rateLimit.ts
import type { KVNamespace } from "@cloudflare/workers-types"

export async function checkRateLimit(
  kv: KVNamespace,
  userId: string,
  endpoint: string
): Promise<{ allowed: boolean; remaining: number; resetAt: number }> {
  const config = RATE_LIMITS[endpoint] || { windowMs: 60000, max: 60 }
  const windowStart = Math.floor(Date.now() / config.windowMs) * config.windowMs
  const key = `ratelimit:${userId}:${endpoint}:${windowStart}`

  const current = parseInt((await kv.get(key)) || "0", 10)

  if (current >= config.max) {
    return {
      allowed: false,
      remaining: 0,
      resetAt: windowStart + config.windowMs,
    }
  }

  await kv.put(key, String(current + 1), {
    expirationTtl: Math.ceil(config.windowMs / 1000) + 60,
  })

  return {
    allowed: true,
    remaining: config.max - current - 1,
    resetAt: windowStart + config.windowMs,
  }
}
```

**Middleware Integration:**
```typescript
// In middleware or each API route
const rateLimit = await checkRateLimit(env.KV, session.user.id, url.pathname)

if (!rateLimit.allowed) {
  return new Response(JSON.stringify({ error: "Rate limit exceeded" }), {
    status: 429,
    headers: {
      "Content-Type": "application/json",
      "Retry-After": String(Math.ceil((rateLimit.resetAt - Date.now()) / 1000)),
      "X-RateLimit-Remaining": "0",
      "X-RateLimit-Reset": String(rateLimit.resetAt),
    },
  })
}
```

## Dependencies

**Depends on stories:**
- Epic 1: Authentication (user ID for tracking)
- Epic 1: Cloudflare KV setup

**Enables stories:**
- Story 05: Security Audit

## Out of Scope

- Global rate limiting (per-user only)
- IP-based rate limiting for unauthenticated routes
- Rate limit bypass for admin users
- Configurable limits via UI

## Notes

- KV TTL should be slightly longer than window to avoid edge cases
- Consider adding rate limit headers to all responses
- Rate limits should be conservative initially, can be adjusted
- Track by user ID, not session (handles multiple sessions)

## Traceability

**Parent epic:** [epic-BG-WEB-002-06-polish-security.md](../../epics/epic-BG-WEB-002-06-polish-security.md)

**Related stories:** Story 05 (Security Audit)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-06/story-01.md`
