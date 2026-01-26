// src/pages/api/admin/server/stop.ts
// Stop server API endpoint
//
// Stops the EC2 instance gracefully. Protected by auth middleware.
// Uses graceful shutdown (not force) to allow Minecraft to save world data.

import type { APIRoute } from "astro";
import { StopInstancesCommand } from "@aws-sdk/client-ec2";
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
    const command = new StopInstancesCommand({
      InstanceIds: [instanceId],
      // Force: false (default) - allows graceful shutdown
      // This gives Minecraft time to save the world before the instance stops
    });

    const response = await ec2Client.send(command);
    const stateChange = response.StoppingInstances?.[0];
    const currentState = stateChange?.CurrentState?.Name;
    const previousState = stateChange?.PreviousState?.Name;

    // Log the action to KV
    await audit.log("server_stop", true, {
      previousState,
      currentState,
      instanceId,
    });

    // Determine message based on state
    let message: string;
    if (currentState === "stopped") {
      message = "Server is already stopped";
    } else if (currentState === "stopping") {
      message = "Server is stopping. World data is being saved.";
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
    await audit.log("server_stop", false, {
      error: error instanceof Error ? error.message : "Unknown error",
      instanceId,
    });

    return new Response(
      JSON.stringify({
        success: false,
        error: "Failed to stop server",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
