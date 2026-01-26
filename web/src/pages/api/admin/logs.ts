// src/pages/api/admin/logs.ts
// Server logs API endpoint
//
// Returns Minecraft server logs from CloudWatch.
// Protected by auth middleware.

import type { APIRoute } from "astro";
import { getServerLogs } from "../../../lib/aws/logs";

// Valid line counts
const VALID_COUNTS = [100, 250, 500];

export const GET: APIRoute = async ({ request }) => {
  const url = new URL(request.url);
  const countParam = url.searchParams.get("count");
  const count = countParam ? parseInt(countParam, 10) : 100;

  // Validate count
  if (!VALID_COUNTS.includes(count)) {
    return new Response(
      JSON.stringify({
        error: `Invalid count. Must be one of: ${VALID_COUNTS.join(", ")}`,
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      }
    );
  }

  try {
    const logs = await getServerLogs(count);

    return new Response(
      JSON.stringify({
        logs,
        count: logs.length,
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("[Logs API] Error:", error);

    // Handle "not configured" gracefully
    if ((error as Error).message === "Log group not configured") {
      return new Response(
        JSON.stringify({
          logs: [],
          count: 0,
          message: "CloudWatch logs not configured. See setup documentation.",
          timestamp: new Date().toISOString(),
        }),
        {
          status: 200,  // Not an error - just not configured
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    return new Response(
      JSON.stringify({
        error: "Failed to fetch logs",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 503,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
