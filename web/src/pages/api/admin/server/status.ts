// src/pages/api/admin/server/status.ts
// Server status API endpoint
//
// Returns combined EC2 instance status and Minecraft server status.
// Protected by auth middleware (requires authentication).

import type { APIRoute } from "astro";
import { DescribeInstancesCommand } from "@aws-sdk/client-ec2";
import { getEC2Client, getInstanceId } from "../../../../lib/aws";
import { getMinecraftStatus } from "../../../../lib/minecraft";

export const GET: APIRoute = async () => {
  const ec2Client = getEC2Client();
  const instanceId = getInstanceId();
  const mcServerAddress = import.meta.env.MC_SERVER_IP || "play.bhsmp.com";

  try {
    // Query EC2 for instance status
    const command = new DescribeInstancesCommand({
      InstanceIds: [instanceId],
    });
    const response = await ec2Client.send(command);
    const instance = response.Reservations?.[0]?.Instances?.[0];

    if (!instance) {
      return new Response(
        JSON.stringify({
          error: "Instance not found",
          instanceId,
        }),
        {
          status: 404,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Extract EC2 status
    const state = instance.State?.Name || "unknown";
    const publicIp = instance.PublicIpAddress || null;
    const launchTime = instance.LaunchTime?.toISOString() || null;

    // Calculate uptime in seconds
    let uptimeSeconds: number | null = null;
    if (launchTime && state === "running") {
      uptimeSeconds = Math.floor((Date.now() - new Date(launchTime).getTime()) / 1000);
    }

    // Get Minecraft status only if EC2 is running
    let minecraft = null;
    if (state === "running" && publicIp) {
      minecraft = await getMinecraftStatus(mcServerAddress);
    }

    // Return combined status
    return new Response(
      JSON.stringify({
        ec2: {
          state,
          publicIp,
          instanceId: instance.InstanceId,
          launchTime,
          uptimeSeconds,
        },
        minecraft,
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("[Status API] Error:", error);

    return new Response(
      JSON.stringify({
        error: "Failed to get server status",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
