---
story_id: 06
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Create Placeholder Routes for Dashboard and API
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 06: Create Placeholder Routes for Dashboard and API

## User Story

**As a** developer,
**I want** placeholder routes for the future admin dashboard and API endpoints,
**so that** the architecture supports Phase 2 (admin features) from the start, and we verify that hybrid rendering and API routes work correctly with the Cloudflare adapter.

## Acceptance Criteria

### Scenario 1: Placeholder dashboard page created
**Given** the project structure is set up (Story 04 complete)
**When** I create `src/pages/dashboard.astro`
**Then** the file exists
**And** it displays a "Coming Soon" or "Admin Dashboard (Phase 2)" message
**And** it's configured for SSR: `export const prerender = false;`
**And** navigating to `/dashboard` shows the placeholder page

### Scenario 2: Dashboard page uses SSR
**Given** the dashboard page is created
**When** I check `dashboard.astro`
**Then** it includes `export const prerender = false;` (opt into SSR)
**And** the page is NOT pre-rendered at build time (stays dynamic)
**And** this verifies Cloudflare adapter's hybrid rendering works

### Scenario 3: API route structure created
**Given** the project structure is set up
**When** I create `src/pages/api/request-access.ts`
**Then** the file exists as a placeholder API endpoint
**And** it exports an API route handler (e.g., `POST` method)
**And** it returns a JSON response (e.g., `{ message: "API endpoint placeholder" }`)
**And** navigating to `/api/request-access` (POST) returns the placeholder response

### Scenario 4: API route works with hybrid rendering
**Given** the API route is created
**When** I test the `/api/request-access` endpoint
**Then** the endpoint responds correctly
**And** it runs on Cloudflare Workers runtime (not static)
**And** this verifies API routes work with the Cloudflare adapter

### Scenario 5: Routes are documented
**Given** placeholder routes are created
**When** I add comments or a README in `src/pages/`
**Then** it's clear that:
  - `/dashboard` is for Phase 2 (Admin Dashboard)
  - `/api/request-access` will be implemented in Epic 4
**And** future developers understand these are placeholders

## Business Value

**Why this matters:** Creating these routes early ensures the architecture supports future SSR features (admin dashboard, API endpoints) and validates that the Cloudflare adapter is configured correctly for hybrid rendering.

**Impact:** Development team can verify hybrid rendering works before building actual features. Phase 2 work (admin dashboard) has a clear starting point. API routes are tested and functional.

**Success metric:** `/dashboard` and `/api/request-access` are accessible locally, and the Cloudflare adapter successfully handles both static pages (future marketing pages) and dynamic routes.

## Technical Considerations

**Potential approaches:**
- Create minimal placeholder files
- Create full-featured "Coming Soon" pages with styling
- Skip placeholders and create routes when needed (not recommended - architecture risk)

**Recommended approach:** Create minimal placeholder files with clear comments explaining their purpose and future implementation.

**Constraints:**
- Dashboard page MUST use SSR (`export const prerender = false;`)
- API route MUST be a TypeScript file (`.ts`, not `.astro`)
- Routes must work with Cloudflare adapter's runtime

**Dashboard placeholder:**
```astro
---
// src/pages/dashboard.astro
// Phase 2: Admin Dashboard with GitHub OAuth + AWS SDK integration

export const prerender = false; // Enable SSR for this route
---

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard - Coming Soon</title>
</head>
<body class="bg-background-dark text-text-light p-8">
  <h1 class="text-4xl font-bold text-primary-grass">Admin Dashboard</h1>
  <p class="mt-4">Coming in Phase 2: GitHub OAuth, AWS SDK integration, server management.</p>
  <a href="/" class="mt-4 inline-block text-accent-diamond hover:underline">← Back to Home</a>
</body>
</html>
```

**API route placeholder:**
```typescript
// src/pages/api/request-access.ts
// Epic 4: Request Access Form - Email submission via Resend

import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  // TODO: Implement in Epic 4 (Request Form & API Integration)
  // - Parse form data
  // - Validate input
  // - Send email via Resend
  // - Return success/error response

  return new Response(
    JSON.stringify({
      message: "API endpoint placeholder - Implement in Epic 4"
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    }
  );
};
```

## Dependencies

**Depends on stories:**
- Story 01: Initialize Astro Project - Must have Astro with Cloudflare adapter
- Story 02: Configure Tailwind - Dashboard page can use Tailwind classes
- Story 04: Create directory structure - Routes go in src/pages/

**Enables stories:**
- Epic 4: Request Form & API Integration - API route will be fully implemented
- Phase 2: Admin Dashboard - Dashboard page will be built out

## Out of Scope

- Implementing actual dashboard features (Phase 2)
- Implementing form submission logic (Epic 4)
- Adding authentication/authorization (Phase 2)
- Styling dashboard page beyond basic layout
- Creating other API routes (only `/api/request-access` for now)

## Notes

- Astro's hybrid rendering mode means pages are static by default
- Use `export const prerender = false;` to opt specific pages into SSR
- API routes are ALWAYS SSR (never pre-rendered) by design
- Cloudflare adapter runs API routes as Cloudflare Workers (edge functions)
- Testing API routes locally: Use `curl` or Postman to send POST requests
- The dashboard route verifies SSR works; the API route verifies Workers integration works

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 01 (Astro init), Story 02 (Tailwind), Story 04 (Directory structure), Epic 4 (API implementation)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-06.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-06.md`
