---
story_id: 06
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Implement Auth Middleware
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 06: Implement Auth Middleware

## User Story

**As a** developer,
**I want** auth middleware that protects dashboard and admin API routes,
**so that** unauthenticated requests are automatically redirected or rejected.

## Acceptance Criteria

### Scenario 1: Dashboard routes protected
**Given** the middleware is configured
**When** an unauthenticated user accesses any `/dashboard*` route
**Then** they are redirected to `/login`

### Scenario 2: Admin API routes protected
**Given** the middleware is configured
**When** an unauthenticated request is made to `/api/admin/*`
**Then** a 401 Unauthorized response is returned
**And** the response includes `{"error": "Unauthorized"}`

### Scenario 3: Public routes unaffected
**Given** the middleware is configured
**When** any user accesses marketing pages (`/`, `/worlds`, `/rules`, etc.)
**Then** the request proceeds normally
**And** no authentication check is performed

### Scenario 4: Public API routes unaffected
**Given** the middleware is configured
**When** any user accesses `/api/request-access`
**Then** the request proceeds normally
**And** no authentication check is performed

### Scenario 5: Authenticated requests proceed
**Given** a user has a valid session
**When** they access `/dashboard` or `/api/admin/*`
**Then** the request proceeds normally
**And** session data is available to the route

## Business Value

**Why this matters:** Middleware provides centralized auth protection, ensuring all protected routes are secured consistently without duplicating auth logic in every file.

**Impact:** Guarantees no protected route can be accidentally left unprotected.

**Success metric:** All `/dashboard*` and `/api/admin/*` routes require authentication.

## Technical Considerations

**Middleware Implementation:**
```typescript
// src/middleware.ts
import { defineMiddleware } from "astro:middleware"
import { getSession } from "auth-astro/server"

export const onRequest = defineMiddleware(async ({ request, redirect }, next) => {
  const url = new URL(request.url)
  const path = url.pathname

  // Routes that require authentication
  const protectedPaths = ['/dashboard', '/api/admin']
  const isProtected = protectedPaths.some(p => path.startsWith(p))

  if (isProtected) {
    const session = await getSession(request)

    if (!session) {
      // API routes return 401, pages redirect
      if (path.startsWith('/api/')) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 401,
          headers: { 'Content-Type': 'application/json' }
        })
      }
      return redirect('/login')
    }
  }

  return next()
})
```

**Path Matching:**
- `/dashboard` - exact and nested routes
- `/dashboard/*` - all dashboard sub-routes
- `/api/admin/*` - all admin API routes
- Exclude: `/`, `/worlds`, `/rules`, `/api/request-access`, etc.

**Constraints:**
- Middleware runs on every request (keep it fast)
- Session lookup adds latency (KV is fast, ~50ms)
- Must not block public routes

## Dependencies

**Depends on stories:**
- Story 01: Auth.js Install
- Story 03: Session Storage

**Enables stories:**
- Story 05: Dashboard Route
- Story 07: Logout
- All Epic 2-6 features

## Out of Scope

- Rate limiting (Epic 6)
- Audit logging (Epic 6)
- Role-based access control (not planned)

## Notes

- Astro middleware uses `defineMiddleware` helper
- The `getSession` function is provided by auth-astro
- Consider caching session in request context for routes that need it multiple times
- API routes should return JSON error, not redirect

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 05 (Dashboard), Epic 2-6 API routes

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-06.md`
