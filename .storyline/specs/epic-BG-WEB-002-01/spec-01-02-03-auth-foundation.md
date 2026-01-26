---
spec_id: 01-02-03
story_ids: [01, 02, 03]
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Auth.js Foundation with GitHub OAuth and JWT Sessions
status: ready_for_implementation
complexity: medium
parent_stories:
  - ../../stories/epic-BG-WEB-002-01/story-01.md
  - ../../stories/epic-BG-WEB-002-01/story-02.md
  - ../../stories/epic-BG-WEB-002-01/story-03.md
created: 2026-01-25
---

# Technical Spec: Auth.js Foundation with GitHub OAuth and JWT Sessions

## Overview

**User stories:**
- [Story 01: Install Auth.js with Astro Adapter](../../stories/epic-BG-WEB-002-01/story-01.md)
- [Story 02: Configure GitHub OAuth Provider](../../stories/epic-BG-WEB-002-01/story-02.md)
- [Story 03: Implement Session Storage with Cloudflare KV](../../stories/epic-BG-WEB-002-01/story-03.md)

**Goal:** Establish the complete authentication foundation for the admin dashboard using Auth.js with GitHub OAuth and JWT sessions (with 7-day expiration). This enables secure, passwordless authentication where only GitHub users in the `ADMIN_GITHUB_USERNAMES` environment variable can access the dashboard.

**Approach:** Install `auth-astro` (the official Auth.js adapter for Astro), configure GitHub OAuth provider with multi-user authorization callback, and use JWT session strategy (simpler than KV adapter for Cloudflare Workers compatibility). Sessions expire after 7 days.

## Technical Design

### Architecture Decision

**Chosen approach:** Auth.js with JWT sessions (not KV database sessions)

**Why JWT sessions instead of Cloudflare KV adapter:**
- **Cloudflare Workers compatibility:** JWT sessions work natively in edge runtime without additional adapters
- **Simpler setup:** No KV namespace binding required for sessions
- **Stateless:** Session data encoded in cookie, no database lookups needed
- **7-day expiration:** Built-in via `maxAge` configuration
- **Trade-off accepted:** Can't revoke individual sessions server-side (logout clears client cookie only)

**Alternatives considered:**
- **Cloudflare KV adapter for sessions** - More complex setup, potential compatibility issues with `auth-astro`, overkill for single-family server
- **Custom JWT implementation** - Reinventing the wheel; Auth.js handles this well
- **Lucia auth** - Good library but Auth.js has better Astro integration

### System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        Browser                                   │
│  ┌──────────────┐                                               │
│  │ Session Cookie│ ◄── JWT encoded, HttpOnly, 7-day expiry     │
│  └──────────────┘                                               │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                 Cloudflare Workers (Edge)                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Auth.js Handler (/api/auth/[...auth])                     │ │
│  │  ├── GET  /api/auth/signin/github  → Redirect to GitHub    │ │
│  │  ├── GET  /api/auth/callback/github → Handle OAuth callback│ │
│  │  ├── GET  /api/auth/session        → Return session JSON   │ │
│  │  └── POST /api/auth/signout        → Clear session cookie  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                             │                                    │
│                             ▼                                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  signIn Callback                                            │ │
│  │  ├── Extract GitHub username from profile.login             │ │
│  │  ├── Compare against ADMIN_GITHUB_USERNAMES (case-insensitive)│
│  │  └── Return true (allow) or false (deny)                    │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub OAuth                                │
│  ├── Client ID: GITHUB_CLIENT_ID                                │
│  ├── Client Secret: GITHUB_CLIENT_SECRET                        │
│  └── Callback: https://bhsmp.com/api/auth/callback/github       │
└─────────────────────────────────────────────────────────────────┘
```

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AUTH_SECRET` | Secret for signing JWTs (32+ chars) | `openssl rand -base64 32` |
| `GITHUB_CLIENT_ID` | GitHub OAuth App Client ID | `Iv1.abc123...` |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth App Client Secret | `abc123def456...` |
| `ADMIN_GITHUB_USERNAMES` | Comma-separated authorized usernames | `prillcode,familymember1` |
| `AUTH_TRUST_HOST` | Trust host header (required for Cloudflare) | `true` |

## Implementation Details

### Files to Create

#### 1. Auth Configuration

**`web/src/lib/auth.ts`**

```typescript
// src/lib/auth.ts
// Auth.js configuration for GitHub OAuth with multi-user authorization
//
// This module configures authentication using GitHub OAuth. Only users
// whose GitHub usernames are listed in ADMIN_GITHUB_USERNAMES can sign in.

import GitHub from "@auth/core/providers/github";
import type { AuthConfig } from "@auth/core/types";

/**
 * Parse comma-separated usernames from environment variable.
 * Handles whitespace, empty values, and normalizes to lowercase.
 */
function getAuthorizedUsers(): string[] {
  const usernames = import.meta.env.ADMIN_GITHUB_USERNAMES || "";
  return usernames
    .split(",")
    .map((u: string) => u.trim().toLowerCase())
    .filter(Boolean);
}

/**
 * Auth.js configuration
 */
export const authConfig: AuthConfig = {
  providers: [
    GitHub({
      clientId: import.meta.env.GITHUB_CLIENT_ID,
      clientSecret: import.meta.env.GITHUB_CLIENT_SECRET,
    }),
  ],

  session: {
    strategy: "jwt",
    maxAge: 7 * 24 * 60 * 60, // 7 days in seconds
  },

  callbacks: {
    /**
     * signIn callback - runs when user attempts to sign in.
     * Returns true to allow sign in, false to reject.
     */
    async signIn({ profile }) {
      const authorizedUsers = getAuthorizedUsers();
      const githubUsername = (profile?.login as string)?.toLowerCase();

      if (!githubUsername) {
        console.log("[Auth] Sign-in rejected: No GitHub username in profile");
        return false;
      }

      const isAuthorized = authorizedUsers.includes(githubUsername);
      console.log(
        `[Auth] Sign-in ${isAuthorized ? "allowed" : "rejected"} for: ${githubUsername}`
      );

      return isAuthorized;
    },

    /**
     * jwt callback - runs when JWT is created or updated.
     * Add GitHub username to token for later use.
     */
    async jwt({ token, profile }) {
      if (profile) {
        token.githubUsername = (profile.login as string)?.toLowerCase();
      }
      return token;
    },

    /**
     * session callback - runs when session is checked.
     * Add GitHub username to session for client access.
     */
    async session({ session, token }) {
      if (token.githubUsername) {
        (session.user as any).githubUsername = token.githubUsername;
      }
      return session;
    },
  },

  pages: {
    signIn: "/login",
    error: "/login", // Redirect to login page on error with ?error= param
  },

  // Trust the host header (required for Cloudflare Workers)
  trustHost: true,
};
```

#### 2. Auth API Route

**`web/src/pages/api/auth/[...auth].ts`**

```typescript
// src/pages/api/auth/[...auth].ts
// Auth.js catch-all API route handler
//
// This route handles all Auth.js endpoints:
// - GET  /api/auth/signin/github  - Initiates GitHub OAuth flow
// - GET  /api/auth/callback/github - Handles OAuth callback
// - GET  /api/auth/session - Returns current session
// - POST /api/auth/signout - Signs out user

import { Auth } from "@auth/core";
import type { APIRoute } from "astro";
import { authConfig } from "../../../lib/auth";

export const GET: APIRoute = async ({ request }) => {
  return Auth(request, authConfig);
};

export const POST: APIRoute = async ({ request }) => {
  return Auth(request, authConfig);
};
```

#### 3. Auth Helper Functions

**`web/src/lib/auth-helpers.ts`**

```typescript
// src/lib/auth-helpers.ts
// Helper functions for authentication in Astro pages and API routes

import { Auth } from "@auth/core";
import { authConfig } from "./auth";

/**
 * Get the current session from a request.
 * Use this in SSR pages and API routes to check authentication.
 *
 * @param request - The incoming HTTP request
 * @returns Session object or null if not authenticated
 */
export async function getSession(request: Request) {
  const sessionUrl = new URL("/api/auth/session", request.url);
  const sessionRequest = new Request(sessionUrl, {
    headers: request.headers,
  });

  const response = await Auth(sessionRequest, authConfig);
  const session = await response.json();

  // Auth.js returns {} for no session, not null
  if (!session || Object.keys(session).length === 0) {
    return null;
  }

  return session as {
    user: {
      name?: string;
      email?: string;
      image?: string;
      githubUsername?: string;
    };
    expires: string;
  };
}

/**
 * Check if a session is valid (exists and not expired).
 */
export function isSessionValid(session: Awaited<ReturnType<typeof getSession>>): boolean {
  if (!session) return false;
  const expires = new Date(session.expires);
  return expires > new Date();
}
```

### Files to Modify

#### 1. Update .env.example

**`web/.env.example`** - Add auth-related variables:

```bash
# ===================
# Marketing Site
# ===================
RESEND_API_KEY=re_xxxxxxxxxxxx
ADMIN_EMAIL=admin@bhsmp.com
MC_SERVER_IP=play.bhsmp.com

# ===================
# Admin Dashboard - Authentication
# ===================

# Auth.js secret for signing JWTs (generate: openssl rand -base64 32)
AUTH_SECRET=your-32-character-or-longer-secret-here

# GitHub OAuth (create at https://github.com/settings/developers)
# Homepage URL: https://bhsmp.com
# Callback URL: https://bhsmp.com/api/auth/callback/github
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Authorized GitHub usernames (comma-separated, case-insensitive)
# Only these users can sign in to the admin dashboard
ADMIN_GITHUB_USERNAMES=yourusername,familymember1,familymember2

# Required for Cloudflare Workers (trust host header)
AUTH_TRUST_HOST=true
```

#### 2. Install Dependencies

Add to `package.json` via npm:

```bash
npm install @auth/core
```

Note: We're using `@auth/core` directly with a custom Astro integration rather than `auth-astro` for better control and Cloudflare Workers compatibility.

### Type Definitions

**`web/src/types/auth.ts`**

```typescript
// src/types/auth.ts
// Type definitions for authentication

import type { Session } from "@auth/core/types";

/**
 * Extended session type with GitHub username
 */
export interface AdminSession extends Session {
  user: {
    name?: string | null;
    email?: string | null;
    image?: string | null;
    githubUsername?: string;
  };
}

/**
 * Environment variables for authentication
 */
export interface AuthEnv {
  AUTH_SECRET: string;
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
  ADMIN_GITHUB_USERNAMES: string;
  AUTH_TRUST_HOST?: string;
}
```

## Acceptance Criteria Mapping

### Story 01: Install Auth.js with Astro Adapter

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| `@auth/core` added to dependencies | `npm install @auth/core` | Check `package.json` |
| `src/lib/auth.ts` exists with base setup | Created with GitHub provider | File exists |
| API route exports GET/POST handlers | `[...auth].ts` created | File exports both |
| TypeScript types work | Strict mode enabled | `npm run build` succeeds |

### Story 02: Configure GitHub OAuth Provider

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| GitHub provider configured | In `authConfig.providers` | Check config |
| Reads GITHUB_CLIENT_ID | `import.meta.env.GITHUB_CLIENT_ID` | Check code |
| Reads GITHUB_CLIENT_SECRET | `import.meta.env.GITHUB_CLIENT_SECRET` | Check code |
| signIn callback checks username | `callbacks.signIn` implemented | Check code |
| Case-insensitive comparison | `.toLowerCase()` applied | Check code |
| Unauthorized user rejected | Returns `false` from callback | Test manually |
| .env.example updated | All vars documented | Check file |

### Story 03: Implement Session Storage

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| JWT strategy configured | `session.strategy: "jwt"` | Check config |
| 7-day TTL set | `maxAge: 7 * 24 * 60 * 60` | Check config |
| Session includes username | `jwt` and `session` callbacks | Check code |
| Session validated on requests | `getSession()` helper | Use in routes |

## Testing Requirements

### Manual Testing Checklist

**Setup (one-time):**
1. [ ] Create GitHub OAuth App at https://github.com/settings/developers
2. [ ] Set Homepage URL: `http://localhost:4321` (dev) or `https://bhsmp.com` (prod)
3. [ ] Set Callback URL: `http://localhost:4321/api/auth/callback/github`
4. [ ] Copy Client ID and Client Secret to `.env`
5. [ ] Set `AUTH_SECRET` (run `openssl rand -base64 32`)
6. [ ] Set `ADMIN_GITHUB_USERNAMES` with your GitHub username

**Authentication Flow Tests:**
1. [ ] Navigate to `/api/auth/signin/github` - redirects to GitHub
2. [ ] Authorize the app on GitHub - redirects back to callback
3. [ ] Callback succeeds for authorized username - session created
4. [ ] Navigate to `/api/auth/session` - returns session JSON with user info
5. [ ] Session includes `githubUsername` field
6. [ ] Navigate to `/api/auth/signout` (POST) - clears session
7. [ ] After signout, `/api/auth/session` returns empty object

**Authorization Tests:**
1. [ ] Sign in with authorized username - succeeds
2. [ ] Sign in with unauthorized username - redirected to `/login?error=AccessDenied`
3. [ ] Whitespace in ADMIN_GITHUB_USERNAMES is trimmed
4. [ ] Case difference (e.g., "PrillCode" vs "prillcode") still works

**Session Expiration Tests:**
1. [ ] Session cookie has 7-day expiration (check browser DevTools)
2. [ ] JWT `exp` claim is set to 7 days from creation

### Build Verification

```bash
cd web
npm run build
```

Expected: Build succeeds with no TypeScript errors related to auth.

### API Endpoint Testing

```bash
# Start dev server
npm run dev

# Test session endpoint (unauthenticated)
curl http://localhost:4321/api/auth/session
# Expected: {} (empty object)

# Test CSRF token endpoint
curl http://localhost:4321/api/auth/csrf
# Expected: {"csrfToken":"..."}

# Test providers endpoint
curl http://localhost:4321/api/auth/providers
# Expected: {"github":{...}}
```

## Dependencies

**Must complete first:**
- Project setup (Astro + TypeScript configured)
- Tailwind CSS (for login page in Story 04)

**Enables:**
- Story 04: Create Login Page
- Story 05: Protected Dashboard Route
- Story 06: Implement Auth Middleware
- Story 07: Add Logout Functionality

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Auth.js doesn't work in Cloudflare Workers | Low | High | Using JWT strategy (no external DB); tested in CF Workers |
| GitHub OAuth callback URL mismatch | Medium | High | Document exact callback URL format |
| Session not persisting across requests | Low | High | JWT stored in HttpOnly cookie; verify cookie settings |
| Environment variables not available | Low | High | Use `import.meta.env`; add to wrangler.toml |

## Security Considerations

**Session Security:**
- JWT signed with `AUTH_SECRET` (32+ characters required)
- Cookie flags: `HttpOnly`, `Secure` (in production), `SameSite=Lax`
- 7-day expiration limits exposure window

**Authorization:**
- Username check happens server-side in callback
- Unauthorized users never receive a session
- GitHub username cannot be spoofed (comes from OAuth profile)

**Secrets Management:**
- All secrets in environment variables (never in code)
- `.env` in `.gitignore`
- Production secrets set via Cloudflare dashboard

## GitHub OAuth App Setup Instructions

**For Development:**
1. Go to https://github.com/settings/developers
2. Click "New OAuth App"
3. Application name: `BlockHaven Admin (Dev)`
4. Homepage URL: `http://localhost:4321`
5. Authorization callback URL: `http://localhost:4321/api/auth/callback/github`
6. Click "Register application"
7. Copy Client ID to `.env` as `GITHUB_CLIENT_ID`
8. Generate a Client Secret and copy to `.env` as `GITHUB_CLIENT_SECRET`

**For Production:**
1. Create a separate OAuth App for production
2. Application name: `BlockHaven Admin`
3. Homepage URL: `https://bhsmp.com`
4. Authorization callback URL: `https://bhsmp.com/api/auth/callback/github`
5. Set secrets in Cloudflare Pages environment variables

## Success Verification

After implementation, verify:

- [ ] `npm install` completes without errors
- [ ] `npm run build` completes without TypeScript errors
- [ ] `/api/auth/providers` returns GitHub provider info
- [ ] `/api/auth/signin/github` redirects to GitHub
- [ ] After GitHub auth, session contains user info with `githubUsername`
- [ ] Unauthorized username cannot sign in
- [ ] Session persists across page refreshes
- [ ] Session cookie expires after 7 days

## Traceability

**Parent stories:**
- [Story 01](../../stories/epic-BG-WEB-002-01/story-01.md)
- [Story 02](../../stories/epic-BG-WEB-002-01/story-02.md)
- [Story 03](../../stories/epic-BG-WEB-002-01/story-03.md)

**Parent epic:** [Epic BG-WEB-002-01: Authentication](../../epics/epic-BG-WEB-002-01-authentication.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-01-02-03-auth-foundation.md`
