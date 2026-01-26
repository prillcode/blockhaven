---
spec_id: 06
story_ids: [06]
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Implement Auth Middleware for Protected Routes
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BG-WEB-002-01/story-06.md
created: 2026-01-25
---

# Technical Spec 06: Implement Auth Middleware for Protected Routes

## Overview

**User story:** [Story 06: Implement Auth Middleware](../../stories/epic-BG-WEB-002-01/story-06.md)

**Goal:** Create Astro middleware that automatically protects `/dashboard*` routes (redirect to login) and `/api/admin/*` routes (return 401 JSON) while allowing public routes to pass through without authentication checks.

**Approach:** Use Astro's `defineMiddleware` to create centralized auth protection. Check session server-side and handle pages vs API routes differently.

## Technical Design

### Route Protection Matrix

| Route Pattern | Auth Required | Unauthenticated Response |
|---------------|---------------|-------------------------|
| `/dashboard` | Yes | Redirect to `/login` |
| `/dashboard/*` | Yes | Redirect to `/login` |
| `/api/admin/*` | Yes | 401 JSON `{"error": "Unauthorized"}` |
| `/api/auth/*` | No | Pass through (Auth.js handles) |
| `/api/request-access` | No | Pass through (public form) |
| `/login` | No | Pass through |
| `/` | No | Pass through |
| `/worlds`, `/rules`, etc. | No | Pass through |

### Middleware Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      Incoming Request                            │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │   Extract pathname from URL  │
                    └─────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │  Is path protected?         │
                    │  (/dashboard* or /api/admin*)│
                    └─────────────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │ No                │ Yes               │
              │                   │                   │
              ▼                   ▼                   │
    ┌───────────────┐   ┌───────────────────┐        │
    │ return next() │   │ Get session       │        │
    │ (pass through)│   └───────────────────┘        │
    └───────────────┘             │                   │
                                  ▼                   │
                    ┌─────────────────────────────┐   │
                    │  Has valid session?         │   │
                    └─────────────────────────────┘   │
                                  │                   │
              ┌───────────────────┼───────────────────┘
              │ Yes               │ No
              │                   │
              ▼                   ▼
    ┌───────────────┐   ┌─────────────────────────────┐
    │ return next() │   │ Is it an API route?         │
    │ (authorized)  │   │ (/api/admin/*)              │
    └───────────────┘   └─────────────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │ Yes               │ No (page)         │
              │                   │                   │
              ▼                   ▼                   │
    ┌───────────────────┐   ┌───────────────────┐    │
    │ Return 401 JSON   │   │ Redirect to /login│    │
    │ Unauthorized      │   │                   │    │
    └───────────────────┘   └───────────────────┘    │
```

## Implementation Details

### Files to Create

#### 1. Auth Middleware

**`web/src/middleware.ts`**

```typescript
// src/middleware.ts
// Astro middleware for authentication and route protection
//
// Protects:
// - /dashboard* routes → redirect to /login
// - /api/admin/* routes → return 401 JSON
//
// Allows:
// - All other routes (public marketing pages)
// - /api/auth/* (Auth.js endpoints)
// - /api/request-access (public form submission)

import { defineMiddleware } from "astro:middleware";
import { getSession } from "./lib/auth-helpers";

/**
 * Routes that require authentication
 */
const PROTECTED_PAGE_PREFIXES = ["/dashboard"];
const PROTECTED_API_PREFIXES = ["/api/admin"];

/**
 * Check if a path starts with any of the given prefixes
 */
function startsWithAny(path: string, prefixes: string[]): boolean {
  return prefixes.some((prefix) => path === prefix || path.startsWith(prefix + "/"));
}

/**
 * Check if a path is an API route
 */
function isApiRoute(path: string): boolean {
  return path.startsWith("/api/");
}

export const onRequest = defineMiddleware(async (context, next) => {
  const { request, redirect } = context;
  const url = new URL(request.url);
  const path = url.pathname;

  // Check if this is a protected page route
  const isProtectedPage = startsWithAny(path, PROTECTED_PAGE_PREFIXES);

  // Check if this is a protected API route
  const isProtectedApi = startsWithAny(path, PROTECTED_API_PREFIXES);

  // If not a protected route, pass through
  if (!isProtectedPage && !isProtectedApi) {
    return next();
  }

  // Check for valid session
  const session = await getSession(request);

  if (!session || !session.user) {
    // No valid session - handle based on route type
    if (isProtectedApi) {
      // API routes return 401 JSON
      return new Response(
        JSON.stringify({
          error: "Unauthorized",
          message: "Authentication required to access this endpoint",
        }),
        {
          status: 401,
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
    } else {
      // Page routes redirect to login
      // Preserve the original URL for redirect after login (future enhancement)
      const loginUrl = new URL("/login", url.origin);
      return redirect(loginUrl.toString(), 302);
    }
  }

  // Session is valid, proceed with the request
  // Optionally, you can attach session to context.locals here
  // context.locals.session = session;

  return next();
});
```

#### 2. Middleware Types (optional but recommended)

**`web/src/env.d.ts`** (update existing or create)

```typescript
/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />

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
  }
}
```

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Dashboard routes protected | `PROTECTED_PAGE_PREFIXES` includes `/dashboard` | Test `/dashboard` unauthenticated |
| Admin API routes protected | `PROTECTED_API_PREFIXES` includes `/api/admin` | Test `/api/admin/test` unauthenticated |
| Public routes unaffected | Not in protected prefixes | Test `/`, `/worlds`, etc. |
| Unauthenticated pages redirect | `redirect("/login")` | Test `/dashboard` |
| Unauthenticated API returns 401 | Return 401 JSON | Test with curl |
| Authenticated requests proceed | `next()` called with valid session | Test after login |

## Testing Requirements

### Manual Testing Checklist

**Protected Page Routes (unauthenticated):**
- [ ] `/dashboard` → redirected to `/login`
- [ ] `/dashboard/anything` → redirected to `/login`

**Protected API Routes (unauthenticated):**
```bash
curl http://localhost:4321/api/admin/server/status
```
- [ ] Returns `{"error":"Unauthorized","message":"Authentication required..."}`
- [ ] Status code is 401

**Public Routes:**
- [ ] `/` loads normally
- [ ] `/worlds` loads normally
- [ ] `/login` loads normally
- [ ] `/api/auth/session` returns (handled by Auth.js)
- [ ] `/api/request-access` returns (public form endpoint)

**Protected Routes (authenticated):**
- [ ] Sign in via GitHub
- [ ] `/dashboard` loads with user info
- [ ] API routes return proper data (once implemented)

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; middleware is bundled with Worker.

### API Testing

```bash
# Test protected API route (unauthenticated)
curl -i http://localhost:4321/api/admin/server/status

# Expected response:
# HTTP/1.1 401 Unauthorized
# Content-Type: application/json
# {"error":"Unauthorized","message":"Authentication required to access this endpoint"}

# Test public route
curl -i http://localhost:4321/api/auth/session

# Expected: 200 OK with session data (or empty if not logged in)
```

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Middleware not running | Low | Critical | Verify file location is `src/middleware.ts` |
| Session check fails silently | Low | High | Log errors, default to unauthorized |
| Public routes accidentally protected | Low | Medium | Test all public routes after changes |
| Performance impact | Low | Low | Session check is fast (JWT decode) |

## Security Considerations

- **Fail closed:** If session check errors, user is treated as unauthenticated
- **No bypasses:** Middleware runs on all routes before handlers
- **API returns JSON:** No HTML error pages for API routes
- **Session validated server-side:** No client-side auth checks

## Performance Considerations

- **JWT sessions are fast:** No database lookup required
- **Early exit for public routes:** Skip session check entirely
- **Middleware is efficient:** Only runs necessary checks

## Success Verification

After implementation:

- [ ] Middleware file exists at `src/middleware.ts`
- [ ] All `/dashboard*` routes redirect when unauthenticated
- [ ] All `/api/admin/*` routes return 401 when unauthenticated
- [ ] Public routes work without session
- [ ] Authenticated users access protected routes
- [ ] No TypeScript errors in build

## Traceability

**Parent story:** [Story 06: Implement Auth Middleware](../../stories/epic-BG-WEB-002-01/story-06.md)

**Parent epic:** [Epic BG-WEB-002-01: Authentication](../../epics/epic-BG-WEB-002-01-authentication.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-06-auth-middleware.md`
