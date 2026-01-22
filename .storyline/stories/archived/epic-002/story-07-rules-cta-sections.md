---
story_id: 07
epic_id: 002
title: ServerRules & CallToAction Section Components
status: ready_for_spec
created: 2026-01-12
---

# Story 07: ServerRules & CallToAction Section Components

## User Story

**As a** BlockHaven website visitor,
**I want** to see a brief overview of server rules and a final call-to-action,
**so that** I understand expectations and am prompted to join.

## Acceptance Criteria

### Scenario 1: ServerRules shows brief rules
**Given** the ServerRules section renders
**When** I view it
**Then** I see 5 key rules with brief descriptions
**And** "View Full Rules" link to /rules page

### Scenario 2: CallToAction section renders
**Given** the CTA section renders
**When** I view it
**Then** I see heading "Ready to Start Your Adventure?"
**And** "Explore Worlds" and "Copy Server IP" buttons
**And** Compelling description text

## Business Value

**Why this matters:** Rules set expectations for family-friendly environment. CTA provides final conversion opportunity.

**Impact:** Clear rules reduce moderation issues. CTA increases join rate.

**Success metric:** >30% of users who reach CTA click one of the buttons.

## Technical Considerations

**Constraints:**
- Uses Button from Story 01
- Uses rules data from Story 02 (filtered to top 5)
- CTA uses same button styles as Hero

## Dependencies

**Depends on:** Story 01 (Button), Story 02 (rules data)
**Enables:** Story 08 (Home Page)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md
