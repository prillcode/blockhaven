---
spec_id: 05
story_ids: [05]
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Create Protected Dashboard Route with User Info
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BG-WEB-002-01/story-05.md
created: 2026-01-25
---

# Technical Spec 05: Create Protected Dashboard Route with User Info

## Overview

**User story:** [Story 05: Create Protected Dashboard Route](../../stories/epic-BG-WEB-002-01/story-05.md)

**Goal:** Create the authenticated dashboard page at `/dashboard` that displays user info (GitHub avatar, username) and provides the shell/layout for future server management features. Unauthenticated users are redirected to `/login`.

**Approach:** Create an SSR-enabled Astro page that checks session server-side, creates a `DashboardLayout` component for consistent admin page structure, and displays authenticated user information with a logout button.

## Technical Design

### Page Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                         Dashboard Header                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  [Logo] BlockHaven Admin              [Avatar] user  [Logout]│
│  └──────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│                         Main Content                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                                                          │   │
│  │    "Server controls coming soon..."                      │   │
│  │                                                          │   │
│  │    (Placeholder for Epic 2-5 components)                 │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Component Hierarchy

```
/dashboard (page)
├── DashboardLayout
│   ├── DashboardHeader
│   │   ├── Logo
│   │   ├── User Info (avatar + name)
│   │   └── Logout Button
│   └── Main Content Slot
│       └── Placeholder Content
```

## Implementation Details

### Files to Create

#### 1. Dashboard Layout

**`web/src/layouts/DashboardLayout.astro`**

```astro
---
// src/layouts/DashboardLayout.astro
// Layout component for all admin dashboard pages
//
// Provides consistent header with user info, logout button,
// and main content area for dashboard features.

interface Props {
  title: string;
  user: {
    name?: string | null;
    email?: string | null;
    image?: string | null;
    githubUsername?: string;
  };
}

const { title, user } = Astro.props;
---

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title}</title>
  <link rel="icon" type="image/png" href="/server-icon.png">
</head>
<body class="bg-bg-dark text-text-light min-h-screen">
  <!-- Header -->
  <header class="bg-secondary-stone/20 border-b border-secondary-stone/30">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <!-- Logo & Title -->
        <div class="flex items-center gap-3">
          <a href="/dashboard" class="flex items-center gap-3">
            <img
              src="/server-icon.png"
              alt="BlockHaven"
              class="w-8 h-8 rounded"
            />
            <span class="font-semibold text-primary-gold hidden sm:block">
              BlockHaven Admin
            </span>
          </a>
        </div>

        <!-- User Info & Logout -->
        <div class="flex items-center gap-4">
          <!-- User Info -->
          <div class="flex items-center gap-3">
            {user.image && (
              <img
                src={user.image}
                alt={user.name || "User avatar"}
                class="w-8 h-8 rounded-full border border-secondary-stone/50"
              />
            )}
            <span class="text-sm text-text-light hidden sm:block">
              {user.githubUsername || user.name || "Admin"}
            </span>
          </div>

          <!-- Logout Button -->
          <form action="/api/auth/signout" method="POST">
            <button
              type="submit"
              class="px-4 py-2 text-sm text-text-muted hover:text-accent-redstone transition-colors"
            >
              Logout
            </button>
          </form>
        </div>
      </div>
    </div>
  </header>

  <!-- Main Content -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <slot />
  </main>
</body>
</html>

<style is:global>
  /* Import Tailwind */
  @import "../styles/global.css";
</style>
```

#### 2. Dashboard Page

**`web/src/pages/dashboard.astro`** (replace existing placeholder)

```astro
---
// src/pages/dashboard.astro
// Protected admin dashboard page
//
// Features:
// - Server-side session check (redirects to /login if not authenticated)
// - Displays user info from GitHub OAuth
// - Placeholder content for future server management features (Epic 2-6)

export const prerender = false; // SSR required for authentication

import { getSession } from "../lib/auth-helpers";
import DashboardLayout from "../layouts/DashboardLayout.astro";

// Check authentication
const session = await getSession(Astro.request);

if (!session || !session.user) {
  return Astro.redirect("/login");
}

const { user } = session;
---

<DashboardLayout title="Dashboard - BlockHaven Admin" user={user}>
  <!-- Page Header -->
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-primary-gold">
      Server Dashboard
    </h1>
    <p class="text-text-muted mt-2">
      Manage your Minecraft server from anywhere
    </p>
  </div>

  <!-- Placeholder Content Grid -->
  <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    <!-- Server Status Placeholder -->
    <div class="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 class="text-lg font-semibold text-text-light mb-4">
        Server Status
      </h2>
      <p class="text-text-muted text-sm">
        Coming in Epic 2: Real-time server status, player count, and uptime monitoring.
      </p>
    </div>

    <!-- Server Controls Placeholder -->
    <div class="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 class="text-lg font-semibold text-text-light mb-4">
        Server Controls
      </h2>
      <p class="text-text-muted text-sm">
        Coming in Epic 2: Start and stop your Minecraft server with one click.
      </p>
    </div>

    <!-- Cost Estimation Placeholder -->
    <div class="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 class="text-lg font-semibold text-text-light mb-4">
        Cost Estimation
      </h2>
      <p class="text-text-muted text-sm">
        Coming in Epic 3: Track estimated monthly costs based on server uptime.
      </p>
    </div>

    <!-- Logs Viewer Placeholder -->
    <div class="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 class="text-lg font-semibold text-text-light mb-4">
        Server Logs
      </h2>
      <p class="text-text-muted text-sm">
        Coming in Epic 4: View Minecraft server logs in real-time.
      </p>
    </div>

    <!-- Quick Actions Placeholder -->
    <div class="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 class="text-lg font-semibold text-text-light mb-4">
        Quick Actions
      </h2>
      <p class="text-text-muted text-sm">
        Coming in Epic 5: Manage whitelist and execute server commands.
      </p>
    </div>
  </div>

  <!-- Welcome Message for New Users -->
  <div class="mt-8 p-6 bg-accent-diamond/10 border border-accent-diamond/30 rounded-lg">
    <h3 class="text-lg font-semibold text-accent-diamond mb-2">
      Welcome, {user.githubUsername || user.name}!
    </h3>
    <p class="text-text-muted text-sm">
      The admin dashboard is being built in phases. Authentication is complete -
      server controls and monitoring features are coming soon.
    </p>
  </div>
</DashboardLayout>
```

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Dashboard shows user info | Session user data displayed | Sign in and check |
| GitHub avatar displayed | `<img src={user.image}>` | Visual check |
| GitHub username displayed | `user.githubUsername` shown | Visual check |
| Logout button visible | Form with POST to signout | Visual check |
| Placeholder content displays | "Coming soon" cards | Visual check |
| Unauthenticated redirected | Session check + redirect | Try without session |
| Mobile layout works | Responsive Tailwind | Test at 320px |
| SSR renders correctly | `prerender = false` | Check build output |

## Testing Requirements

### Manual Testing Checklist

**Authentication:**
- [ ] Visit `/dashboard` when not logged in - redirected to `/login`
- [ ] Sign in via GitHub - redirected to `/dashboard`
- [ ] Dashboard shows GitHub avatar (from OAuth)
- [ ] Dashboard shows GitHub username

**User Interface:**
- [ ] Header displays "BlockHaven Admin" with logo
- [ ] Logout button visible in header
- [ ] Placeholder cards for each future feature
- [ ] Welcome message shows username

**Responsive Design:**
- [ ] Desktop: Full header with all elements visible
- [ ] Tablet: Content adjusts to 2 columns
- [ ] Mobile (320px): Single column, username hidden, avatar visible
- [ ] No horizontal scroll on mobile

**Logout Flow:**
- [ ] Click logout button
- [ ] Redirected to homepage or login page
- [ ] Revisiting `/dashboard` redirects to `/login`

### Build Verification

```bash
npm run build
```

Expected:
- Build succeeds
- `/dashboard` listed as SSR route (not pre-rendered)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| User image missing | Low | Low | Show username/initials fallback |
| Session check fails | Low | High | Redirect to login on any error |
| Layout breaks on mobile | Low | Medium | Test responsive breakpoints |

## Security Considerations

- **Server-side auth check:** Session verified before rendering
- **No sensitive data in HTML:** Only user info from OAuth (public)
- **Logout uses POST:** CSRF-safe form submission
- **SSR ensures no flash:** User never sees protected content if unauthenticated

## Success Verification

After implementation:

- [ ] Unauthenticated users redirected to `/login`
- [ ] Authenticated users see dashboard with their info
- [ ] GitHub avatar and username display correctly
- [ ] Logout button works
- [ ] Layout is responsive
- [ ] Placeholder cards provide context for future features

## Traceability

**Parent story:** [Story 05: Create Protected Dashboard Route](../../stories/epic-BG-WEB-002-01/story-05.md)

**Parent epic:** [Epic BG-WEB-002-01: Authentication](../../epics/epic-BG-WEB-002-01-authentication.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-01/spec-05-dashboard-route.md`
