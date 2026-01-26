---
story_id: 04
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Create Login Page
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 04: Create Login Page

## User Story

**As an** authorized admin,
**I want** to see a login page with a GitHub sign-in button,
**so that** I can authenticate to access the dashboard.

## Acceptance Criteria

### Scenario 1: Login page renders
**Given** a user navigates to `/login`
**When** the page loads
**Then** a centered login card is displayed
**And** the BlockHaven branding is visible
**And** a "Sign in with GitHub" button is prominently displayed

### Scenario 2: GitHub sign-in initiates
**Given** the login page is displayed
**When** the user clicks "Sign in with GitHub"
**Then** they are redirected to GitHub OAuth
**And** a loading state is shown during redirect

### Scenario 3: Successful login redirects to dashboard
**Given** a user completes GitHub OAuth
**And** their username is in the authorized list
**When** the callback completes
**Then** they are redirected to `/dashboard`

### Scenario 4: Unauthorized user sees error
**Given** a user completes GitHub OAuth
**And** their username is NOT in the authorized list
**When** the callback completes
**Then** they are redirected back to `/login`
**And** an error message displays: "Access denied. Your GitHub username (username) is not authorized."

### Scenario 5: Mobile-friendly layout
**Given** the user is on a mobile device
**When** they view the login page
**Then** the layout is responsive
**And** the sign-in button is touch-friendly (min 44x44px)
**And** no horizontal scrolling is required

### Scenario 6: Already authenticated redirect
**Given** a user already has a valid session
**When** they navigate to `/login`
**Then** they are redirected to `/dashboard`

## Business Value

**Why this matters:** The login page is the entry point for admin access. A clean, simple UI reduces friction and the GitHub OAuth button provides a familiar, trustworthy experience.

**Impact:** Authorized users can easily access the dashboard from any device.

**Success metric:** Users can complete login flow in under 10 seconds.

## Technical Considerations

**Page Structure:**
```astro
---
// src/pages/login.astro
import { getSession } from "auth-astro/server"
import BaseLayout from "../layouts/BaseLayout.astro"

const session = await getSession(Astro.request)
if (session) {
  return Astro.redirect("/dashboard")
}

const error = Astro.url.searchParams.get("error")
---

<BaseLayout title="Login - BlockHaven Admin">
  <div class="min-h-screen flex items-center justify-center">
    <div class="bg-secondary-darkGray p-8 rounded-lg max-w-md w-full">
      <h1>BlockHaven Admin</h1>
      {error && <div class="error">{error}</div>}
      <a href="/api/auth/signin/github" class="github-button">
        Sign in with GitHub
      </a>
    </div>
  </div>
</BaseLayout>
```

**Styling:**
- Use existing Tailwind Minecraft theme
- GitHub button with GitHub's brand colors (#24292e)
- Loading spinner during redirect
- Error messages in red with clear text

**Error Handling:**
- Display query param `?error=AccessDenied` as user-friendly message
- Show attempted username for debugging typos in env var

## Dependencies

**Depends on stories:**
- Story 01: Auth.js Install
- Story 02: GitHub Provider
- Story 03: Session Storage

**Enables stories:**
- Story 05: Dashboard Route
- Story 07: Logout

## Out of Scope

- Dashboard content (Story 05)
- Password-based login (not planned)
- "Remember me" checkbox (not needed with 7-day sessions)
- Multiple OAuth providers (GitHub only)

## Notes

- Use Astro's built-in redirect for authenticated users
- Error messages should help debug authorization issues (show username)
- The page should match the marketing site's visual style

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 05 (Dashboard), Story 07 (Logout)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-04.md`
