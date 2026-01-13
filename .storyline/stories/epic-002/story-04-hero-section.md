---
story_id: 04
epic_id: 002
title: Hero Section Component
status: ready_for_spec
created: 2026-01-12
---

# Story 04: Hero Section Component

## User Story

**As a** BlockHaven website visitor,
**I want** an eye-catching hero section with the server tagline and clear CTA,
**so that** I immediately understand what BlockHaven offers and what action to take.

## Acceptance Criteria

### Scenario 1: Hero renders with all elements
**Given** I land on the homepage
**When** the Hero section renders
**Then** I see tagline "Family-Friendly Anti-Griefer Survival & Creative!"
**And** server IP with copy button
**And** live status badge (placeholder for Epic 004)
**And** "Explore Worlds" primary CTA button
**And** Minecraft-themed background

### Scenario 2: CTA navigates to Worlds page
**Given** the Hero section is displayed
**When** I click "Explore Worlds" button
**Then** I navigate to /worlds page

### Scenario 3: Responsive on mobile
**Given** viewing on mobile (<768px)
**When** Hero renders
**Then** layout stacks vertically
**And** text sizes adjust appropriately
**And** CTA remains prominent

## Business Value

**Why this matters:** Hero is the first impression - must immediately communicate value and guide users to explore.

**Impact:** Strong hero increases engagement and reduces bounce rate.

**Success metric:** >70% of homepage visitors click "Explore Worlds" CTA.

## Technical Considerations

**Constraints:**
- Uses Button from Story 01
- Must integrate with Router (Story 11) for navigation
- Placeholder for ServerStatus widget (Epic 004)

## Dependencies

**Depends on:** Story 01 (Button component)
**Enables:** Story 08 (Home Page)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md
