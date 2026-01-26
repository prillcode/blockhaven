---
spec_id: 04
story_ids: [04]
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Create Login Page with GitHub OAuth Button
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BG-WEB-002-01/story-04.md
created: 2026-01-25
---

# Technical Spec 04: Create Login Page with GitHub OAuth Button

## Overview

**User story:** [Story 04: Create Login Page](../../stories/epic-BG-WEB-002-01/story-04.md)

**Goal:** Create a login page at `/login` with BlockHaven branding and a "Sign in with GitHub" button. The page handles OAuth errors gracefully and redirects authenticated users to the dashboard.

**Approach:** Create an Astro page that checks for existing session (redirect if authenticated), displays error messages from URL parameters, and provides a clear call-to-action to sign in via GitHub OAuth.

## Technical Design

### Page Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     User navigates to /login                     │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │  Check for existing session  │
                    └─────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
              Has Session                 No Session
                    │                           │
                    ▼                           ▼
        ┌───────────────────┐     ┌───────────────────────────┐
        │ Redirect to       │     │ Check for error param     │
        │ /dashboard        │     │ (?error=AccessDenied)     │
        └───────────────────┘     └───────────────────────────┘
                                              │
                                              ▼
                                  ┌───────────────────────────┐
                                  │ Render login page:        │
                                  │ - BlockHaven branding     │
                                  │ - Error message (if any)  │
                                  │ - GitHub sign-in button   │
                                  └───────────────────────────┘
                                              │
                                              ▼
                                  ┌───────────────────────────┐
                                  │ User clicks GitHub button │
                                  │ → /api/auth/signin/github │
                                  └───────────────────────────┘
```

### Error Handling

| Error Code | Display Message |
|------------|-----------------|
| `AccessDenied` | "Access denied. Your GitHub account is not authorized." |
| `OAuthSignin` | "Could not start sign-in process. Please try again." |
| `OAuthCallback` | "Error during sign-in. Please try again." |
| `Default` | "An error occurred. Please try again." |

## Implementation Details

### Files to Create

#### 1. Login Page

**`web/src/pages/login.astro`**

```astro
---
// src/pages/login.astro
// Login page with GitHub OAuth sign-in
//
// Features:
// - Redirects authenticated users to /dashboard
// - Displays error messages from OAuth flow
// - Mobile-responsive design with Minecraft theme

export const prerender = false; // SSR required for session check

import { getSession } from "../lib/auth-helpers";
import BaseLayout from "../layouts/BaseLayout.astro";

// Check for existing session
const session = await getSession(Astro.request);
if (session) {
  return Astro.redirect("/dashboard");
}

// Get error from URL params
const error = Astro.url.searchParams.get("error");

// Map error codes to user-friendly messages
const errorMessages: Record<string, string> = {
  AccessDenied: "Access denied. Your GitHub account is not authorized to access the admin dashboard.",
  OAuthSignin: "Could not start the sign-in process. Please try again.",
  OAuthCallback: "An error occurred during sign-in. Please try again.",
  OAuthAccountNotLinked: "This account is already linked to another user.",
  Default: "An error occurred. Please try again.",
};

const errorMessage = error ? (errorMessages[error] || errorMessages.Default) : null;
---

<BaseLayout title="Login - BlockHaven Admin">
  <main class="min-h-screen flex items-center justify-center p-4 bg-bg-dark">
    <div class="w-full max-w-md">
      <!-- Login Card -->
      <div class="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-8 shadow-xl">
        <!-- Logo/Branding -->
        <div class="text-center mb-8">
          <img
            src="/blockhaven-icon-medium.png"
            alt="BlockHaven"
            class="w-20 h-20 mx-auto mb-4 rounded-lg"
          />
          <h1 class="text-2xl font-bold text-primary-gold">
            BlockHaven Admin
          </h1>
          <p class="text-text-muted mt-2">
            Server Management Dashboard
          </p>
        </div>

        <!-- Error Message -->
        {errorMessage && (
          <div class="mb-6 p-4 bg-accent-redstone/20 border border-accent-redstone/40 rounded-lg">
            <p class="text-accent-redstone text-sm">
              {errorMessage}
            </p>
          </div>
        )}

        <!-- Sign In Button -->
        <a
          href="/api/auth/signin/github"
          class="flex items-center justify-center gap-3 w-full px-6 py-4 bg-[#24292e] hover:bg-[#2f363d] text-white font-medium rounded-lg transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-accent-diamond focus:ring-offset-2 focus:ring-offset-bg-dark"
        >
          <!-- GitHub Icon -->
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.17 6.839 9.49.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.604-3.369-1.34-3.369-1.34-.454-1.156-1.11-1.463-1.11-1.463-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.831.092-.646.35-1.086.636-1.336-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.167 22 16.418 22 12c0-5.523-4.477-10-10-10z"/>
          </svg>
          <span>Sign in with GitHub</span>
        </a>

        <!-- Help Text -->
        <p class="mt-6 text-center text-sm text-text-muted">
          Only authorized administrators can access this dashboard.
        </p>
      </div>

      <!-- Back to Site Link -->
      <div class="mt-6 text-center">
        <a
          href="/"
          class="text-accent-diamond hover:text-primary-gold transition-colors text-sm"
        >
          &larr; Back to BlockHaven
        </a>
      </div>
    </div>
  </main>
</BaseLayout>
```

### Dependencies

**Requires from previous specs:**
- `src/lib/auth-helpers.ts` - `getSession()` function
- `src/layouts/BaseLayout.astro` - Base layout component
- Tailwind CSS with Minecraft theme colors

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Login page renders at /login | `pages/login.astro` created | Navigate to `/login` |
| Centered login card displayed | Flexbox centering with Tailwind | Visual check |
| BlockHaven branding visible | Logo image and styled heading | Visual check |
| GitHub sign-in button displayed | `<a>` to `/api/auth/signin/github` | Visual check |
| Button redirects to GitHub OAuth | href points to auth endpoint | Click test |
| Error message displays | Parse `?error=` param | Test with `?error=AccessDenied` |
| Mobile-friendly layout | Responsive Tailwind classes | Test at 320px width |
| Authenticated users redirected | Session check in frontmatter | Sign in, then visit `/login` |

## Testing Requirements

### Manual Testing Checklist

**Page Rendering:**
- [ ] Navigate to `/login` - page loads without errors
- [ ] BlockHaven logo displays
- [ ] "BlockHaven Admin" heading visible
- [ ] GitHub button styled correctly (dark gray background)
- [ ] "Back to BlockHaven" link visible

**Authentication Flow:**
- [ ] Click GitHub button - redirects to GitHub OAuth
- [ ] After successful auth - redirected to `/dashboard`
- [ ] After failed auth (unauthorized) - redirected to `/login?error=AccessDenied`
- [ ] Error message displays for AccessDenied

**Session Check:**
- [ ] When already logged in, visiting `/login` redirects to `/dashboard`

**Responsive Design:**
- [ ] Test at 320px width - no horizontal scroll
- [ ] Button is touch-friendly (min 44px height)
- [ ] Card is readable on mobile

**Error Handling:**
- [ ] `/login?error=AccessDenied` shows authorization error
- [ ] `/login?error=OAuthSignin` shows sign-in error
- [ ] `/login?error=Unknown` shows generic error

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; `/login` route listed as SSR.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Session check fails | Low | Medium | Fallback to showing login page |
| GitHub icon not rendering | Low | Low | Using inline SVG (no external deps) |
| Redirect loop if auth broken | Low | High | Session check has null fallback |

## Security Considerations

- **No credentials displayed:** Page only shows GitHub OAuth button
- **Error messages are generic:** Don't reveal which usernames are authorized
- **SSR required:** Session check must happen server-side
- **CSRF protection:** Auth.js handles CSRF for OAuth flow

## Success Verification

After implementation:

- [ ] `/login` page renders with BlockHaven branding
- [ ] GitHub button is prominent and clickable
- [ ] Error messages display appropriately
- [ ] Authenticated users cannot access login page
- [ ] Mobile layout is usable

## Traceability

**Parent story:** [Story 04: Create Login Page](../../stories/epic-BG-WEB-002-01/story-04.md)

**Parent epic:** [Epic BG-WEB-002-01: Authentication](../../epics/epic-BG-WEB-002-01-authentication.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-04-login-page.md`
