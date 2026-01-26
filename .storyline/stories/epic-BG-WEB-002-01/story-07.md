---
story_id: 07
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Add Logout Functionality
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 07: Add Logout Functionality

## User Story

**As an** authenticated admin,
**I want** to be able to log out of the dashboard,
**so that** my session is ended and I can secure my access.

## Acceptance Criteria

### Scenario 1: Logout button visible
**Given** an authenticated user is on the dashboard
**When** they view the header
**Then** a logout button/link is visible

### Scenario 2: Logout clears session
**Given** an authenticated user clicks logout
**When** the logout process completes
**Then** their session is removed from Cloudflare KV
**And** their browser session cookie is cleared

### Scenario 3: Logout redirects to home
**Given** an authenticated user logs out
**When** the logout completes
**Then** they are redirected to the marketing homepage (`/`)
**And** they see a brief "Logged out" message (optional)

### Scenario 4: After logout, dashboard inaccessible
**Given** a user has logged out
**When** they try to navigate to `/dashboard`
**Then** they are redirected to `/login`

### Scenario 5: Logout works on mobile
**Given** an authenticated user is on a mobile device
**When** they tap the logout button
**Then** the logout process works correctly
**And** they are redirected to the homepage

## Business Value

**Why this matters:** Logout functionality is essential for security. Users need to be able to end their session, especially on shared or public devices.

**Impact:** Users can secure their access when finished using the dashboard.

**Success metric:** Logged out users cannot access protected routes without re-authenticating.

## Technical Considerations

**Logout Flow:**
1. User clicks logout button
2. Request to `/api/auth/signout`
3. Auth.js clears session from KV
4. Session cookie cleared
5. Redirect to `/`

**Implementation:**
```astro
<!-- In dashboard header -->
<form action="/api/auth/signout" method="POST">
  <button type="submit" class="logout-button">
    Logout
  </button>
</form>
```

Or with link:
```astro
<a href="/api/auth/signout">Logout</a>
```

**Auth.js Signout:**
- Auth.js provides `/api/auth/signout` endpoint
- Handles session cleanup automatically
- Can configure redirect URL in auth config

**Redirect Configuration:**
```typescript
// In auth config
callbacks: {
  async redirect({ url, baseUrl }) {
    // After signout, redirect to home
    if (url.includes('signout')) {
      return baseUrl // Returns to /
    }
    return url
  }
}
```

## Dependencies

**Depends on stories:**
- Story 01: Auth.js Install
- Story 03: Session Storage
- Story 05: Dashboard Route

**Enables stories:** None (completes authentication epic)

## Out of Scope

- "Log out all devices" functionality
- Session management UI (view active sessions)
- Logout confirmation dialog (simple action)

## Notes

- Auth.js handles the signout endpoint automatically
- Session is removed from KV (or JWT is cleared)
- Consider CSRF protection on logout (use POST form, not GET link)
- Mobile logout should work identically to desktop

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 04 (Login), Story 05 (Dashboard)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-07.md`
