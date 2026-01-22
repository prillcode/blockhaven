---
story_id: 06
epic_id: 002
title: FeaturesGrid Section Component
status: ready_for_spec
created: 2026-01-12
---

# Story 06: FeaturesGrid Section Component

## User Story

**As a** BlockHaven website visitor,
**I want** to see key server features highlighted in an organized grid,
**so that** I understand what makes BlockHaven special (anti-grief, cross-platform, etc.).

## Acceptance Criteria

### Scenario 1: Grid displays all features
**Given** the FeaturesGrid section renders
**When** I view it
**Then** I see 6 feature cards with icon, title, description
**And** Golden Shovel Land Claims is prominently featured first
**And** grid is responsive (1-2-3 columns)

### Scenario 2: Icons render correctly
**Given** each feature has an icon
**When** the grid renders
**Then** lucide-react icons display (Shield, Users, Coins, Heart, Globe, Gamepad2)
**And** icons are colored with theme colors

## Business Value

**Why this matters:** Features section communicates unique value propositions beyond just worlds.

**Impact:** Highlights FREE golden shovel claims (major selling point) and family-friendly environment.

**Success metric:** Features section read by >50% of visitors.

## Technical Considerations

**Constraints:**
- Uses Card from Story 01
- Uses features data from Story 02
- Icons from lucide-react

## Dependencies

**Depends on:** Story 01 (Card), Story 02 (features data)
**Enables:** Story 08 (Home Page)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md
