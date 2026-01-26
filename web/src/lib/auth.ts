// src/lib/auth.ts
// Auth.js configuration for GitHub OAuth with multi-user authorization
//
// This module configures authentication using GitHub OAuth. Only users
// whose GitHub usernames are listed in ADMIN_GITHUB_USERNAMES can sign in.

import GitHub from "@auth/core/providers/github";
import type { AuthConfig } from "@auth/core/types";

/**
 * Parse comma-separated usernames from environment variable.
 * Handles whitespace, empty values, and normalizes to lowercase.
 */
function getAuthorizedUsers(): string[] {
  const usernames = import.meta.env.ADMIN_GITHUB_USERNAMES || "";
  return usernames
    .split(",")
    .map((u: string) => u.trim().toLowerCase())
    .filter(Boolean);
}

/**
 * Auth.js configuration
 */
export const authConfig: AuthConfig = {
  providers: [
    GitHub({
      clientId: import.meta.env.GITHUB_CLIENT_ID,
      clientSecret: import.meta.env.GITHUB_CLIENT_SECRET,
    }),
  ],

  session: {
    strategy: "jwt",
    maxAge: 7 * 24 * 60 * 60, // 7 days in seconds
  },

  callbacks: {
    /**
     * signIn callback - runs when user attempts to sign in.
     * Returns true to allow sign in, false to reject.
     */
    async signIn({ profile }) {
      const authorizedUsers = getAuthorizedUsers();
      const githubUsername = (profile?.login as string)?.toLowerCase();

      if (!githubUsername) {
        console.log("[Auth] Sign-in rejected: No GitHub username in profile");
        return false;
      }

      const isAuthorized = authorizedUsers.includes(githubUsername);

      // Log the attempt (KV not available in auth callback, use console only)
      console.log(
        `[AUDIT] ${isAuthorized ? "login" : "login_failed"} by ${githubUsername} at ${new Date().toISOString()}`
      );

      return isAuthorized;
    },

    /**
     * jwt callback - runs when JWT is created or updated.
     * Add GitHub username to token for later use.
     */
    async jwt({ token, profile }) {
      if (profile) {
        token.githubUsername = (profile.login as string)?.toLowerCase();
      }
      return token;
    },

    /**
     * session callback - runs when session is checked.
     * Add GitHub username to session for client access.
     */
    async session({ session, token }) {
      if (token.githubUsername) {
        (session.user as any).githubUsername = token.githubUsername;
      }
      return session;
    },

    /**
     * redirect callback - controls where users are sent after auth events.
     * Used to redirect to homepage after signout, and to dashboard after signin.
     */
    async redirect({ url, baseUrl }) {
      // After signout, redirect to homepage
      if (url.includes("signout")) {
        return baseUrl;
      }
      // After signin, redirect to dashboard
      if (url.includes("callback")) {
        return `${baseUrl}/dashboard`;
      }
      // Default: same origin only
      if (url.startsWith(baseUrl)) {
        return url;
      }
      return baseUrl;
    },
  },

  pages: {
    signIn: "/login",
    error: "/login", // Redirect to login page on error with ?error= param
  },

  // Trust the host header (required for Cloudflare Workers)
  trustHost: true,
};
