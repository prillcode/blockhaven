---
story_id: 02
epic_id: 002
title: Content Data Structures & TypeScript Types
status: ready_for_spec
created: 2026-01-12
---

# Story 02: Content Data Structures & TypeScript Types

## User Story

**As a** BlockHaven website developer,
**I want** TypeScript interfaces and data files for worlds, features, and rules,
**so that** I have type-safe content that's easy to update and maintain.

## Acceptance Criteria

### Scenario 1: World data structure defined
**Given** I need to display world information
**When** I import `worlds` from `src/data/worlds.ts`
**Then** I get an array of 6 world objects
**And** each world has required fields (id, displayName, type, difficulty, description, image, features)
**And** TypeScript prevents invalid data

### Scenario 2: Features data structure defined
**Given** I need to display server features
**When** I import `features` from `src/data/features.ts`
**Then** I get an array of feature objects
**And** each has icon name, title, description
**And** Icons are from lucide-react

### Scenario 3: Rules data structure defined
**Given** I need to display server rules
**When** I import `rules` from `src/data/rules.ts`
**Then** I get an array of rule objects
**And** each has id, title, description, examples (optional)

### Scenario 4: TypeScript types defined
**Given** I'm building components
**When** I import types from `src/types/world.ts`
**Then** World, Feature, Rule interfaces are available
**And** Difficulty type: 'Easy' | 'Normal' | 'Hard' | 'Peaceful'
**And** WorldType: 'survival' | 'creative' | 'spawn'

## Business Value

**Why this matters:** Structured data with types prevents bugs and makes content updates safe and easy.

**Impact:** Content changes require zero code changes - just update data files.

**Success metric:** All content displayed correctly with type safety enforced.

## Technical Considerations

**Potential approaches:**
- TypeScript interfaces + static data exports (recommended)
- JSON files + type definitions (less type-safe)

**Constraints:**
- Must be fully typed with TypeScript
- Must include all 6 worlds with complete data
- Must match content from WEB-COMPLETE-PLAN.md

**Data requirements:**
- 6 worlds (SMP_Plains, SMP_Ravine, SMP_Cliffs, Creative_Plots, Creative_Hills, Spawn_Hub)
- 6+ features (Golden Shovel, Cross-Platform, Economy, Family-Friendly, etc.)
- 10-15 server rules

## Dependencies

**Depends on stories:**
- Epic 001 complete

**Enables stories:**
- Story 03: WorldCard (uses World type)
- Story 05: WorldsShowcase (uses worlds data)
- Story 06: FeaturesGrid (uses features data)
- Story 07: ServerRules (uses rules data)
- Story 09: Worlds Page (uses worlds data)
- Story 10: Rules Page (uses rules data)

## Out of Scope

- CMS integration (static data for now)
- Admin panel for content editing
- Content versioning or localization

## Notes

- Use seed values from WEB-COMPLETE-PLAN.md for worlds
- Include UltimateLandClaim description prominently
- Golden Shovel Land Claims should be first feature

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md

**Related stories:** Story 03, 05, 06, 07, 09, 10

---

**Next step:** Run `/spec-story .storyline/stories/epic-002/story-02-data-structures-typescript-types.md`
