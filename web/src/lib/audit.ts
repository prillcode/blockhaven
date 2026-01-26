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
