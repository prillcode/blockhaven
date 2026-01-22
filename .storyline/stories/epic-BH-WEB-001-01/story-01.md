---
story_id: 01
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Initialize Astro Project with Cloudflare Adapter
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 01: Initialize Astro Project with Cloudflare Adapter

## User Story

**As a** developer,
**I want** to initialize the Astro project with Cloudflare adapter and core dependencies,
**so that** we have a working foundation for building the BlockHaven marketing website with hybrid rendering capabilities.

## Acceptance Criteria

### Scenario 1: Project initialization succeeds
**Given** the `/web` directory exists (or will be created)
**When** I run `npm create astro@latest`
**Then** Astro 4.x is installed successfully
**And** the basic project structure is created
**And** `package.json` is created with Astro as a dependency

### Scenario 2: Cloudflare adapter installed
**Given** the Astro project is initialized
**When** I install `@astrojs/cloudflare` adapter
**Then** the adapter is added to dependencies
**And** I can import it in `astro.config.mjs`

### Scenario 3: Core dependencies installed
**Given** the project is initialized
**When** I install all required dependencies
**Then** `package.json` includes:
  - `astro` ^4.0.0
  - `@astrojs/cloudflare` ^11.0.0
  - `typescript` ^5.0.0
  - `@types/node` ^20.0.0
  - `wrangler` ^3.0.0
**And** `node_modules/` is populated

### Scenario 4: Basic Astro config with hybrid rendering
**Given** dependencies are installed
**When** I configure `astro.config.mjs`
**Then** the config exports `output: 'hybrid'`
**And** the config includes `adapter: cloudflare()`
**And** the dev server can start with `npm run dev`

### Scenario 5: Git setup
**Given** the project is initialized
**When** I initialize git (if not already a repo)
**Then** `.gitignore` includes:
  - `node_modules/`
  - `.env`
  - `dist/`
  - `.wrangler/`
  - `.DS_Store`

## Business Value

**Why this matters:** This is the foundational story that enables all other work on the website. Without proper initialization, no other features can be built.

**Impact:** Development team can begin building pages, components, and features. The hybrid rendering setup ensures we can serve static marketing pages (fast, SEO-friendly) while supporting future SSR requirements for the admin dashboard.

**Success metric:** `npm run dev` starts successfully and serves a basic Astro page at `http://localhost:4321`

## Technical Considerations

**Potential approaches:**
- Use `npm create astro@latest` interactive CLI
- Manual setup with `npm init` and package installation
- Use a custom Astro template/starter

**Recommended approach:** Use official Astro CLI for initialization, then manually configure Cloudflare adapter and hybrid rendering.

**Constraints:**
- Must use Astro 4.x (latest stable)
- Must use Cloudflare adapter (not Node, Vercel, or Netlify)
- Must configure hybrid rendering (not 'static' or 'server')
- Node.js 18+ required

**Data requirements:**
- No external data needed for this story
- Basic Astro configuration only

**Configuration specifics:**
```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  output: 'hybrid', // Static by default, SSR on demand
  adapter: cloudflare(),
});
```

## Dependencies

**Depends on stories:** None (this is the first story)

**Enables stories:**
- Story 02: Configure Tailwind (needs Astro project)
- Story 03: Setup TypeScript (needs Astro project)
- Story 04: Create directory structure (needs project root)

## Out of Scope

- Tailwind CSS installation (Story 02)
- TypeScript configuration beyond Astro defaults (Story 03)
- Creating actual pages or components (Epic 3)
- Environment variables setup (Story 05)
- Wrangler configuration beyond basic install (Story 05)
- README documentation (Story 07)

## Notes

- Astro 4.x includes built-in TypeScript support, but tsconfig.json customization is in Story 03
- Hybrid rendering is crucial: allows static pages (marketing) + SSR (future admin dashboard)
- Cloudflare adapter enables deployment to Cloudflare Pages with Workers
- This story focuses on "does it run?" - not "is it fully configured?"

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 02 (Tailwind), Story 03 (TypeScript), Story 05 (Environment)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-01.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-01.md`
