// src/pages/api/admin/rcon.ts
// RCON command execution API endpoint
//
// Executes whitelisted RCON commands via AWS SSM.
// Protected by auth middleware.

import type { APIRoute } from "astro";
import {
  executeRconCommand,
  validateCommand,
  type AllowedCommand,
} from "../../../lib/aws/rcon";
import { getSession } from "../../../lib/auth-helpers";
import { createAuditLogger } from "../../../lib/audit";

export const POST: APIRoute = async ({ request, locals }) => {
  // Get session for audit logging
  const session = await getSession(request);
  const kv = (locals as any).runtime?.env?.BLOCKHAVEN_AUDIT;
  const audit = createAuditLogger(kv, request, session?.user || {});

  let command: string | undefined;
  let args: string | undefined;

  try {
    // Parse request body
    const body = await request.json();
    command = body.command as string;
    args = body.args as string | undefined;

    if (!command) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Command is required",
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Validate command and arguments
    const validation = validateCommand(command, args);
    if (!validation.valid) {
      return new Response(
        JSON.stringify({
          success: false,
          error: validation.error,
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Execute the command
    const output = await executeRconCommand(command as AllowedCommand, args);

    // Log successful command to KV
    await audit.log("rcon_command", true, {
      command,
      args,
      output: output.substring(0, 200), // Truncate long output
    });

    return new Response(
      JSON.stringify({
        success: true,
        output,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    await audit.log("rcon_command", false, {
      command,
      args,
      error: error instanceof Error ? error.message : "Unknown error",
    });

    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Command execution failed",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
