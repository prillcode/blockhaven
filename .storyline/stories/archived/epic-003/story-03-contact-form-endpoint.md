---
story_id: 03
epic_id: 003
title: Contact Form Endpoint with Discord Integration
status: ready_for_spec
created: 2026-01-12
---

# Story 03: Contact Form Endpoint with Discord Integration

## User Story

**As a** BlockHaven website visitor,
**I want** to submit a contact form that sends my message to server administrators,
**so that** I can ask questions or report issues without needing email.

## Acceptance Criteria

### Scenario 1: Valid form submission succeeds
**Given** I have a valid contact form payload
**When** I POST /api/contact with name, email, subject, message
**Then** I receive 200 status with {"success": true}
**And** message appears in Discord channel via webhook

### Scenario 2: Validation rejects invalid data
**Given** I submit a form with missing name
**When** I POST /api/contact
**Then** I receive 400 status with validation error
**And** no Discord message is sent

### Scenario 3: Email validation works
**Given** I submit form with invalid email "notanemail"
**When** I POST /api/contact
**Then** I receive 400 with {"error": "Invalid email format"}

## Business Value

**Why this matters:** Provides easy support channel without exposing admin emails.

**Impact:** Increases user support engagement, reduces friction.

**Success metric:** >90% of submitted forms successfully reach Discord.

## Technical Considerations

**Constraints:**
- Discord webhook URL from environment variable
- Server-side validation (name, email format, subject, message min length)
- Never expose webhook URL to client

## Dependencies

**Depends on:** Story 01 (Hono server)
**Enables:** Epic 004 (ContactForm widget)

## Traceability

**Parent epic:** .storyline/epics/epic-003-backend-api-services.md
