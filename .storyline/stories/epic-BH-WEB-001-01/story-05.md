---
story_id: 05
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Configure Environment Variables and Wrangler
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 05: Configure Environment Variables and Wrangler

## User Story

**As a** developer,
**I want** environment variables properly configured with Wrangler for local Cloudflare Workers development,
**so that** I can develop and test API routes locally without deploying to production, and sensitive configuration is kept secure.

## Acceptance Criteria

### Scenario 1: .env.example file created
**Given** the Astro project is initialized
**When** I create `.env.example`
**Then** it includes all required environment variables:
  - `RESEND_API_KEY=your_resend_api_key_here`
  - `ADMIN_EMAIL=admin@example.com`
  - `MC_SERVER_IP=play.bhsmp.com`
  - `MC_SERVER_PORT=25565`
  - (Additional variables as needed)
**And** each variable has a descriptive comment explaining its purpose
**And** no actual secrets are in `.env.example` (only placeholder values)

### Scenario 2: .env file in .gitignore
**Given** `.gitignore` exists
**When** I check its contents
**Then** `.env` is listed (should already be there from Story 01)
**And** `.env.local` is listed
**And** `.env.production` is listed (if used)
**And** actual secrets are never committed to git

### Scenario 3: Wrangler configuration created
**Given** Wrangler is installed (from Story 01)
**When** I create `wrangler.toml` (or configure as needed)
**Then** Wrangler is configured for local development
**And** I can run `wrangler dev` to test Cloudflare Workers locally (optional)
**And** configuration matches Cloudflare Pages deployment settings (Epic 5)

### Scenario 4: Environment variables accessible in Astro
**Given** `.env` file exists with actual values (developer creates this locally)
**When** I access `import.meta.env.RESEND_API_KEY` in Astro code
**Then** the value is available at runtime
**And** TypeScript autocomplete works for env variables (if types configured)
**And** server-side code can read environment variables securely

### Scenario 5: Local development works with environment variables
**Given** environment variables are configured
**When** I run `npm run dev`
**Then** the dev server starts successfully
**And** API routes can access environment variables
**And** no warnings about missing environment variables appear

## Business Value

**Why this matters:** Proper environment variable management is critical for security (no hardcoded secrets), portability (different configs for dev/staging/prod), and team collaboration (everyone uses same variable names).

**Impact:** Developers can work locally without exposing production secrets. The team can switch between environments easily. Deployment to Cloudflare Pages (Epic 5) is straightforward because env vars are already configured.

**Success metric:** Developer can clone repo, copy `.env.example` to `.env`, add their keys, and start dev server without configuration issues.

## Technical Considerations

**Potential approaches:**
- Use Astro's built-in `.env` support (recommended)
- Use Wrangler's environment variable support for Cloudflare Workers
- Use both (for different contexts: build-time vs runtime)

**Recommended approach:** Use `.env` for local dev and Wrangler secrets for production (Epic 5).

**Constraints:**
- Environment variables must work in both:
  1. Astro dev server (`npm run dev`)
  2. Cloudflare Workers runtime (deployed)
- Sensitive variables (API keys) must NEVER be committed to git
- Must follow Cloudflare Pages environment variable conventions

**Data requirements:**
- Resend API key (for email sending - Epic 4)
- Admin email address (for form submissions - Epic 4)
- Minecraft server IP/port (for displaying on site)

**Environment variables needed:**
```bash
# .env.example

# Email service (Resend) - Get from https://resend.com/api-keys
RESEND_API_KEY=re_...

# Admin email for form submissions
ADMIN_EMAIL=admin@bhsmp.com

# Minecraft server connection details
MC_SERVER_IP=play.bhsmp.com
MC_SERVER_PORT=25565

# Optional: Discord webhook for notifications
DISCORD_WEBHOOK_URL=

# Optional: GitHub OAuth (Phase 2 - Admin Dashboard)
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
```

**Wrangler configuration:**
```toml
# wrangler.toml (optional for now, refined in Epic 5)
name = "blockhaven-web"
compatibility_date = "2024-01-01"

# Pages project (Cloudflare Pages)
pages_build_output_dir = "./dist"
```

## Dependencies

**Depends on stories:**
- Story 01: Initialize Astro Project - Must have project and Wrangler installed

**Enables stories:**
- Story 06: Create placeholder routes - API routes need env vars
- Epic 4: Request Form & API Integration - Uses RESEND_API_KEY and ADMIN_EMAIL
- Epic 5: Deployment & Production - Environment variables configured for Cloudflare Pages

## Out of Scope

- Setting up Cloudflare Pages environment variables (Epic 5)
- Implementing actual email sending logic (Epic 4)
- Configuring GitHub OAuth secrets (Phase 2)
- Setting up environment-specific configs (dev/staging/prod) beyond `.env.example`
- Creating TypeScript types for environment variables (can be added later)

## Notes

- Astro supports `.env` files natively via Vite
- Environment variables prefixed with `PUBLIC_` are available in client-side code (use sparingly)
- Server-side environment variables (no `PUBLIC_` prefix) are only accessible in `.astro` files and API routes
- Wrangler is primarily used for deployment (Epic 5) but installing it now ensures compatibility
- For Cloudflare Pages, environment variables are set in the Cloudflare dashboard (Epic 5)
- Consider adding a `docs/ENVIRONMENT.md` file explaining each variable's purpose (optional enhancement)

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 01 (Astro init), Story 06 (API routes), Epic 4 (Form & API), Epic 5 (Deployment)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-05.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-05.md`
