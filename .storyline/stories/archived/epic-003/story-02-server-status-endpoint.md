---
story_id: 02
epic_id: 003
title: Server Status Endpoint with Caching
status: ready_for_spec
created: 2026-01-12
---

# Story 02: Server Status Endpoint with Caching

## User Story

**As a** BlockHaven website visitor,
**I want** to fetch real-time server status (online/offline, player count) via API,
**so that** I can see if the server is up before attempting to join.

## Acceptance Criteria

### Scenario 1: Status endpoint returns server info
**Given** Minecraft server is online at 5.161.69.191:25565
**When** I GET /api/server-status
**Then** I receive JSON with online: true, players: {online, max}, version, latency

### Scenario 2: Status is cached for 30 seconds
**Given** I fetch status at time T
**When** I fetch again at T+10s
**Then** cached response is returned (no new query to mcstatus.io)
**When** I fetch again at T+35s
**Then** fresh query is made to mcstatus.io

### Scenario 3: Offline server handled gracefully
**Given** Minecraft server is offline
**When** I GET /api/server-status
**Then** I receive 503 status with {"online": false, "error": "Server offline"}

## Business Value

**Why this matters:** Live status reduces player frustration from joining offline servers.

**Impact:** Shows real-time player count, encouraging joins when active.

**Success metric:** API responds in <500ms with accurate status.

## Technical Considerations

**Constraints:**
- Use mcstatus.io API (not minecraft-server-util)
- Cache TTL: 30 seconds
- Graceful offline handling

## Dependencies

**Depends on:** Story 01 (Hono server)
**Enables:** Epic 004 (ServerStatus widget)

## Traceability

**Parent epic:** .storyline/epics/epic-003-backend-api-services.md
