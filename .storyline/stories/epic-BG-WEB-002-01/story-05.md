---
story_id: 05
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Create Protected Dashboard Route
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 05: Create Protected Dashboard Route

## User Story

**As an** authenticated admin,
**I want** to access a protected dashboard page,
**so that** I can see my authentication status and prepare for server management features.

## Acceptance Criteria

### Scenario 1: Dashboard shows user info
**Given** an authenticated user navigates to `/dashboard`
**When** the page loads
**Then** the user's GitHub avatar is displayed
**And** the user's GitHub username is displayed
**And** a logout button is visible in the header

### Scenario 2: Placeholder content displays
**Given** an authenticated user is on the dashboard
**When** they view the main content area
**Then** they see placeholder text: "Server controls coming soon"
**And** the layout is ready for future components

### Scenario 3: Unauthenticated access redirects
**Given** a user is NOT authenticated
**When** they navigate to `/dashboard`
**Then** they are redirected to `/login`

### Scenario 4: Mobile layout works
**Given** an authenticated user is on a mobile device
**When** they view the dashboard
**Then** the layout is responsive
**And** the header collapses appropriately
**And** content is readable without horizontal scroll

### Scenario 5: SSR renders correctly
**Given** the dashboard uses server-side rendering
**When** the page is requested
**Then** the session is checked server-side
**And** user data is available on initial render
**And** no client-side auth flicker occurs

## Business Value

**Why this matters:** The dashboard is the central hub for server management. This story establishes the protected route and user context that all other features will build upon.

**Impact:** Provides the authenticated framework for Epic 2-6 features.

**Success metric:** Authenticated users see their info; unauthenticated users are redirected.

## Technical Considerations

**Page Structure:**
```astro
---
// src/pages/dashboard.astro
export const prerender = false // SSR required

import { getSession } from "auth-astro/server"
import DashboardLayout from "../layouts/DashboardLayout.astro"

const session = await getSession(Astro.request)
if (!session) {
  return Astro.redirect("/login")
}

const { user } = session
---

<DashboardLayout title="Dashboard - BlockHaven Admin" user={user}>
  <header class="flex justify-between items-center p-4">
    <div class="flex items-center gap-3">
      <img src={user.image} alt="Avatar" class="w-10 h-10 rounded-full" />
      <span>{user.name}</span>
    </div>
    <a href="/api/auth/signout">Logout</a>
  </header>

  <main class="p-4">
    <h1>BlockHaven Server Dashboard</h1>
    <p>Server controls coming soon...</p>
    <!-- Future: ServerStatusCard, ServerControls, etc. -->
  </main>
</DashboardLayout>
```

**Dashboard Layout:**
- Create `DashboardLayout.astro` for consistent admin page structure
- Include user context in layout for header/nav
- Reserve space for sidebar navigation (future)

**SSR Configuration:**
- `export const prerender = false` ensures SSR
- Session check happens server-side before render
- No loading flash for auth state

## Dependencies

**Depends on stories:**
- Story 01: Auth.js Install
- Story 03: Session Storage
- Story 06: Auth Middleware

**Enables stories:**
- Story 07: Logout
- Epic 2: Server Status components
- Epic 3: Cost Estimation
- Epic 4: Logs Viewer
- Epic 5: Quick Actions

## Out of Scope

- Server status display (Epic 2)
- Server controls (Epic 2)
- Cost estimation (Epic 3)
- Logs viewer (Epic 4)
- Quick actions (Epic 5)

## Notes

- This creates the shell/frame for all dashboard features
- Use SSR (`prerender = false`) for authentication
- The DashboardLayout should be created to standardize admin pages
- Consider adding a simple sidebar for navigation between future sections

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 06 (Middleware), Story 07 (Logout)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-05.md`
