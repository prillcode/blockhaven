# Epic BG-WEB-002-01: Authentication - Technical Specs Index

## Overview

This epic implements GitHub OAuth authentication for the BlockHaven Admin Dashboard.

**Total Stories:** 7
**Total Specs:** 4 (some stories combined)

## Specs

| Spec | Stories | Title | Complexity | Status |
|------|---------|-------|------------|--------|
| [spec-01-02-03](spec-01-02-03-auth-foundation.md) | 01, 02, 03 | Auth.js Foundation with GitHub OAuth and JWT Sessions | Medium | Ready |
| [spec-04](spec-04-login-page.md) | 04 | Create Login Page with GitHub OAuth Button | Simple | Ready |
| [spec-05](spec-05-dashboard-route.md) | 05 | Create Protected Dashboard Route with User Info | Simple | Ready |
| [spec-06](spec-06-auth-middleware.md) | 06 | Implement Auth Middleware for Protected Routes | Simple | Ready |
| [spec-07](spec-07-logout.md) | 07 | Add Logout Functionality | Simple | Ready |

## Implementation Order

1. **spec-01-02-03** - Auth foundation (must be first)
2. **spec-06** - Middleware (protects routes)
3. **spec-04** - Login page (entry point)
4. **spec-05** - Dashboard (protected route)
5. **spec-07** - Logout (completes flow)

## Dependencies

```
spec-01-02-03 (Auth Foundation)
      │
      ├──► spec-06 (Middleware)
      │         │
      ├──► spec-04 (Login Page)
      │         │
      └──► spec-05 (Dashboard) ◄─── depends on middleware
                  │
                  └──► spec-07 (Logout)
```

## Key Files Created

| File | Purpose |
|------|---------|
| `src/lib/auth.ts` | Auth.js configuration |
| `src/lib/auth-helpers.ts` | Session helper functions |
| `src/pages/api/auth/[...auth].ts` | Auth.js API routes |
| `src/pages/login.astro` | Login page |
| `src/pages/dashboard.astro` | Protected dashboard |
| `src/layouts/DashboardLayout.astro` | Admin layout |
| `src/middleware.ts` | Route protection |

## Environment Variables Required

```bash
AUTH_SECRET=           # JWT signing secret (32+ chars)
GITHUB_CLIENT_ID=      # GitHub OAuth App Client ID
GITHUB_CLIENT_SECRET=  # GitHub OAuth App Client Secret
ADMIN_GITHUB_USERNAMES= # Comma-separated authorized usernames
AUTH_TRUST_HOST=true   # Required for Cloudflare
```

## To Execute All Specs

```bash
# In order:
/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-01-02-03-auth-foundation.md
/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-06-auth-middleware.md
/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-04-login-page.md
/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-05-dashboard-route.md
/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-07-logout.md
```
