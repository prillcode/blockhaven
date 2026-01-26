---
spec_id: 02
story_ids: [02]
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Add Audit Logging for Sensitive Actions
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BG-WEB-002-06/story-02.md
created: 2026-01-25
---

# Technical Spec 02: Add Audit Logging

## Overview

**User story:** [Story 02: Add Audit Logging](../../stories/epic-BG-WEB-002-06/story-02.md)

**Goal:** Log sensitive actions (login, logout, server start/stop, RCON commands) to Cloudflare KV with user attribution and timestamps for security auditing.

**Approach:** Create an audit logging module that writes structured log entries to KV with 90-day TTL. Integrate into auth callbacks and API routes.

## Technical Design

### Audit Log Structure

```typescript
interface AuditLog {
  id: string;            // UUID
  timestamp: string;     // ISO 8601
  userId: string;        // GitHub username or ID
  action: AuditAction;   // login, logout, server_start, etc.
  details?: Record<string, unknown>;  // Action-specific data
  ip?: string;           // Client IP (from CF-Connecting-IP)
  userAgent?: string;    // Client user agent
  success: boolean;      // Action succeeded or failed
}

type AuditAction =
  | "login"
  | "login_failed"
  | "logout"
  | "server_start"
  | "server_stop"
  | "rcon_command";
```

### Storage

- **Location:** Cloudflare KV namespace `BLOCKHAVEN_AUDIT`
- **Key format:** `audit:{timestamp}:{uuid}`
- **TTL:** 90 days (7,776,000 seconds)
- **Ordering:** Timestamp-prefixed keys enable range queries

## Implementation Details

### Files to Create

#### 1. Audit Logging Module

**`web/src/lib/audit.ts`**

```typescript
// src/lib/audit.ts
// Audit logging for security-sensitive actions
//
// Logs are stored in Cloudflare KV with 90-day retention.
// All sensitive actions should call logAuditEvent().

/**
 * Audit action types
 */
export type AuditAction =
  | "login"
  | "login_failed"
  | "logout"
  | "server_start"
  | "server_stop"
  | "rcon_command";

/**
 * Audit log entry
 */
export interface AuditLog {
  id: string;
  timestamp: string;
  userId: string;
  githubUsername: string;
  action: AuditAction;
  details?: Record<string, unknown>;
  ip?: string;
  userAgent?: string;
  success: boolean;
}

/**
 * Input for creating audit log
 */
export interface AuditLogInput {
  userId: string;
  githubUsername: string;
  action: AuditAction;
  details?: Record<string, unknown>;
  ip?: string;
  userAgent?: string;
  success: boolean;
}

/**
 * TTL for audit logs (90 days in seconds)
 */
const AUDIT_LOG_TTL = 90 * 24 * 60 * 60;

/**
 * Log an audit event
 *
 * @param kv - Cloudflare KV namespace (BLOCKHAVEN_AUDIT)
 * @param input - Audit log data
 */
export async function logAuditEvent(
  kv: KVNamespace | undefined,
  input: AuditLogInput
): Promise<void> {
  const log: AuditLog = {
    ...input,
    id: crypto.randomUUID(),
    timestamp: new Date().toISOString(),
  };

  // Always log to console for immediate visibility
  const logLevel = input.success ? "INFO" : "WARN";
  console.log(
    `[AUDIT][${logLevel}] ${log.action} by ${log.githubUsername} at ${log.timestamp}` +
    (log.details ? ` - ${JSON.stringify(log.details)}` : "") +
    (log.success ? "" : " (FAILED)")
  );

  // Store in KV if available
  if (kv) {
    const key = `audit:${log.timestamp}:${log.id}`;
    try {
      await kv.put(key, JSON.stringify(log), {
        expirationTtl: AUDIT_LOG_TTL,
      });
    } catch (error) {
      console.error("[AUDIT] Failed to write to KV:", error);
    }
  }
}

/**
 * Helper to extract audit context from request
 */
export function getAuditContext(request: Request): { ip?: string; userAgent?: string } {
  return {
    ip: request.headers.get("CF-Connecting-IP") ||
        request.headers.get("X-Forwarded-For")?.split(",")[0] ||
        undefined,
    userAgent: request.headers.get("User-Agent") || undefined,
  };
}

/**
 * Create audit helper bound to a specific request context
 */
export function createAuditLogger(
  kv: KVNamespace | undefined,
  request: Request,
  user: { id?: string; githubUsername?: string; name?: string }
) {
  const context = getAuditContext(request);
  const userId = user.id || user.githubUsername || user.name || "unknown";
  const githubUsername = user.githubUsername || user.name || "unknown";

  return {
    log: (action: AuditAction, success: boolean, details?: Record<string, unknown>) =>
      logAuditEvent(kv, {
        userId,
        githubUsername,
        action,
        details,
        success,
        ...context,
      }),
  };
}
```

### Files to Modify

#### Update Start Server API

**`web/src/pages/api/admin/server/start.ts`**

```typescript
// Add import
import { createAuditLogger } from "../../../../lib/audit";

export const POST: APIRoute = async ({ request, locals }) => {
  const session = await getSession(request);
  const kv = (locals as any).runtime?.env?.BLOCKHAVEN_AUDIT;
  const audit = createAuditLogger(kv, request, session?.user || {});

  // ... existing code ...

  try {
    // ... start instance ...

    await audit.log("server_start", true, {
      previousState,
      currentState,
      instanceId,
    });

    return new Response(/* ... */);
  } catch (error) {
    await audit.log("server_start", false, {
      error: error instanceof Error ? error.message : "Unknown error",
      instanceId,
    });

    return new Response(/* ... */);
  }
};
```

#### Update Stop Server API

Similar pattern to start - add audit logging for success and failure.

#### Update RCON API

**`web/src/pages/api/admin/rcon.ts`**

```typescript
// Add audit logging
await audit.log("rcon_command", true, {
  command,
  args,
  output: output.substring(0, 200), // Truncate long output
});
```

#### Update Auth Configuration

**`web/src/lib/auth.ts`** - Add logging in callbacks:

```typescript
callbacks: {
  async signIn({ profile, user }) {
    const githubUsername = (profile?.login as string)?.toLowerCase();
    const authorized = authorizedUsers.includes(githubUsername);

    // Log the attempt (KV not available in auth callback, use console only)
    console.log(
      `[AUDIT] ${authorized ? "login" : "login_failed"} by ${githubUsername} at ${new Date().toISOString()}`
    );

    return authorized;
  },
}
```

### Wrangler Configuration

Add audit KV namespace to `wrangler.toml`:

```toml
[[kv_namespaces]]
binding = "BLOCKHAVEN_AUDIT"
id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # Replace with actual KV ID
```

Create namespace:
```bash
wrangler kv:namespace create BLOCKHAVEN_AUDIT
```

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Login events logged | Auth callback + console | Check logs after login |
| Logout events logged | Auth signout callback | Check logs after logout |
| Server start logged | API route + KV | Check KV after start |
| Server stop logged | API route + KV | Check KV after stop |
| RCON commands logged | API route + KV | Check KV after command |
| Failed logins logged | Auth callback | Try unauthorized user |
| 90-day TTL | `expirationTtl` in KV put | Check KV metadata |
| Includes user, timestamp, IP | `AuditLog` structure | Examine log entries |

## Testing Requirements

### Manual Testing

**Check console logs:**
```bash
# Watch Cloudflare logs
wrangler tail

# Perform actions and verify log output:
# [AUDIT][INFO] login by prillcode at 2026-01-25T...
# [AUDIT][INFO] server_start by prillcode at 2026-01-25T...
# [AUDIT][WARN] login_failed by unauthorized at 2026-01-25T... (FAILED)
```

**Check KV storage:**
```bash
# List audit logs
wrangler kv:key list --namespace-id=<AUDIT_NAMESPACE_ID> --prefix="audit:"

# Read specific log
wrangler kv:key get --namespace-id=<AUDIT_NAMESPACE_ID> "audit:2026-01-25T..."
```

### Build Verification

```bash
npm run build
```

Expected: Build succeeds.

## Success Verification

After implementation:

- [ ] Console shows `[AUDIT]` logs for all actions
- [ ] KV stores audit entries with correct structure
- [ ] Entries include user, timestamp, IP, action
- [ ] Failed actions are logged with `success: false`
- [ ] RCON commands include command and args
- [ ] Server start/stop includes state changes

## Traceability

**Parent story:** [Story 02: Add Audit Logging](../../stories/epic-BG-WEB-002-06/story-02.md)

**Parent epic:** [Epic BG-WEB-002-06: Polish & Security](../../epics/epic-BG-WEB-002-06-polish-security.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-06/spec-02-audit-logging.md`
