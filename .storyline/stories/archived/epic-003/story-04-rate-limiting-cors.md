---
story_id: 04
epic_id: 003
title: Rate Limiting & CORS Middleware
status: ready_for_spec
created: 2026-01-12
---

# Story 04: Rate Limiting & CORS Middleware

## User Story

**As a** BlockHaven server administrator,
**I want** rate limiting and CORS protection on API endpoints,
**so that** the API is protected from spam and unauthorized access.

## Acceptance Criteria

### Scenario 1: Rate limiting prevents spam
**Given** rate limit is 3 requests per 10 minutes per IP
**When** same IP makes 4 contact form submissions in 5 minutes
**Then** first 3 succeed (200), 4th fails with 429 "Too many requests"

### Scenario 2: CORS allows frontend domain
**Given** request from https://bhsmp.com
**When** frontend makes API request
**Then** CORS headers allow the request

### Scenario 3: CORS blocks unauthorized domains
**Given** request from https://evil-site.com
**When** that domain makes API request
**Then** CORS blocks the request

### Scenario 4: Rate limiting resets after window
**Given** IP hit rate limit at time T
**When** 11 minutes pass (T+11m)
**Then** that IP can make requests again

## Business Value

**Why this matters:** Protects API from abuse and spam attacks.

**Impact:** Prevents Discord webhook spam, reduces server load.

**Success metric:** 0 spam attacks succeed, legitimate traffic unaffected.

## Technical Considerations

**Constraints:**
- Rate limit: 3 requests/10min per IP (contact endpoint only)
- CORS: bhsmp.com and localhost:5173 (dev)
- Memory-based rate limit store (no Redis needed)

## Dependencies

**Depends on:** Stories 01, 02, 03 (applies to endpoints)

## Traceability

**Parent epic:** .storyline/epics/epic-003-backend-api-services.md
