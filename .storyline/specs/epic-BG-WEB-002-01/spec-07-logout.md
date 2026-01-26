---
spec_id: 07
story_ids: [07]
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Add Logout Functionality
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BG-WEB-002-01/story-07.md
created: 2026-01-25
---

# Technical Spec 07: Add Logout Functionality

## Overview

**User story:** [Story 07: Add Logout Functionality](../../stories/epic-BG-WEB-002-01/story-07.md)

**Goal:** Implement logout functionality that clears the user's session and redirects them to the homepage. The logout button is already in the dashboard header from Story 05; this spec ensures the signout endpoint works correctly and handles the redirect.

**Approach:** Auth.js provides the `/api/auth/signout` endpoint automatically. We need to ensure proper redirect configuration and verify the flow works end-to-end.

## Technical Design

### Logout Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  User clicks "Logout" button in dashboard header                 │
│  (Form POST to /api/auth/signout)                               │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│  Auth.js signout handler                                         │
│  ├── Validates CSRF token                                       │
│  ├── Clears session cookie                                      │
│  └── Redirects to configured URL (/ homepage)                   │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│  User lands on homepage (/)                                      │
│  ├── Session cookie cleared                                     │
│  └── No longer authenticated                                    │
└─────────────────────────────────────────────────────────────────┘
```

### Session Cookie Handling

- **Cookie name:** Set by Auth.js (typically `authjs.session-token` or `__Secure-authjs.session-token` in production)
- **Clear mechanism:** Auth.js sets cookie with immediate expiration
- **JWT invalidation:** Since we use JWT sessions, the cookie itself IS the session; clearing it logs the user out

## Implementation Details

### Files to Modify

#### 1. Update Auth Configuration (Redirect After Signout)

**`web/src/lib/auth.ts`** - Add redirect callback:

```typescript
// Add to authConfig.callbacks
callbacks: {
  // ... existing callbacks (signIn, jwt, session)

  /**
   * redirect callback - controls where users are sent after auth events.
   * Used to redirect to homepage after signout.
   */
  async redirect({ url, baseUrl }) {
    // After signout, redirect to homepage
    if (url.includes("/signout") || url.includes("signout")) {
      return baseUrl; // Returns to /
    }

    // For signin, redirect to dashboard
    if (url.includes("/callback") || url.includes("callback")) {
      return `${baseUrl}/dashboard`;
    }

    // Default: allow redirects to same origin only
    if (url.startsWith(baseUrl)) {
      return url;
    }

    return baseUrl;
  },
}
```

The complete updated `authConfig` should look like:

```typescript
export const authConfig: AuthConfig = {
  providers: [
    GitHub({
      clientId: import.meta.env.GITHUB_CLIENT_ID,
      clientSecret: import.meta.env.GITHUB_CLIENT_SECRET,
    }),
  ],

  session: {
    strategy: "jwt",
    maxAge: 7 * 24 * 60 * 60, // 7 days
  },

  callbacks: {
    async signIn({ profile }) {
      const authorizedUsers = getAuthorizedUsers();
      const githubUsername = (profile?.login as string)?.toLowerCase();
      if (!githubUsername) return false;
      return authorizedUsers.includes(githubUsername);
    },

    async jwt({ token, profile }) {
      if (profile) {
        token.githubUsername = (profile.login as string)?.toLowerCase();
      }
      return token;
    },

    async session({ session, token }) {
      if (token.githubUsername) {
        (session.user as any).githubUsername = token.githubUsername;
      }
      return session;
    },

    async redirect({ url, baseUrl }) {
      // After signout, redirect to homepage
      if (url.includes("signout")) {
        return baseUrl;
      }
      // After signin, redirect to dashboard
      if (url.includes("callback")) {
        return `${baseUrl}/dashboard`;
      }
      // Default: same origin only
      if (url.startsWith(baseUrl)) {
        return url;
      }
      return baseUrl;
    },
  },

  pages: {
    signIn: "/login",
    error: "/login",
  },

  trustHost: true,
};
```

### Logout Button (Already Implemented in Story 05)

The logout button in `DashboardLayout.astro` already exists:

```astro
<!-- Logout Button -->
<form action="/api/auth/signout" method="POST">
  <button
    type="submit"
    class="px-4 py-2 text-sm text-text-muted hover:text-accent-redstone transition-colors"
  >
    Logout
  </button>
</form>
```

**Why form POST instead of link:**
- CSRF protection (Auth.js validates the request)
- Prevents accidental logout via browser prefetch
- More secure than GET request

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Logout button visible | Already in DashboardLayout | Visual check |
| Click clears session | Auth.js signout clears cookie | Check browser DevTools |
| Redirects to homepage | `redirect` callback returns `baseUrl` | Click and verify URL |
| Dashboard inaccessible after logout | Middleware redirects to `/login` | Try `/dashboard` after logout |
| Works on mobile | Standard form submission | Test on mobile |

## Testing Requirements

### Manual Testing Checklist

**Basic Logout Flow:**
1. [ ] Sign in via GitHub
2. [ ] Navigate to `/dashboard`
3. [ ] Verify logout button is visible in header
4. [ ] Click logout button
5. [ ] Verify redirect to homepage (`/`)
6. [ ] Check browser DevTools → Cookies → Session cookie gone
7. [ ] Navigate to `/dashboard` → redirected to `/login`

**Session Verification:**
```bash
# Check session before logout
curl http://localhost:4321/api/auth/session -H "Cookie: ..."
# Should return user data

# After logout
curl http://localhost:4321/api/auth/session
# Should return {} (empty)
```

**Mobile Testing:**
- [ ] Test logout flow on iOS Safari
- [ ] Test logout flow on Android Chrome
- [ ] Button is touch-friendly (min 44px)

### Build Verification

```bash
npm run build
npm run preview
```

Test logout flow in production preview mode.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CSRF validation fails | Low | Medium | Use POST form (not GET link) |
| Redirect not working | Low | Low | Configure redirect callback |
| Cookie not clearing | Low | High | Verify in browser DevTools |

## Security Considerations

- **CSRF protection:** Form POST includes CSRF token from Auth.js
- **No GET logout:** Prevents browser prefetch from logging user out
- **Cookie cleared server-side:** Auth.js handles cookie expiration
- **JWT invalidation:** Clearing cookie is sufficient (no server state to clear)

## Success Verification

After implementation:

- [ ] Logout button click triggers POST to `/api/auth/signout`
- [ ] Session cookie is cleared
- [ ] User redirected to homepage
- [ ] Protected routes inaccessible after logout
- [ ] No errors in console during logout

## Traceability

**Parent story:** [Story 07: Add Logout Functionality](../../stories/epic-BG-WEB-002-01/story-07.md)

**Parent epic:** [Epic BG-WEB-002-01: Authentication](../../epics/epic-BG-WEB-002-01-authentication.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-07-logout.md`
