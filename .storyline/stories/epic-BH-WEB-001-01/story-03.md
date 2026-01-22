---
story_id: 03
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Configure TypeScript for Astro Development
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 03: Configure TypeScript for Astro Development

## User Story

**As a** developer,
**I want** TypeScript properly configured with strict type checking for Astro,
**so that** I can catch errors at compile time and have better IDE autocomplete and type safety throughout the codebase.

## Acceptance Criteria

### Scenario 1: TypeScript compiles without errors
**Given** the Astro project is initialized (Story 01 complete)
**When** I run `npm run build` or `tsc --noEmit`
**Then** TypeScript compilation succeeds with no errors
**And** type definitions for Astro are available
**And** type definitions for Node.js are available

### Scenario 2: tsconfig.json configured for Astro
**Given** TypeScript is installed
**When** I review `tsconfig.json`
**Then** it includes Astro-specific settings:
  - `"extends": "astro/tsconfigs/strict"`
  - `"compilerOptions.jsx": "react-jsx"` (for JSX support)
  - `"compilerOptions.moduleResolution": "bundler"`
  - `"include": ["src/**/*"]`
  - `"exclude": ["dist", "node_modules"]`

### Scenario 3: Type checking works in development
**Given** TypeScript is configured
**When** I write code with type errors (e.g., wrong prop types)
**Then** VSCode shows red squiggly underlines
**And** `npm run build` fails with type error messages
**And** error messages are clear and actionable

### Scenario 4: Astro component types work
**Given** TypeScript is configured
**When** I create an Astro component with TypeScript in the frontmatter
**Then** type inference works for `Astro.props`
**And** I can define prop interfaces with `interface Props {}`
**And** autocomplete works for Astro globals

### Scenario 5: Import path resolution works
**Given** TypeScript is configured
**When** I import from `src/components/` or `src/lib/`
**Then** imports resolve correctly
**And** I can use path aliases (e.g., `@/components`) if configured

## Business Value

**Why this matters:** TypeScript prevents runtime errors by catching type mismatches at compile time, reducing bugs and improving developer productivity. It also provides better documentation through types.

**Impact:** Development team writes safer code with fewer bugs. New developers onboarding to the project get inline documentation via types. Refactoring becomes safer and faster.

**Success metric:** Zero TypeScript errors on `npm run build`, and developers report improved autocomplete experience in their IDEs.

## Technical Considerations

**Potential approaches:**
- Use Astro's default TypeScript config (basic)
- Extend Astro's strict config (recommended)
- Custom tsconfig from scratch (not recommended)

**Recommended approach:** Extend `astro/tsconfigs/strict` for maximum type safety.

**Constraints:**
- Must be compatible with Astro 4.x
- Must support JSX/TSX syntax (for React-like syntax in Astro)
- Must work with Cloudflare adapter types

**Data requirements:**
- No external data needed
- Type definition packages from npm

**Configuration specifics:**
```json
// tsconfig.json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2022",
    "lib": ["ES2022"],
    "skipLibCheck": true,
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "types": ["@types/node"]
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

## Dependencies

**Depends on stories:**
- Story 01: Initialize Astro Project - Must have Astro installed first

**Enables stories:**
- Story 04: Create directory structure - TypeScript will enforce structure
- Story 06: Create placeholder routes - Routes can use TypeScript
- All Epic 2, 3, 4 stories - All code will benefit from type safety

## Out of Scope

- Setting up path aliases (e.g., `@/components`) - can be added later if needed
- Installing additional type definition packages beyond `@types/node`
- ESLint configuration for TypeScript (can be added separately)
- Custom type declarations (`.d.ts` files) - only if needed later
- Strict null checks (included in strict mode, but not the focus)

## Notes

- Astro has excellent built-in TypeScript support; most configuration is handled automatically
- The `astro/tsconfigs/strict` preset is recommended for new projects
- Type checking does NOT run during `npm run dev` by default (for speed) - only during build
- To enable type checking in dev, use `astro check --watch` in a separate terminal
- VSCode's TypeScript language server provides real-time type checking in the editor

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 01 (Astro init), Story 04 (Directory structure), All future code stories

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-03.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-03.md`
