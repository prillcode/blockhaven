// src/lib/rateLimit.ts
// Rate limiting using Cloudflare KV
//
// Implements sliding window rate limiting per user per endpoint.
// Stores counts in Cloudflare KV with automatic expiration.

/**
 * Rate limit configuration per endpoint
 */
export const RATE_LIMITS: Record<string, { windowMs: number; max: number }> = {
  "/api/admin/server/status": { windowMs: 60000, max: 120 },  // 120/min
  "/api/admin/server/start": { windowMs: 60000, max: 5 },     // 5/min
  "/api/admin/server/stop": { windowMs: 60000, max: 5 },      // 5/min
  "/api/admin/logs": { windowMs: 60000, max: 30 },            // 30/min
  "/api/admin/rcon": { windowMs: 60000, max: 10 },            // 10/min
};

/**
 * Default rate limit for unspecified admin endpoints
 */
const DEFAULT_LIMIT = { windowMs: 60000, max: 60 };  // 60/min

/**
 * Rate limit check result
 */
export interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetAt: number;       // Unix timestamp (ms)
  limit: number;
}

/**
 * Check rate limit for a user and endpoint
 *
 * @param kv - Cloudflare KV namespace
 * @param userId - User identifier (from session)
 * @param endpoint - API endpoint path
 * @returns Rate limit result
 */
export async function checkRateLimit(
  kv: KVNamespace,
  userId: string,
  endpoint: string
): Promise<RateLimitResult> {
  const config = RATE_LIMITS[endpoint] || DEFAULT_LIMIT;

  // Calculate window start (floor to window boundary)
  const windowStart = Math.floor(Date.now() / config.windowMs) * config.windowMs;
  const resetAt = windowStart + config.windowMs;

  // Build key
  const key = `ratelimit:${userId}:${endpoint}:${windowStart}`;

  // Get current count
  const currentStr = await kv.get(key);
  const current = currentStr ? parseInt(currentStr, 10) : 0;

  // Check if over limit
  if (current >= config.max) {
    return {
      allowed: false,
      remaining: 0,
      resetAt,
      limit: config.max,
    };
  }

  // Increment count
  const newCount = current + 1;
  const ttlSeconds = Math.ceil(config.windowMs / 1000) + 60; // Extra buffer

  await kv.put(key, String(newCount), {
    expirationTtl: ttlSeconds,
  });

  return {
    allowed: true,
    remaining: config.max - newCount,
    resetAt,
    limit: config.max,
  };
}

/**
 * Create rate limit response headers
 */
export function rateLimitHeaders(result: RateLimitResult): Record<string, string> {
  return {
    "X-RateLimit-Limit": String(result.limit),
    "X-RateLimit-Remaining": String(result.remaining),
    "X-RateLimit-Reset": String(Math.ceil(result.resetAt / 1000)),
    ...(result.allowed ? {} : {
      "Retry-After": String(Math.ceil((result.resetAt - Date.now()) / 1000)),
    }),
  };
}

/**
 * Create 429 Too Many Requests response
 */
export function rateLimitExceededResponse(result: RateLimitResult): Response {
  const retryAfter = Math.ceil((result.resetAt - Date.now()) / 1000);

  return new Response(
    JSON.stringify({
      error: "Too Many Requests",
      message: `Rate limit exceeded. Try again in ${retryAfter} seconds.`,
      retryAfter,
    }),
    {
      status: 429,
      headers: {
        "Content-Type": "application/json",
        ...rateLimitHeaders(result),
      },
    }
  );
}
