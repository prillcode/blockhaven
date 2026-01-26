// src/types/auth.ts
// Type definitions for authentication

import type { Session } from "@auth/core/types";

/**
 * Extended session type with GitHub username
 */
export interface AdminSession extends Session {
  user: {
    name?: string | null;
    email?: string | null;
    image?: string | null;
    githubUsername?: string;
  };
}

/**
 * Environment variables for authentication
 */
export interface AuthEnv {
  AUTH_SECRET: string;
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
  ADMIN_GITHUB_USERNAMES: string;
  AUTH_TRUST_HOST?: string;
}
