---
story_id: 03
epic_id: 002
title: WorldCard Component
status: ready_for_spec
created: 2026-01-12
---

# Story 03: WorldCard Component

## User Story

**As a** BlockHaven website visitor,
**I want** to see each Minecraft world displayed in an attractive card with screenshot, difficulty, and features,
**so that** I can quickly understand what each world offers.

## Acceptance Criteria

### Scenario 1: WorldCard renders with all elements
**Given** a world object is passed to WorldCard
**When** the component renders
**Then** it displays world screenshot, name, difficulty badge, description, and features list
**And** hover effects work (scale up slightly)
**And** "Learn More" button links to worlds page

### Scenario 2: Difficulty badge shows correct color
**Given** different worlds have different difficulties
**When** WorldCard renders for each
**Then** Easy shows green, Normal shows yellow, Hard shows red, Peaceful shows blue

### Scenario 3: Responsive design works
**Given** the card is viewed on mobile
**When** screen width < 768px
**Then** card layout stacks vertically
**And** image fills width
**And** text remains readable

## Business Value

**Why this matters:** WorldCard is the primary component for showcasing BlockHaven's unique multi-world offering.

**Impact:** Clear visual representation helps players choose which world to explore first.

**Success metric:** WorldCard used in both homepage WorldsShowcase and Worlds detail page.

## Technical Considerations

**Constraints:**
- Uses Button, Card, Badge from Story 01
- Uses World type from Story 02
- Must support both grid and list layouts

**Data requirements:**
- World interface with all fields
- lucide-react icons for features

## Dependencies

**Depends on:** Story 01 (UI components), Story 02 (World type)
**Enables:** Story 05 (WorldsShowcase), Story 09 (Worlds Page)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md

---

**Next step:** Run `/spec-story .storyline/stories/epic-002/story-03-worldcard-component.md`
