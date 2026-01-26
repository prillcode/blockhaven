---
story_id: 03
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Implement Session Storage with Cloudflare KV
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 03: Implement Session Storage with Cloudflare KV

## User Story

**As a** developer,
**I want** to store authentication sessions in Cloudflare KV,
**so that** sessions persist across requests and have automatic expiration.

## Acceptance Criteria

### Scenario 1: KV adapter configured
**Given** Auth.js is configured with GitHub provider
**When** I add the Cloudflare KV adapter
**Then** sessions are stored in Cloudflare KV
**And** the adapter uses the `BLOCKHAVEN_SESSIONS` namespace

### Scenario 2: Session created on login
**Given** a user successfully authenticates
**When** the OAuth callback completes
**Then** a session is created in Cloudflare KV
**And** the session includes userId and githubUsername
**And** the session has a 7-day TTL

### Scenario 3: Session validated on requests
**Given** a user has an active session
**When** they make a request to a protected route
**Then** the session is retrieved from KV
**And** the session is validated
**And** the request proceeds if valid

### Scenario 4: Session expires after 7 days
**Given** a session was created 7 days ago
**When** the user makes a request
**Then** the session is not found (KV TTL expired)
**And** the user must re-authenticate

### Scenario 5: Wrangler KV configuration
**Given** the project uses Cloudflare
**When** I check `wrangler.toml`
**Then** the KV namespace binding is configured
**And** local development uses KV simulation

## Business Value

**Why this matters:** Cloudflare KV provides globally distributed, low-latency session storage that integrates seamlessly with Cloudflare Workers. The 7-day TTL ensures sessions don't persist indefinitely.

**Impact:** Sessions work at the edge with automatic expiration, no database required.

**Success metric:** Sessions persist across page reloads and expire after 7 days.

## Technical Considerations

**KV Namespace Setup:**
```bash
# Create KV namespace
wrangler kv:namespace create BLOCKHAVEN_SESSIONS

# Add to wrangler.toml
[[kv_namespaces]]
binding = "BLOCKHAVEN_SESSIONS"
id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Session Configuration:**
```typescript
// src/lib/auth.ts
import { CloudflareKVAdapter } from "@auth/cloudflare-kv-adapter"

export const authConfig = {
  // ... providers
  adapter: CloudflareKVAdapter(env.BLOCKHAVEN_SESSIONS),
  session: {
    strategy: "jwt", // or "database" with KV
    maxAge: 7 * 24 * 60 * 60, // 7 days in seconds
  },
}
```

**Alternative: JWT Sessions**
If KV adapter has issues, fall back to JWT sessions:
```typescript
session: {
  strategy: "jwt",
  maxAge: 7 * 24 * 60 * 60,
}
```

**Constraints:**
- Cloudflare KV has eventual consistency (acceptable for sessions)
- KV TTL is minimum 60 seconds
- Must bind KV namespace in wrangler.toml

## Dependencies

**Depends on stories:** Story 01 (Auth.js), Story 02 (GitHub Provider)

**Enables stories:**
- Story 04: Login Page
- Story 06: Auth Middleware
- Story 07: Logout

## Out of Scope

- Session refresh/renewal (use re-auth after expiry)
- Multiple sessions per user (allowed by default)
- Session revocation UI (logout handles single session)

## Notes

- KV namespace must be created via Wrangler CLI or Cloudflare dashboard
- For local development, wrangler dev simulates KV
- Consider using JWT strategy if KV adapter has compatibility issues with Astro

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 06 (Middleware), Story 07 (Logout)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-03.md`
