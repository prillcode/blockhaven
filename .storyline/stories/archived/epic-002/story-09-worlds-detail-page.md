---
story_id: 09
epic_id: 002
title: Worlds Detail Page
status: ready_for_spec
created: 2026-01-12
---

# Story 09: Worlds Detail Page

## User Story

**As a** BlockHaven website visitor,
**I want** a dedicated page with detailed information about all 6 worlds,
**so that** I can make an informed decision about where to play.

## Acceptance Criteria

### Scenario 1: Page shows all 6 worlds with details
**Given** I navigate to /worlds
**When** the page loads
**Then** I see sections for Survival Worlds, Creative Worlds, and Spawn Hub
**And** each world shows full description, seed, features, screenshot gallery

### Scenario 2: Worlds organized by category
**Given** the Worlds page displays
**When** I scroll through it
**Then** survival worlds grouped together (Easy, Normal, Hard)
**And** creative worlds grouped together (Plots, Hills)
**And** Spawn Hub section explains central hub concept

### Scenario 3: Copy seed button works
**Given** a world shows its seed
**When** I click "Copy Seed" button
**Then** seed is copied to clipboard
**And** toast notification confirms "Seed copied!"

## Business Value

**Why this matters:** World variety is BlockHaven's main differentiator - needs dedicated showcase.

**Impact:** Detailed world info helps players visualize gameplay and increases joins.

**Success metric:** Worlds page has 2nd highest traffic after Home.

## Technical Considerations

**Constraints:**
- Uses WorldCard from Story 03 (enhanced with more details)
- Uses worlds data from Story 02
- Copy seed functionality (clipboard API)

## Dependencies

**Depends on:** Story 01 (UI), Story 02 (data), Story 03 (WorldCard)
**Enables:** Story 11 (Router)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md
