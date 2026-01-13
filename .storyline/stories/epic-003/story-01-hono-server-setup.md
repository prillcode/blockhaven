---
story_id: 01
epic_id: 003
title: Hono API Server Setup & TypeScript Configuration
status: ready_for_spec
created: 2026-01-12
---

# Story 01: Hono API Server Setup & TypeScript Configuration

## User Story

**As a** BlockHaven developer,
**I want** a working Hono API server with TypeScript in the api/ directory,
**so that** I can build backend endpoints for server status and contact form.

## Acceptance Criteria

### Scenario 1: Hono server starts successfully
**Given** the api project is initialized
**When** I run `pnpm dev` in api/
**Then** Hono server starts on port 3001
**And** a test route GET /api/health returns {"status": "ok"}

### Scenario 2: TypeScript compilation works
**Given** TypeScript is configured
**When** I run `pnpm build`
**Then** TypeScript compiles without errors
**And** compiled JavaScript is output to dist/

### Scenario 3: Hot reload works in development
**Given** the dev server is running
**When** I modify a route file
**Then** the server reloads automatically
**And** changes are reflected immediately

## Business Value

**Why this matters:** API server is the foundation for all backend features.

**Impact:** Enables live server status and contact form functionality.

**Success metric:** Server runs without errors and responds to requests.

## Technical Considerations

**Constraints:**
- Use Hono (not Express)
- Use @hono/node-server adapter
- TypeScript 5.7+
- pnpm package manager

**Data requirements:**
- package.json with Hono dependencies
- tsconfig.json for API
- Basic routing structure

## Dependencies

**Depends on:** None (can start independently)
**Enables:** Stories 02, 03, 04, 05

## Traceability

**Parent epic:** .storyline/epics/epic-003-backend-api-services.md
