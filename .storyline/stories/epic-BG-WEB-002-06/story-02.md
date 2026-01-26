---
story_id: 02
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Add Audit Logging
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-06-polish-security.md
created: 2026-01-25
---

# Story 02: Add Audit Logging

## User Story

**As a** system administrator,
**I want** sensitive actions to be logged,
**so that** I can audit who did what and when.

## Acceptance Criteria

### Scenario 1: Login events logged
**Given** a user successfully logs in
**When** the authentication completes
**Then** an audit log entry is created
**And** it includes user, timestamp, and IP

### Scenario 2: Logout events logged
**Given** a user logs out
**When** the session ends
**Then** an audit log entry is created

### Scenario 3: Server start logged
**Given** a user starts the server
**When** the action completes
**Then** an audit log entry is created
**And** it includes user and action details

### Scenario 4: Server stop logged
**Given** a user stops the server
**When** the action completes
**Then** an audit log entry is created
**And** it includes user and action details

### Scenario 5: RCON commands logged
**Given** a user executes an RCON command
**When** the command completes
**Then** an audit log entry is created
**And** it includes user, command, and arguments

### Scenario 6: Logs stored in KV
**Given** audit logs are created
**When** they are stored
**Then** they are saved to Cloudflare KV
**And** they have a 90-day TTL

### Scenario 7: Failed login attempts logged
**Given** an unauthorized user attempts to log in
**When** the authentication fails
**Then** an audit log entry is created
**And** it indicates failed authentication

## Business Value

**Why this matters:** Audit logs provide accountability and help with incident response. They're essential for understanding system usage and detecting anomalies.

**Impact:** Enables security monitoring and compliance.

**Success metric:** All sensitive actions are logged with user attribution.

## Technical Considerations

**Audit Log Interface:**
```typescript
// src/lib/audit.ts
export interface AuditLog {
  id: string
  timestamp: string
  userId: string
  githubUsername: string
  action: "login" | "logout" | "login_failed" | "server_start" | "server_stop" | "rcon_command"
  details?: Record<string, unknown>
  ip?: string
  userAgent?: string
  success: boolean
}

export async function logAuditEvent(
  kv: KVNamespace,
  event: Omit<AuditLog, "id" | "timestamp">
): Promise<void> {
  const log: AuditLog = {
    ...event,
    id: crypto.randomUUID(),
    timestamp: new Date().toISOString(),
  }

  const key = `audit:${log.timestamp}:${log.id}`
  await kv.put(key, JSON.stringify(log), {
    expirationTtl: 90 * 24 * 60 * 60, // 90 days
  })

  // Also log to console for real-time visibility
  console.log(`[AUDIT] ${log.action} by ${log.githubUsername}: ${JSON.stringify(log.details)}`)
}
```

**Usage in API Routes:**
```typescript
// In start server API
await logAuditEvent(env.KV, {
  userId: session.user.id,
  githubUsername: session.user.name,
  action: "server_start",
  details: { instanceId, previousState },
  ip: request.headers.get("CF-Connecting-IP") || undefined,
  userAgent: request.headers.get("User-Agent") || undefined,
  success: true,
})
```

**KV Storage:**
- Key format: `audit:{timestamp}:{uuid}`
- TTL: 90 days (7,776,000 seconds)
- Consider prefix scan for log retrieval

## Dependencies

**Depends on stories:**
- Epic 1: Authentication (user info)
- Epic 1: Cloudflare KV setup

**Enables stories:**
- Story 05: Security Audit

## Out of Scope

- Audit log viewer UI
- Log export functionality
- Real-time log streaming
- Log retention beyond 90 days

## Notes

- Console logging provides immediate visibility
- KV provides persistence and durability
- Consider using Cloudflare Analytics or Workers Analytics Endpoints for production
- IP address captured via CF-Connecting-IP header

## Traceability

**Parent epic:** [epic-BG-WEB-002-06-polish-security.md](../../epics/epic-BG-WEB-002-06-polish-security.md)

**Related stories:** Story 05 (Security Audit)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-06/story-02.md`
