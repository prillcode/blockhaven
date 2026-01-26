// src/middleware.ts
// Astro middleware for authentication and route protection
//
// Protects:
// - /dashboard* routes -> redirect to /login
// - /api/admin/* routes -> return 401 JSON
//
// Allows:
// - All other routes (public marketing pages)
// - /api/auth/* (Auth.js endpoints)
// - /api/request-access (public form submission)
//
// Rate limiting:
// - Applies per-user rate limits to /api/admin/* routes
// - Uses Cloudflare KV for distributed rate limit storage

import { defineMiddleware } from "astro:middleware";
import { getSession } from "./lib/auth-helpers";
import {
  checkRateLimit,
  rateLimitExceededResponse,
  rateLimitHeaders,
} from "./lib/rateLimit";

/**
 * Routes that require authentication
 */
const PROTECTED_PAGE_PREFIXES = ["/dashboard"];
const PROTECTED_API_PREFIXES = ["/api/admin"];

/**
 * Check if a path starts with any of the given prefixes
 */
function startsWithAny(path: string, prefixes: string[]): boolean {
  return prefixes.some((prefix) => path === prefix || path.startsWith(prefix + "/"));
}

export const onRequest = defineMiddleware(async (context, next) => {
  const { request, redirect, locals } = context;
  const url = new URL(request.url);
  const path = url.pathname;

  // Check if this is a protected page route
  const isProtectedPage = startsWithAny(path, PROTECTED_PAGE_PREFIXES);

  // Check if this is a protected API route
  const isProtectedApi = startsWithAny(path, PROTECTED_API_PREFIXES);

  // If not a protected route, pass through
  if (!isProtectedPage && !isProtectedApi) {
    return next();
  }

  // Check for valid session
  const session = await getSession(request);

  if (!session || !session.user) {
    // No valid session - handle based on route type
    if (isProtectedApi) {
      // API routes return 401 JSON
      return new Response(
        JSON.stringify({
          error: "Unauthorized",
          message: "Authentication required to access this endpoint",
        }),
        {
          status: 401,
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
    } else {
      // Page routes redirect to login
      // Preserve the original URL for redirect after login (future enhancement)
      const loginUrl = new URL("/login", url.origin);
      return redirect(loginUrl.toString(), 302);
    }
  }

  // Rate limiting (only for API routes)
  if (isProtectedApi) {
    const kv = (locals as any).runtime?.env?.BLOCKHAVEN_RATE_LIMITS;

    if (kv) {
      const userId = session.user.githubUsername || session.user.email || "unknown";
      const result = await checkRateLimit(kv, userId, path);

      if (!result.allowed) {
        return rateLimitExceededResponse(result);
      }

      // Add rate limit headers to response
      const response = await next();
      const newHeaders = new Headers(response.headers);
      for (const [key, value] of Object.entries(rateLimitHeaders(result))) {
        newHeaders.set(key, value);
      }
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: newHeaders,
      });
    }
  }

  // Session is valid, proceed with the request
  // Optionally, you can attach session to context.locals here
  // context.locals.session = session;

  return next();
});
