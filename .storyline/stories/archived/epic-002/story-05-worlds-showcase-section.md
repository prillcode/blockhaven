---
story_id: 05
epic_id: 002
title: WorldsShowcase Section Component
status: ready_for_spec
created: 2026-01-12
---

# Story 05: WorldsShowcase Section Component

## User Story

**As a** BlockHaven website visitor,
**I want** to see all 6 worlds displayed in a grid on the homepage,
**so that** I can get a quick overview of the server's variety.

## Acceptance Criteria

### Scenario 1: Grid displays all 6 worlds
**Given** the WorldsShowcase section renders
**When** I view it
**Then** I see 6 WorldCards in a grid (3x2 on desktop)
**And** each card shows world screenshot and info
**And** grid is responsive (1 column on mobile, 2 on tablet, 3 on desktop)

### Scenario 2: Section has heading
**Given** the section renders
**When** I scroll to it
**Then** I see section heading "Explore Our 6 Unique Worlds"
**And** optional subtitle with brief description

## Business Value

**Why this matters:** World variety is BlockHaven's primary differentiator - must be prominently showcased.

**Impact:** Clear world presentation helps players understand options and increases join rate.

**Success metric:** WorldsShowcase is the most-viewed section on homepage (scroll tracking).

## Technical Considerations

**Constraints:**
- Uses WorldCard from Story 03
- Uses worlds data from Story 02
- Must be performant with 6 images

## Dependencies

**Depends on:** Story 01 (UI), Story 02 (data), Story 03 (WorldCard)
**Enables:** Story 08 (Home Page)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md
