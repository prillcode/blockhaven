---
story_id: 01
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Install Auth.js with Astro Adapter
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 01: Install Auth.js with Astro Adapter

## User Story

**As a** developer,
**I want** to install and configure Auth.js with the Astro adapter,
**so that** we have the foundation for implementing GitHub OAuth authentication.

## Acceptance Criteria

### Scenario 1: Auth.js packages installed
**Given** the BlockHaven web project exists
**When** I install Auth.js packages
**Then** `@auth/core` is added to dependencies
**And** `auth-astro` is added to dependencies
**And** packages install without errors

### Scenario 2: Auth configuration file created
**Given** Auth.js packages are installed
**When** I create the auth configuration
**Then** `src/lib/auth.ts` exists with base Auth.js setup
**And** the configuration exports auth handlers

### Scenario 3: API route created for auth
**Given** the auth configuration exists
**When** I create the auth API route
**Then** `src/pages/api/auth/[...auth].ts` exists
**And** it exports GET and POST handlers from auth config

### Scenario 4: TypeScript types work
**Given** Auth.js is configured
**When** I run TypeScript compilation
**Then** there are no type errors related to Auth.js
**And** session types are properly inferred

## Business Value

**Why this matters:** Auth.js (NextAuth.js) is the de facto standard for authentication in modern web frameworks. Installing it correctly establishes the foundation for all authentication features.

**Impact:** Enables secure authentication without building custom auth from scratch.

**Success metric:** `npm run build` succeeds with Auth.js configured.

## Technical Considerations

**Potential approaches:**
- Use `auth-astro` package (recommended wrapper for Astro)
- Use `@auth/core` directly with custom integration

**Recommended approach:** Use `auth-astro` as it provides Astro-specific helpers and middleware integration.

**Constraints:**
- Must be compatible with Cloudflare Workers runtime
- Must support Cloudflare KV for session storage
- Must work with Astro's hybrid rendering mode

**Dependencies to install:**
```bash
npm install @auth/core auth-astro
```

## Dependencies

**Depends on stories:** None (first story)

**Enables stories:**
- Story 02: Configure GitHub OAuth Provider
- Story 03: Implement Session Storage

## Out of Scope

- GitHub OAuth configuration (Story 02)
- Cloudflare KV session storage (Story 03)
- Login page UI (Story 04)
- Route protection middleware (Story 06)

## Notes

- Auth.js v5 (beta) is the current version with Astro support
- The `auth-astro` package simplifies Astro integration
- Configuration will be extended in subsequent stories

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 02 (GitHub Provider), Story 03 (KV Sessions)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-01.md`
