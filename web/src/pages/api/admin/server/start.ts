// src/pages/api/admin/server/start.ts
// Start server API endpoint
//
// Starts the EC2 instance. Protected by auth middleware.
// Returns immediately; use status endpoint to poll for state changes.

import type { APIRoute } from "astro";
import { StartInstancesCommand } from "@aws-sdk/client-ec2";
import { getEC2Client, getInstanceId } from "../../../../lib/aws";
import { getSession } from "../../../../lib/auth-helpers";
import { createAuditLogger } from "../../../../lib/audit";

export const POST: APIRoute = async ({ request, locals }) => {
  const ec2Client = getEC2Client();
  const instanceId = getInstanceId();

  // Get session for audit logging
  const session = await getSession(request);
  const kv = (locals as any).runtime?.env?.BLOCKHAVEN_AUDIT;
  const audit = createAuditLogger(kv, request, session?.user || {});

  try {
    const command = new StartInstancesCommand({
      InstanceIds: [instanceId],
    });

    const response = await ec2Client.send(command);
    const stateChange = response.StartingInstances?.[0];
    const currentState = stateChange?.CurrentState?.Name;
    const previousState = stateChange?.PreviousState?.Name;

    // Log the action to KV
    await audit.log("server_start", true, {
      previousState,
      currentState,
      instanceId,
    });

    // Determine message based on state
    let message: string;
    if (currentState === "running") {
      message = "Server is already running";
    } else if (currentState === "pending") {
      message = "Server is starting. This may take 30-60 seconds.";
    } else {
      message = `Server state changed to ${currentState}`;
    }

    return new Response(
      JSON.stringify({
        success: true,
        message,
        currentState,
        previousState,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    await audit.log("server_start", false, {
      error: error instanceof Error ? error.message : "Unknown error",
      instanceId,
    });

    return new Response(
      JSON.stringify({
        success: false,
        error: "Failed to start server",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
