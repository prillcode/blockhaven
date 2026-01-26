// src/lib/auth-helpers.ts
// Helper functions for authentication in Astro pages and API routes

import { Auth } from "@auth/core";
import { authConfig } from "./auth";

/**
 * Get the current session from a request.
 * Use this in SSR pages and API routes to check authentication.
 *
 * @param request - The incoming HTTP request
 * @returns Session object or null if not authenticated
 */
export async function getSession(request: Request) {
  // If AUTH_SECRET is not configured, auth is disabled
  if (!import.meta.env.AUTH_SECRET) {
    return null;
  }

  try {
    const sessionUrl = new URL("/api/auth/session", request.url);
    const sessionRequest = new Request(sessionUrl, {
      headers: request.headers,
    });

    const response = await Auth(sessionRequest, authConfig);
    const session = await response.json();

    // Auth.js returns {} for no session, not null
    if (!session || Object.keys(session).length === 0) {
      return null;
    }

    return session as {
      user: {
        name?: string;
        email?: string;
        image?: string;
        githubUsername?: string;
      };
      expires: string;
    };
  } catch (error) {
    // Auth.js throws when not properly configured - treat as no session
    console.warn("[auth] Session check failed:", error instanceof Error ? error.message : error);
    return null;
  }
}

/**
 * Check if a session is valid (exists and not expired).
 */
export function isSessionValid(session: Awaited<ReturnType<typeof getSession>>): boolean {
  if (!session) return false;
  const expires = new Date(session.expires);
  return expires > new Date();
}
