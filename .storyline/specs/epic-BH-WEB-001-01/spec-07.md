---
spec_id: 07
story_ids: [07]
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Write Web Project Documentation
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BH-WEB-001-01/story-07.md
created: 2026-01-22
---

# Technical Spec 07: Write Web Project Documentation

## Overview

**User story:** [Story 07: Write Web Project Documentation](../../stories/epic-BH-WEB-001-01/story-07.md)

**Goal:** Create a comprehensive README.md in `/web` that documents project setup, architecture, development workflow, deployment process, and code organization, enabling new developers to get up and running within 10 minutes.

**Approach:** Write a single README.md file with 8 major sections: Project Overview, Tech Stack, Getting Started, Development Commands, Project Structure, Architecture, Deployment, and Contributing. Use clear headings, code blocks for commands, and inline comments for clarity. Document the current state (post-Epic 1) while noting future additions (Epic 2-5, Phase 2).

## Technical Design

### Architecture Decision

**Chosen approach:** Single comprehensive README.md in `/web` directory

**Why this approach:**
- **Single source of truth:** All essential information in one file, easy to find
- **GitHub-friendly:** Displays automatically on GitHub repository page
- **Searchable:** Developers can Ctrl+F to find specific topics
- **Version-controlled:** Changes tracked in git, evolves with codebase

**Alternatives considered:**
- **Separate documentation site (e.g., Docusaurus)** - Overkill for a small project; maintenance overhead
- **Wiki or external docs** - Risk of becoming outdated; not version-controlled with code
- **Minimal README with external links** - Fragmented information; poor developer experience

**Rationale:** A well-structured README provides immediate value without additional tooling or infrastructure.

### System Components

**Documentation File:**
- Location: `web/README.md`
- Format: GitHub-flavored Markdown
- Sections: 8 major sections (see below)

**Content Strategy:**
- **Onboarding-first:** Prioritize "Getting Started" early
- **Reference-second:** Architecture and structure details follow
- **Future-aware:** Note planned features (Epic 2-5, Phase 2) without over-promising

## Implementation Details

### Files to Create

#### web/README.md

**Purpose:** Comprehensive developer documentation for the BlockHaven web project

**Sections:**
1. **Header & Overview** - What this project is
2. **Tech Stack** - Technologies used
3. **Getting Started** - Step-by-step setup
4. **Development Commands** - npm scripts reference
5. **Project Structure** - Directory organization
6. **Architecture** - Hybrid rendering, Cloudflare, design decisions
7. **Environment Variables** - Link to `.env.example`
8. **Deployment** - Cloudflare Pages deployment (Epic 5 adds details)
9. **Contributing** - Development workflow and conventions

**Full implementation:**

````markdown
# BlockHaven Marketing Website

Official marketing website for the BlockHaven Minecraft server (invite-only SMP at `play.bhsmp.com`).

Built with Astro 4.x, Cloudflare Pages, and Tailwind CSS with a custom Minecraft-themed color palette.

## Tech Stack

- **[Astro 4.x](https://astro.build/)** - Modern web framework with hybrid rendering
- **[Cloudflare Pages](https://pages.cloudflare.com/)** - Deployment platform with edge Workers
- **[Tailwind CSS 3.x](https://tailwindcss.com/)** - Utility-first CSS with custom Minecraft theme
- **[TypeScript 5.x](https://www.typescriptlang.org/)** - Type-safe JavaScript
- **[Resend](https://resend.com/)** - Transactional email service (Epic 4)
- **[Wrangler 3.x](https://developers.cloudflare.com/workers/wrangler/)** - Cloudflare Workers CLI

## Getting Started

### Prerequisites

- **Node.js 18+** (check with `node -v`)
- **npm** or **pnpm** package manager
- **Git** (project is version-controlled)

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/blockhaven.git
   cd blockhaven/web
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and add your API keys (see [Environment Variables](#environment-variables) section below).

4. **Start the development server:**
   ```bash
   npm run dev
   ```

5. **Open your browser:**
   Navigate to [http://localhost:4321](http://localhost:4321)

You should see the BlockHaven homepage! 🎮

## Development Commands

All commands are run from the `/web` directory:

| Command                | Action                                           |
|:-----------------------|:-------------------------------------------------|
| `npm install`          | Install dependencies                             |
| `npm run dev`          | Start dev server at `localhost:4321`             |
| `npm run build`        | Build production site to `./dist/`               |
| `npm run preview`      | Preview production build locally                 |
| `npm run astro`        | Run Astro CLI commands                           |
| `npm run astro check`  | Type-check the project (TypeScript)              |

## Project Structure

```
/web/
├── src/
│   ├── pages/              # File-based routing (*.astro → routes)
│   │   ├── index.astro     # Homepage (/)
│   │   ├── dashboard.astro # Admin dashboard - Phase 2 (SSR)
│   │   └── api/            # API routes (TypeScript endpoints)
│   │       └── request-access.ts  # Form submission - Epic 4
│   ├── components/         # Reusable UI components
│   ├── layouts/            # Page layout templates
│   ├── lib/                # Utility functions, types, constants
│   ├── content/            # Astro Content Collections (Epic 2)
│   └── styles/
│       └── global.css      # Tailwind imports + custom styles
├── public/                 # Static assets (images, fonts, favicon)
├── .env.example            # Environment variable template
├── astro.config.mjs        # Astro configuration (hybrid rendering)
├── tailwind.config.mjs     # Tailwind + Minecraft color palette
├── tsconfig.json           # TypeScript configuration (strict mode)
├── wrangler.toml           # Cloudflare Workers configuration
└── package.json            # Dependencies and scripts
```

## Architecture

### Hybrid Rendering

The site uses Astro's **hybrid rendering mode** (`output: 'hybrid'`):

- **Static pages (default):** Marketing pages (e.g., `/`, `/about`, `/rules`) are pre-rendered at build time for maximum performance and SEO.
- **SSR pages (opt-in):** Admin dashboard (`/dashboard`) and API routes (`/api/*`) run server-side on Cloudflare Workers using `export const prerender = false`.

This architecture supports **Phase 1** (marketing site) and **Phase 2** (admin dashboard with GitHub OAuth + AWS SDK).

### Cloudflare Adapter

The `@astrojs/cloudflare` adapter enables:
- Deployment to Cloudflare Pages (global CDN)
- Server-side rendering via Cloudflare Workers (edge compute)
- Automatic static asset optimization

### Tailwind + Minecraft Theme

Custom color palette inspired by Minecraft:

- **Primary:** Grass Green (`#7CBD2F`), Emerald (`#50C878`)
- **Secondary:** Stone Gray (`#7F7F7F`), Dark Gray (`#1A1A1A`)
- **Accent:** Diamond Blue (`#5DCCE3`), Gold (`#FCEE4B`)

Use classes like `bg-primary-grass`, `text-accent-diamond`, etc.

### Content Auto-Generation (Epic 2)

Content for pages (rules, features, etc.) will be auto-generated from markdown files in `/mc-server/docs/` using Astro Content Collections.

### Future: Admin Dashboard (Phase 2)

The `/dashboard` route is a placeholder for future admin features:
- GitHub OAuth authentication
- AWS SDK integration for EC2 server management
- Server start/stop controls
- Player whitelist management

## Environment Variables

This project uses environment variables for sensitive configuration. See [.env.example](.env.example) for the full list.

**Required variables:**

- `RESEND_API_KEY` - Resend API key for sending emails (Epic 4)
- `ADMIN_EMAIL` - Admin email address for form submissions
- `MC_SERVER_IP` - Minecraft server IP (e.g., `play.bhsmp.com`)
- `MC_SERVER_PORT` - Minecraft server port (default: `25565`)

**Optional variables (Phase 2):**

- `DISCORD_WEBHOOK_URL` - Discord webhook for notifications
- `GITHUB_CLIENT_ID` - GitHub OAuth client ID
- `GITHUB_CLIENT_SECRET` - GitHub OAuth client secret

**Setup:**

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Add your API keys and secrets (never commit `.env` to git!)

3. Restart the dev server to load new variables.

**Note:** Environment variables prefixed with `PUBLIC_` are exposed to the browser. Use sparingly for sensitive data.

## Deployment

### Cloudflare Pages

The site is deployed to **Cloudflare Pages** (configured in Epic 5).

**Build settings:**
- Build command: `npm run build`
- Build output directory: `dist`
- Node.js version: 18+

**Environment variables** are configured in the Cloudflare Pages dashboard (not in `.env`).

**Deployment:**

- **Automatic:** Pushes to `main` branch trigger automatic deployments
- **Manual:** Use Wrangler CLI:
  ```bash
  npx wrangler pages deploy dist
  ```

More details on deployment will be added in **Epic 5: Deployment & Production**.

## Contributing

### Development Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Follow existing code style (TypeScript, Tailwind)
   - Test locally with `npm run dev`
   - Run type check: `npm run astro check`

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat: description of your changes"
   ```

4. **Push and create a Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style Conventions

- **TypeScript:** Strict mode enabled; use type annotations for function params and returns
- **Tailwind:** Use utility classes; avoid custom CSS unless necessary
- **Astro Components:** Use `.astro` files for pages/components; use frontmatter for logic
- **File Naming:** Use `kebab-case` for files (e.g., `request-access.ts`, `base-layout.astro`)

### Project Phases

- **Epic 1: Site Foundation** (current) - Astro + Tailwind + TypeScript setup
- **Epic 2: Content System** - Auto-generate content from markdown docs
- **Epic 3: Pages & Components** - Build marketing pages (home, about, rules, etc.)
- **Epic 4: Form & API Integration** - Request access form with email submission
- **Epic 5: Deployment & Production** - Deploy to Cloudflare Pages
- **Phase 2:** Admin dashboard with GitHub OAuth + AWS SDK (future)

## Resources

- **PRD:** See [web/.docs/ASTRO-SITE-PRD.md](../.docs/ASTRO-SITE-PRD.md) for full product requirements
- **Astro Docs:** https://astro.build/
- **Cloudflare Pages:** https://developers.cloudflare.com/pages/
- **Tailwind CSS:** https://tailwindcss.com/

## License

[Add license information if applicable]

---

**Built with ❤️ for the BlockHaven Minecraft community**
````

### Files to Modify

**None** - This spec only creates a new file (`web/README.md`), no existing files are modified.

## Acceptance Criteria Mapping

### Story Criterion 1: README.md created in /web

**Acceptance criteria:**
- File exists in `/web` directory (project root)
- Provides clear overview of the BlockHaven marketing website

**Verification:**
- Check file exists: `ls web/README.md`
- File starts with project title and description
- Overview explains invite-only Minecraft server

### Story Criterion 2: Project overview section

**Acceptance criteria:**
- Explains what BlockHaven website is (invite-only Minecraft server marketing site)
- Lists tech stack: Astro 4.x, Cloudflare adapter, Tailwind CSS, TypeScript
- Describes architecture: Hybrid rendering (static marketing + SSR admin dashboard)
- States purpose: Phase 1 (marketing) + Phase 2 (admin dashboard)

**Verification:**
- README includes header section with project description
- "Tech Stack" section lists all technologies
- "Architecture" section explains hybrid rendering
- Mentions Phase 2 admin dashboard plans

### Story Criterion 3: Getting started section

**Acceptance criteria:**
- Includes step-by-step setup instructions
- Steps: Clone → Navigate → Copy .env → npm install → npm run dev → Open browser

**Verification:**
- "Getting Started" section exists
- Numbered steps match acceptance criteria
- Commands are in code blocks
- Includes prerequisites (Node.js 18+, npm, git)

### Story Criterion 4: Development commands documented

**Acceptance criteria:**
- Lists all npm scripts with descriptions
- Includes: dev, build, preview, astro check

**Verification:**
- "Development Commands" section exists
- Table format with command and action columns
- All core scripts documented

### Story Criterion 5: Project structure documented

**Acceptance criteria:**
- Explains purpose of each directory
- Covers: pages, components, layouts, lib, content, styles, public

**Verification:**
- "Project Structure" section exists
- Includes directory tree visualization
- Each directory has purpose explanation

### Story Criterion 6: Architecture notes

**Acceptance criteria:**
- Explains hybrid rendering (static + SSR)
- Documents Cloudflare adapter benefits
- Notes Tailwind + Minecraft theme
- Mentions content auto-generation (Epic 2)
- References future admin dashboard (Phase 2)

**Verification:**
- "Architecture" section exists
- All 5 topics covered with subsections
- Explains static vs SSR page types
- Lists Minecraft color palette

### Story Criterion 7: Deployment information

**Acceptance criteria:**
- States deployment to Cloudflare Pages (Epic 5)
- Mentions environment variables in Cloudflare dashboard
- Notes automatic deployments on push to main
- References Wrangler CLI for manual deployments

**Verification:**
- "Deployment" section exists
- All 4 points covered
- Build settings documented
- Notes that Epic 5 adds more details

### Story Criterion 8: Contributing guidelines

**Acceptance criteria:**
- Explains how to create feature branches
- Documents code style conventions (TypeScript, Tailwind)
- Describes how to test changes locally
- Notes PR process (if applicable)

**Verification:**
- "Contributing" section exists
- Development workflow steps documented
- Code style conventions listed
- Testing instructions included

## Testing Requirements

### Manual Testing Checklist

**After creating README:**

- [ ] File exists at `web/README.md`
- [ ] Markdown renders correctly on GitHub (or in Markdown preview)
- [ ] All 8 major sections present
- [ ] Code blocks are properly formatted with syntax highlighting
- [ ] Links are valid (internal file links, external URLs)
- [ ] Table of npm commands renders correctly
- [ ] Directory tree structure is readable
- [ ] No typos or grammatical errors (quick proofread)

### Content Verification

**Check each section:**

- [ ] **Header** - Project title and tagline
- [ ] **Tech Stack** - All 6 technologies listed
- [ ] **Getting Started** - 6 numbered steps
- [ ] **Development Commands** - Table with 6 commands
- [ ] **Project Structure** - Directory tree + explanations
- [ ] **Architecture** - 5 subsections (hybrid rendering, Cloudflare, Tailwind, content, Phase 2)
- [ ] **Environment Variables** - Links to `.env.example`, lists required vars
- [ ] **Deployment** - Build settings, auto-deploy, Wrangler command
- [ ] **Contributing** - Workflow steps, code style, phases

### Link Verification

**Check all links work:**

- [ ] `.env.example` link (relative path)
- [ ] `web/.docs/ASTRO-SITE-PRD.md` link (relative path)
- [ ] External links (Astro docs, Cloudflare, Tailwind) open correctly

### Accuracy Verification

**Cross-check with actual project:**

- [ ] npm scripts in README match `package.json`
- [ ] Directory structure matches actual `/web/src/` structure
- [ ] Environment variables match `.env.example`
- [ ] Tech stack versions match `package.json` (Astro 4.x, Tailwind 3.x, TypeScript 5.x)

## Dependencies

**Must complete first:**
- Spec stories-01-05-combined: Project initialized with all configs
- Spec 06: Placeholder routes created (dashboard, API)
- All previous specs must be implemented so README can accurately document the current state

**Enables:**
- Epic 2-5: README will be updated incrementally as features are added
- Future maintainers: Documentation ensures project longevity

## Risks & Mitigations

**Risk 1: README becomes outdated**
- **Likelihood:** Medium (as project evolves)
- **Impact:** Medium (misleads new developers)
- **Mitigation:** Add note at top: "Last updated: [date]"; update README in each epic's final story
- **Fallback:** Schedule quarterly documentation reviews

**Risk 2: Setup instructions don't work**
- **Likelihood:** Low (if tested)
- **Impact:** High (blocks onboarding)
- **Mitigation:** Test setup instructions on fresh clone before finalizing
- **Fallback:** Add troubleshooting section with common issues

**Risk 3: Over-promising future features**
- **Likelihood:** Low (explicitly labeled as "Phase 2")
- **Impact:** Low (expectations set correctly)
- **Mitigation:** Clearly mark future features as "Phase 2" or "Epic X"
- **Fallback:** Use "planned" or "future" language instead of definitive statements

## Performance Considerations

**Not applicable** - This is documentation only, no runtime performance impact.

## Security Considerations

**Documentation risks:**
- **Don't include:** Actual API keys, secrets, or production URLs
- **Do include:** Placeholder values in `.env.example` format
- **Reference `.env.example`:** Direct developers to copy and customize

**Verification:**
- README contains no actual secrets
- All example environment variables use placeholder values
- Production deployment URLs not hardcoded (Epic 5 will add)

## Success Verification

After implementation, verify all criteria:

**File & Format:**
- [ ] `web/README.md` exists
- [ ] Markdown is valid (no syntax errors)
- [ ] Renders correctly on GitHub / in Markdown preview
- [ ] All headings use proper hierarchy (H1, H2, H3)

**Content Completeness:**
- [ ] All 8 major sections present and populated
- [ ] Tech stack lists all technologies
- [ ] Getting Started has 6 numbered steps
- [ ] Development Commands table has all npm scripts
- [ ] Project Structure shows directory tree
- [ ] Architecture explains hybrid rendering + future plans
- [ ] Environment Variables section references `.env.example`
- [ ] Deployment section mentions Cloudflare Pages
- [ ] Contributing section explains workflow

**Accuracy:**
- [ ] npm scripts match `package.json`
- [ ] Directory structure matches actual project
- [ ] Tech stack versions are correct
- [ ] Links to `.env.example` and PRD work

**Usability:**
- [ ] New developer can follow instructions to get server running
- [ ] Code blocks have syntax highlighting (```bash, ```markdown, etc.)
- [ ] Table formats correctly
- [ ] No broken links

## Traceability

**Parent story:** [Story 07: Write Web Project Documentation](../../stories/epic-BH-WEB-001-01/story-07.md)

**Parent epic:** [Epic BH-WEB-001-01: Site Foundation & Infrastructure](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-07.md
      └─ specs/epic-BH-WEB-001-01/spec-07.md (this file)
         └─ [Implementation via /sl-develop]
```

## Implementation Notes

**Recommended execution order:**

1. **Create the file:**
   ```bash
   touch web/README.md
   ```

2. **Copy the full README content** from this spec (see "Full implementation" section above)

3. **Review for accuracy:**
   - Check npm scripts match `package.json`
   - Verify directory structure matches actual project
   - Confirm tech stack versions

4. **Test links:**
   - Open README in VS Code Markdown preview or GitHub
   - Click all internal links (`.env.example`, PRD)
   - Verify external links open (Astro docs, Cloudflare, Tailwind)

5. **Proofread:**
   - Run spell check
   - Read through for clarity
   - Ensure consistent formatting

6. **Commit:**
   ```bash
   git add web/README.md
   git commit -m "docs: add comprehensive README for web project"
   ```

**Open questions:**
- Should we add a "Troubleshooting" section? (Can add later as issues arise)
- Should we include screenshots? (Not required for MVP, can add in Epic 3)
- Should we add build status badges? (Add in Epic 5 after CI/CD setup)

**Assumptions:**
- All previous specs (stories 01-06) are implemented
- `package.json`, `astro.config.mjs`, `tailwind.config.mjs`, `.env.example` exist
- Project structure matches Epic 1 specifications

**Notes for implementation:**
- Use the **full README content** provided in this spec - it's ready to paste
- Markdown syntax: Use triple backticks for code blocks, add language for highlighting (```bash, ```typescript, etc.)
- Keep README updated: This is a living document; Epic 2-5 will add sections for new features
- Avoid over-promising: Clearly label future features as "Phase 2" or "Epic X" to set expectations
- Internal links use relative paths: `../.docs/ASTRO-SITE-PRD.md` (up one level, into .docs)

---

**Next step:** Implement this spec with `/sl-develop .storyline/specs/epic-BH-WEB-001-01/spec-07.md`
