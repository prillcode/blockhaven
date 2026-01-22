---
story_id: 01
epic_id: 001
title: Vite + React 19 + TypeScript Project Initialization
status: ready_for_spec
created: 2026-01-10
---

# Story 01: Vite + React 19 + TypeScript Project Initialization

## User Story

**As a** BlockHaven website developer,
**I want** a working Vite + React 19 + TypeScript development environment with proper project structure,
**so that** I can start building the marketing website with modern tools and best practices.

## Acceptance Criteria

### Scenario 1: Project initialization succeeds
**Given** I am in the `/web/` directory
**When** I run `pnpm create vite@latest . -- --template react-ts`
**Then** the Vite project is initialized with React 19 and TypeScript
**And** the project includes standard Vite files (vite.config.ts, tsconfig.json, index.html)

### Scenario 2: Dependencies installed successfully
**Given** the project is initialized
**When** I run `pnpm install`
**Then** all core dependencies are installed (react, react-dom, typescript, vite)
**And** package.json includes all required dependencies
**And** pnpm-lock.yaml is generated

### Scenario 3: Development server starts
**Given** dependencies are installed
**When** I run `pnpm dev`
**Then** Vite development server starts on port 5173
**And** the default React welcome page displays in browser
**And** hot module replacement (HMR) works when files are edited

### Scenario 4: Project structure created
**Given** the base project exists
**When** I create the directory structure
**Then** all required directories exist:
- src/components/ (layout, sections, widgets, ui)
- src/pages/
- src/hooks/
- src/contexts/
- src/data/
- src/lib/
- src/types/
- src/styles/
- public/worlds/

### Scenario 5: TypeScript compilation works
**Given** the project is set up
**When** I run `pnpm build`
**Then** TypeScript compilation succeeds without errors
**And** production build is created in dist/ directory

## Business Value

**Why this matters:** Without a properly initialized project, no development can begin. This is the foundation for the entire website.

**Impact:** Developers can immediately start building components and pages using modern React 19 features with type safety.

**Success metric:** Developer can run `pnpm dev` and see a working React application in under 5 minutes from project start.

## Technical Considerations

**Potential approaches:**
- Use `pnpm create vite@latest` with react-ts template (recommended)
- Manually configure Vite + React + TypeScript (more complex, not recommended)

**Constraints:**
- Must use pnpm (not npm or yarn)
- Must use Vite 6.0+ (latest version)
- Must use React 19 (latest with concurrent features)
- Must use TypeScript 5.7+

**Data requirements:**
- package.json with all dependencies
- vite.config.ts with proper configuration
- tsconfig.json with strict mode enabled
- index.html as entry point

**Key dependencies to install:**
```json
{
  "react": "^19.0.0",
  "react-dom": "^19.0.0",
  "react-router-dom": "^7.0.0",
  "clsx": "latest",
  "tailwind-merge": "latest",
  "lucide-react": "latest",
  "framer-motion": "^12.0.0"
}
```

**Dev dependencies:**
```json
{
  "@tailwindcss/vite": "latest",
  "tailwindcss": "^4.0.0",
  "autoprefixer": "latest",
  "postcss": "latest",
  "@types/react": "latest",
  "@types/react-dom": "latest",
  "typescript": "^5.7.0",
  "vite": "^6.0.0"
}
```

## Dependencies

**Depends on stories:**
- No dependencies (foundation story)

**Enables stories:**
- Story 02: Tailwind CSS Configuration (needs base project)
- Story 03: Theme Context & Dark Mode (needs React project structure)
- Story 04-006: All layout components (need project structure)

**No dependencies:** This is the first story and can start immediately.

## Out of Scope

- Tailwind CSS configuration (Story 02)
- Component creation (Stories 004-006)
- Theme implementation (Story 03)
- Content or data files
- Docker setup (Epic 005)

## Notes

- Use pnpm for package management (faster, more efficient than npm)
- Ensure Node.js 20+ is installed before starting
- Create .gitignore to exclude node_modules/, dist/, .env
- This story focuses purely on scaffolding - no custom code yet

## Traceability

**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

**Related stories:** Story 02 (Tailwind setup), Story 03 (Theme context)

---

**Next step:** Run `/spec-story .storyline/stories/epic-001/story-001-vite-react-project-initialization.md`
