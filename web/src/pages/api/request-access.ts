// src/pages/api/request-access.ts
// Epic 4: Request Access Form - Email submission via Resend
//
// This is a placeholder API endpoint to validate that API routes work correctly
// with the Cloudflare adapter and hybrid rendering. In Epic 4, this will be
// implemented to handle form submissions from the /request-access page and send
// emails via the Resend API.

import type { APIRoute } from 'astro';

/**
 * Handle POST requests to /api/request-access
 *
 * Future implementation (Epic 4):
 * - Parse JSON body with { minecraft_username, email, reason }
 * - Validate input (required fields, email format, username format)
 * - Send email to admin via Resend API
 * - Return success/error response
 *
 * @param request - Incoming HTTP request
 * @returns JSON response with success/error message
 */
export const POST: APIRoute = async ({ request }) => {
  // TODO: Implement in Epic 4 (Request Form & API Integration)
  //
  // Steps:
  // 1. Parse request body: const data = await request.json()
  // 2. Validate required fields: minecraft_username, email, reason
  // 3. Validate email format with regex
  // 4. Validate Minecraft username (3-16 chars, alphanumeric + underscore)
  // 5. Send email via Resend:
  //    - To: import.meta.env.ADMIN_EMAIL
  //    - From: noreply@bhsmp.com
  //    - Subject: "New Access Request from {username}"
  //    - Body: Include username, email, reason
  // 6. Return { success: true, message: "Request submitted" } on success
  // 7. Return { success: false, error: "..." } on failure

  console.log('API route placeholder - POST /api/request-access called');

  return new Response(
    JSON.stringify({
      message: "API endpoint placeholder - Implement in Epic 4",
      status: "not_implemented"
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    }
  );
};
