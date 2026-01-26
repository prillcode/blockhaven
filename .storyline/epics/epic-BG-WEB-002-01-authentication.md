# Epic 1: GitHub OAuth Authentication

**Epic ID:** BG-WEB-002-01
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md

---

## Business Goal

Implement secure authentication for the admin dashboard using GitHub OAuth, ensuring only authorized users (specified by GitHub username) can access server management features. This eliminates the need for custom password management while leveraging GitHub's robust OAuth infrastructure.

## User Value

**Who Benefits:** Authorized admins (configurable list of GitHub usernames)

**How They Benefit:**
- Secure access without managing separate credentials
- Familiar GitHub login flow
- Session persistence across devices (7-day TTL)
- Automatic session expiry for security
- Mobile-friendly authentication flow
- Easy to add/remove authorized users via environment variable

## Success Criteria

- [ ] GitHub OAuth flow works reliably (login → GitHub → callback → dashboard)
- [ ] Only users with GitHub usernames in `ADMIN_GITHUB_USERNAMES` can access `/dashboard`
- [ ] Unauthorized users see clear error message and cannot access protected routes
- [ ] Session persists across page reloads and browser restarts
- [ ] Logout button clears session and redirects to marketing site
- [ ] Session automatically expires after 7 days
- [ ] Mobile login flow works smoothly (no OAuth popup issues)
- [ ] Auth middleware protects all `/dashboard` and `/api/admin/*` routes

## Scope

### In Scope
- Auth.js installation and configuration with `@auth/astro` adapter
- GitHub OAuth application setup (documented)
- Cloudflare KV namespace for session storage
- Multi-user authorization via comma-separated username list
- `/login` page with "Sign in with GitHub" button
- `/dashboard` page (protected, placeholder UI)
- Auth middleware for route protection
- Session management (create, verify, delete)
- Logout functionality
- Error handling (unauthorized user, OAuth errors)
- Environment variables configuration
- Loading states during OAuth flow

### Out of Scope
- Role-based access control (all authorized users have same permissions)
- Refresh tokens (re-auth required after 7 days)
- Remember me functionality
- Social login options other than GitHub
- Password-based authentication
- User management UI (add/remove via env var only)
- Actual dashboard functionality (Epic 2+)

## Technical Notes

**Key Technologies:**
- Auth.js (NextAuth.js) v5 with Astro adapter
- GitHub OAuth 2.0
- Cloudflare KV for session storage
- Astro middleware for route protection

**Multi-User Authorization:**
```bash
# Environment variable - comma-separated list of authorized GitHub usernames
ADMIN_GITHUB_USERNAMES=prillcode,familymember1,familymember2
```

**Auth.js Configuration:**
```typescript
// src/auth.ts
import { Auth } from "@auth/core"
import GitHub from "@auth/core/providers/github"
import { CloudflareKVAdapter } from "@auth/cloudflare-kv-adapter"

// Parse comma-separated list of authorized usernames
const getAuthorizedUsers = (): string[] => {
  const usernames = import.meta.env.ADMIN_GITHUB_USERNAMES || ""
  return usernames.split(",").map(u => u.trim().toLowerCase()).filter(Boolean)
}

export const { GET, POST } = Auth({
  providers: [
    GitHub({
      clientId: import.meta.env.GITHUB_CLIENT_ID,
      clientSecret: import.meta.env.GITHUB_CLIENT_SECRET,
    }),
  ],
  adapter: CloudflareKVAdapter(KV_NAMESPACE),
  callbacks: {
    async signIn({ user, profile }) {
      // Check if GitHub username is in the authorized list
      const authorizedUsers = getAuthorizedUsers()
      const githubUsername = profile?.login?.toLowerCase()
      return githubUsername ? authorizedUsers.includes(githubUsername) : false
    },
  },
  session: {
    maxAge: 7 * 24 * 60 * 60, // 7 days
  },
})
```

**GitHub OAuth Application Settings:**
- Homepage URL: `https://bhsmp.com`
- Authorization callback URL: `https://bhsmp.com/api/auth/callback/github`

**Route Protection Middleware:**
```typescript
// src/middleware.ts
import { getSession } from "auth-astro/server"

export async function onRequest({ request, redirect }, next) {
  const url = new URL(request.url)

  // Protect /dashboard and /api/admin/* routes
  if (url.pathname.startsWith('/dashboard') || url.pathname.startsWith('/api/admin')) {
    const session = await getSession(request)
    if (!session) {
      return redirect('/login')
    }
  }

  return next()
}
```

**Session Storage (Cloudflare KV):**
- Namespace: `BLOCKHAVEN_SESSIONS`
- Key format: `session:{session_id}`
- TTL: 604800 seconds (7 days)
- Data: `{ userId, githubUsername, createdAt, expiresAt }`

## Dependencies

**Depends On:**
- BH-WEB-001 (Marketing website deployed with Cloudflare adapter)
- Cloudflare KV namespace provisioned
- GitHub OAuth application created

**Blocks:**
- Epic 2: Server Status & Controls
- Epic 3: Cost Estimation
- Epic 4: Server Logs Viewer
- Epic 5: Quick Actions Panel
- Epic 6: Polish & Security Audit

## Risks & Mitigations

**Risk:** Auth.js Astro adapter compatibility issues
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Use stable versions, fallback to manual OAuth implementation if needed

**Risk:** Cloudflare KV session storage latency
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** KV is fast (< 50ms globally), acceptable for auth flows

**Risk:** GitHub OAuth rate limits
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Small number of admin users means minimal OAuth calls

**Risk:** OAuth popup blocked on mobile
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Use redirect flow instead of popup for mobile

**Risk:** Typo in authorized usernames
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Clear error message showing attempted username, case-insensitive matching

## Acceptance Criteria

### GitHub OAuth Application
- [ ] OAuth app created at github.com/settings/developers
- [ ] Client ID and Secret stored in environment variables
- [ ] Callback URL configured correctly

### Auth.js Integration
- [ ] `@auth/astro` package installed and configured
- [ ] GitHub provider configured with credentials
- [ ] Cloudflare KV adapter configured for sessions
- [ ] `signIn` callback validates GitHub username against authorized list
- [ ] Username matching is case-insensitive

### Multi-User Authorization
- [ ] `ADMIN_GITHUB_USERNAMES` env var accepts comma-separated list
- [ ] Whitespace around usernames is trimmed
- [ ] Empty/invalid usernames are filtered out
- [ ] Adding new user requires only env var update and redeploy

### Login Page (`/login`)
- [ ] Clean, centered login UI matching site theme
- [ ] "Sign in with GitHub" button clearly visible
- [ ] Loading state during OAuth redirect
- [ ] Error message for unauthorized users (shows their GitHub username for debugging)
- [ ] Redirect to `/dashboard` after successful login
- [ ] Mobile-friendly layout

### Dashboard Route (`/dashboard`)
- [ ] Protected by auth middleware
- [ ] Redirects to `/login` if not authenticated
- [ ] Displays user's GitHub avatar and username
- [ ] Logout button in header
- [ ] Placeholder content: "Dashboard Coming Soon"

### API Auth Routes
- [ ] `GET/POST /api/auth/[...auth]` handles OAuth flow
- [ ] Session endpoint returns current user
- [ ] Logout endpoint clears session

### Middleware Protection
- [ ] All `/dashboard*` routes protected
- [ ] All `/api/admin/*` routes protected
- [ ] Marketing pages remain public
- [ ] `/api/request-access` remains public

### Session Management
- [ ] Session created on successful login
- [ ] Session stored in Cloudflare KV
- [ ] Session includes: userId, githubUsername, expiresAt
- [ ] Session verified on each protected request
- [ ] Session deleted on logout
- [ ] Session expires after 7 days

### Error Handling
- [ ] Graceful handling of OAuth failures
- [ ] Clear error message for unauthorized GitHub users
- [ ] Network error handling during OAuth flow
- [ ] Session expiry shows re-login prompt

### Environment Variables
```bash
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ADMIN_GITHUB_USERNAMES=prillcode,familymember1,familymember2  # Comma-separated list
AUTH_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # openssl rand -base64 32
```

### Directory Structure Additions
```
/web/src/
├── pages/
│   ├── login.astro           # GitHub OAuth login page
│   ├── dashboard.astro       # Protected admin dashboard
│   └── api/
│       └── auth/
│           └── [...auth].ts  # Auth.js API routes
├── middleware.ts             # Route protection middleware
└── lib/
    └── auth.ts               # Auth configuration and utilities
```

### Verification Checklist
- [ ] Login flow: `/login` → GitHub → callback → `/dashboard`
- [ ] Authorized user: can access dashboard
- [ ] Unauthorized user: shows error with their username, cannot access `/dashboard`
- [ ] Multiple authorized users: all can login independently
- [ ] Logout: clears session, redirects to `/`
- [ ] Session persistence: reload page, still logged in
- [ ] Session expiry: after 7 days, requires re-login
- [ ] Mobile: login flow works on iOS Safari and Android Chrome
- [ ] API protection: `/api/admin/*` returns 401 when not authenticated

## Related User Stories

From PRD:
- User Story 1: "As the admin, I want to log in with GitHub so only I can access the dashboard"
- User Story 6: "As the admin, I want to be automatically logged out after 7 days"

## Notes

- This epic establishes the security foundation for all admin features
- Auth.js (formerly NextAuth.js) is the de facto standard for auth in modern frameworks
- GitHub OAuth was chosen because admin already uses GitHub for code management
- Multiple admin users supported via comma-separated `ADMIN_GITHUB_USERNAMES` env var
- Adding/removing users requires environment variable update and redeploy
- Cloudflare KV is ideal for session storage due to edge deployment
- All authorized users have equal access (no role-based permissions)

---

**Next Epic:** Epic 2 - Server Status & Controls
