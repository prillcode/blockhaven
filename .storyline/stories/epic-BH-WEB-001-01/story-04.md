---
story_id: 04
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Create Standard Project Directory Structure
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 04: Create Standard Project Directory Structure

## User Story

**As a** developer,
**I want** a well-organized directory structure following Astro best practices,
**so that** the team knows where to place pages, components, layouts, utilities, and content, reducing confusion and maintaining consistency as the project grows.

## Acceptance Criteria

### Scenario 1: Pages directory created
**Given** the Astro project is initialized
**When** I navigate to `src/pages/`
**Then** the directory exists
**And** it contains a placeholder `index.astro` (if not already present from init)
**And** I understand this is where routes are defined

### Scenario 2: Components directory created
**Given** the project structure is being set up
**When** I create `src/components/`
**Then** the directory exists
**And** it has a `.gitkeep` or README explaining its purpose
**And** I can create reusable UI components here

### Scenario 3: Layouts directory created
**Given** the project structure is being set up
**When** I create `src/layouts/`
**Then** the directory exists
**And** it has a `.gitkeep` or README explaining layout purpose
**And** I can create shared page layouts here (e.g., BaseLayout.astro)

### Scenario 4: Lib directory for utilities created
**Given** the project structure is being set up
**When** I create `src/lib/`
**Then** the directory exists
**And** it's meant for utility functions, helpers, and business logic
**And** subdirectories may include: `utils/`, `types/`, `constants/`

### Scenario 5: Content directory created
**Given** the project structure is being set up
**When** I create `src/content/`
**Then** the directory exists
**And** it's prepared for Astro Content Collections (Epic 2)
**And** a README explains this is for structured content (markdown docs, data files)

### Scenario 6: Styles directory created
**Given** the project structure is being set up
**When** I create `src/styles/`
**Then** the directory exists
**And** it contains `global.css` (from Story 02 or placeholder)
**And** additional stylesheets can be added here

### Scenario 7: Public directory exists
**Given** Astro's default setup
**When** I check for `public/` (in project root, not `src/`)
**Then** the directory exists (created by Astro init)
**And** I can place static assets here (images, fonts, favicon.ico)
**And** files here are served at root URL (e.g., `/logo.png`)

## Business Value

**Why this matters:** A clear, predictable directory structure reduces cognitive load for developers, makes onboarding faster, and prevents "where do I put this?" questions. It scales with the project as features are added.

**Impact:** Development team can navigate the codebase confidently. New developers understand project organization immediately. Future maintainers can find files quickly.

**Success metric:** Any developer can locate a file type (component, layout, page, utility) within 10 seconds.

## Technical Considerations

**Potential approaches:**
- Use Astro's default structure and add missing directories
- Create all directories upfront (recommended)
- Add directories incrementally as needed (leads to inconsistency)

**Recommended approach:** Create all standard directories upfront with placeholder files or READMEs explaining their purpose.

**Constraints:**
- Must follow Astro conventions:
  - `src/pages/` for routing
  - `src/components/` for reusable components
  - `src/layouts/` for page layouts
  - `public/` for static assets (not in `src/`)
- Must be compatible with TypeScript imports
- Must work with Tailwind's content scanning

**Directory purposes:**
- **pages/**: File-based routing (e.g., `about.astro` → `/about`)
- **components/**: Reusable UI components (Header, Footer, Button, etc.)
- **layouts/**: Page templates (BaseLayout, BlogLayout, etc.)
- **lib/**: Utility functions, types, constants, API clients
- **content/**: Content Collections for structured data (Epic 2)
- **styles/**: Global CSS, Tailwind imports, custom stylesheets
- **public/**: Static assets served as-is (images, fonts, favicon)

**Structure overview:**
```
/web/
├── src/
│   ├── pages/          # Routes (file-based routing)
│   ├── components/     # Reusable UI components
│   ├── layouts/        # Page layouts
│   ├── lib/            # Utilities, helpers, types
│   ├── content/        # Content Collections (Epic 2)
│   └── styles/         # Global CSS, Tailwind
├── public/             # Static assets (images, fonts)
├── package.json
├── astro.config.mjs
└── tsconfig.json
```

## Dependencies

**Depends on stories:**
- Story 01: Initialize Astro Project - Must have project root
- Story 02: Configure Tailwind - Styles directory relates to global.css

**Enables stories:**
- Story 06: Create placeholder routes - Routes go in pages/
- Epic 2: Content System - Content Collections go in content/
- Epic 3: Pages & Components - All UI code goes in these directories

## Out of Scope

- Creating actual components or layouts (Epic 3)
- Setting up Content Collections config (Epic 2)
- Adding specific utilities or helper functions (Epic 2 onwards)
- Organizing subdirectories within `lib/` (e.g., `lib/utils/`, `lib/types/`) - add as needed
- Creating a component library structure (e.g., `components/ui/`, `components/features/`) - refine later

## Notes

- Some directories may already exist after `npm create astro@latest` (e.g., `pages/`, `public/`)
- Use `.gitkeep` files to commit empty directories to git (git doesn't track empty directories)
- Alternatively, add a `README.md` in each directory explaining its purpose (better documentation)
- The `content/` directory is for Astro Content Collections, not general content (Epic 2 explains this)
- Subdirectories within `lib/` (e.g., `lib/utils/`, `lib/api/`) can be added incrementally as needed

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 01 (Astro init), Story 06 (Placeholder routes), Epic 2 (Content system)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-04.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-04.md`
