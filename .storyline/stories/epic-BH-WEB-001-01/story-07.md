---
story_id: 07
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Write Web Project Documentation
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 07: Write Web Project Documentation

## User Story

**As a** developer or future maintainer,
**I want** comprehensive README documentation for the web project,
**so that** I can understand the project setup, architecture, development workflow, and deployment process without needing to ask the original developers.

## Acceptance Criteria

### Scenario 1: README.md created in /web
**Given** the web project is set up
**When** I create `web/README.md`
**Then** the file exists in the `/web` directory (project root)
**And** it provides a clear overview of the BlockHaven marketing website

### Scenario 2: Project overview section
**Given** README is created
**When** I read the project overview section
**Then** it explains:
  - What the BlockHaven website is (invite-only Minecraft server marketing site)
  - Tech stack: Astro 4.x, Cloudflare adapter, Tailwind CSS, TypeScript
  - Architecture: Hybrid rendering (static marketing + SSR admin dashboard)
  - Purpose: Phase 1 (marketing) + Phase 2 (admin dashboard)

### Scenario 3: Getting started section
**Given** README is created
**When** I read the "Getting Started" section
**Then** it includes step-by-step setup instructions:
  1. Clone the repository
  2. Navigate to `/web` directory
  3. Copy `.env.example` to `.env` and add keys
  4. Run `npm install`
  5. Run `npm run dev`
  6. Open `http://localhost:4321`

### Scenario 4: Development commands documented
**Given** README is created
**When** I read the "Development Commands" section
**Then** it lists all npm scripts:
  - `npm run dev` - Start dev server
  - `npm run build` - Build for production
  - `npm run preview` - Preview production build locally
  - `npm run astro check` - Type check
  - (Any other scripts in package.json)

### Scenario 5: Project structure documented
**Given** README is created
**When** I read the "Project Structure" section
**Then** it explains the purpose of each directory:
  - `src/pages/` - File-based routing
  - `src/components/` - Reusable UI components
  - `src/layouts/` - Page layouts
  - `src/lib/` - Utilities, types, helpers
  - `src/content/` - Content Collections (markdown docs)
  - `src/styles/` - Global CSS, Tailwind
  - `public/` - Static assets

### Scenario 6: Architecture notes
**Given** README is created
**When** I read the "Architecture" section
**Then** it explains:
  - Hybrid rendering: static pages for marketing, SSR for admin routes
  - Cloudflare adapter: enables deployment to Cloudflare Pages + Workers
  - Tailwind + Minecraft theme: custom color palette for branding
  - Content auto-generation: markdown docs from `mc-server/docs/` (Epic 2)
  - Future admin dashboard: GitHub OAuth + AWS SDK (Phase 2)

### Scenario 7: Deployment information
**Given** README is created
**When** I read the "Deployment" section
**Then** it explains:
  - Deployed to Cloudflare Pages (Epic 5)
  - Environment variables set in Cloudflare dashboard
  - Automatic deployments on push to main branch
  - Wrangler CLI for manual deployments

### Scenario 8: Contributing guidelines
**Given** README is created
**When** I read the "Contributing" or "Development Workflow" section
**Then** it explains:
  - How to create feature branches
  - Code style conventions (TypeScript, Tailwind)
  - How to test changes locally
  - PR process (if applicable)

## Business Value

**Why this matters:** Good documentation reduces onboarding time for new developers, prevents knowledge silos, and ensures the project is maintainable long-term. Without documentation, future maintainers waste hours reverse-engineering the setup.

**Impact:** New developers can get up and running in under 10 minutes. Future maintainers understand architectural decisions. The project remains accessible even if original developers leave.

**Success metric:** A new developer with no context can clone the repo, follow the README, and have a running dev server within 10 minutes.

## Technical Considerations

**Potential approaches:**
- Minimal README (just setup instructions)
- Comprehensive README (recommended)
- Separate documentation site (overkill for this project)

**Recommended approach:** Comprehensive README with clear sections for setup, architecture, and deployment.

**Constraints:**
- README must be accurate (no outdated info)
- Must be updated as the project evolves (Epic 2-5)
- Should include examples where helpful

**README template structure:**
```markdown
# BlockHaven Marketing Website

Invite-only Minecraft server marketing site built with Astro, Cloudflare, and Tailwind CSS.

## Tech Stack
- Astro 4.x (hybrid rendering)
- Cloudflare Pages + Workers
- Tailwind CSS (Minecraft theme)
- TypeScript
- Resend (email)

## Getting Started
[Step-by-step instructions]

## Development Commands
[npm scripts]

## Project Structure
[Directory explanation]

## Architecture
[Hybrid rendering, Cloudflare adapter, content system]

## Deployment
[Cloudflare Pages deployment process]

## Environment Variables
[Link to .env.example]

## Contributing
[Development workflow]

## License
[If applicable]
```

## Dependencies

**Depends on stories:**
- Story 01-06: All foundation stories - README documents their output

**Enables stories:**
- All future epics - README is living documentation that evolves

## Out of Scope

- Creating separate documentation site (too early)
- Writing API documentation (Epic 4)
- Writing component library documentation (Epic 3)
- Creating detailed deployment runbooks (Epic 5 will add more details)
- Writing user-facing documentation (this is developer docs)

## Notes

- README should be updated incrementally as new features are added (Epic 2-5)
- Consider adding badges (build status, deployment status) in the future
- Keep README focused on developers; user-facing docs go elsewhere
- Screenshots or GIFs can help, but not required for MVP
- Link to relevant PRD documents (`.docs/ASTRO-SITE-PRD.md`) for deeper context

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 01-06 (all foundation stories)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-07.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-07.md`
