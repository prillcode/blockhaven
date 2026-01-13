---
story_id: 10
epic_id: 002
title: Rules & Contact Pages
status: ready_for_spec
created: 2026-01-12
---

# Story 10: Rules & Contact Pages

## User Story

**As a** BlockHaven website visitor,
**I want** a complete rules page and contact page with FAQ,
**so that** I understand server policies and know how to get help.

## Acceptance Criteria

### Scenario 1: Rules page shows full rules list
**Given** I navigate to /rules
**When** the page loads
**Then** I see all 10-15 server rules with descriptions
**And** rules are organized by category
**And** expandable sections for detailed explanations (optional)

### Scenario 2: Contact page shows FAQ
**Given** I navigate to /contact
**When** the page loads
**Then** I see FAQ section with common questions
**And** placeholder for contact form (Epic 004)
**And** Discord invite link (if available)

### Scenario 3: Both pages have SEO
**Given** either page loads
**When** I inspect meta tags
**Then** unique title and description for each page
**And** appropriate Open Graph tags

## Business Value

**Why this matters:** Clear rules set expectations. Contact page provides support channel.

**Impact:** Reduces rule violations and support burden.

**Success metric:** Rules page read by >40% of new players before joining.

## Technical Considerations

**Constraints:**
- Uses rules data from Story 02
- Uses Card, Button from Story 01
- Contact form is placeholder (full implementation in Epic 004)

## Dependencies

**Depends on:** Story 01 (UI), Story 02 (rules data)
**Enables:** Story 11 (Router)

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md
