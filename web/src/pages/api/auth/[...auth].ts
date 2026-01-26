// src/pages/api/auth/[...auth].ts
// Auth.js catch-all API route handler
//
// This route handles all Auth.js endpoints:
// - GET  /api/auth/signin/github  - Initiates GitHub OAuth flow
// - GET  /api/auth/callback/github - Handles OAuth callback
// - GET  /api/auth/session - Returns current session
// - POST /api/auth/signout - Signs out user

import { Auth } from "@auth/core";
import type { APIRoute } from "astro";
import { authConfig } from "../../../lib/auth";

export const GET: APIRoute = async ({ request }) => {
  return Auth(request, authConfig);
};

export const POST: APIRoute = async ({ request }) => {
  return Auth(request, authConfig);
};
