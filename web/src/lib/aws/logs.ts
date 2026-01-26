// src/lib/aws/logs.ts
// CloudWatch Logs integration for Minecraft server logs

import {
  CloudWatchLogsClient,
  GetLogEventsCommand,
  DescribeLogStreamsCommand,
} from "@aws-sdk/client-cloudwatch-logs";

/**
 * Log entry from CloudWatch
 */
export interface LogEntry {
  timestamp: string;
  message: string;
  level: "INFO" | "WARN" | "ERROR" | "DEBUG";
}

/**
 * Get configured CloudWatch Logs client
 */
function getLogsClient(): CloudWatchLogsClient {
  return new CloudWatchLogsClient({
    region: import.meta.env.AWS_REGION || "us-east-2",
    credentials: {
      accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
    },
  });
}

/**
 * Parse log level from message content
 */
function parseLogLevel(message: string): LogEntry["level"] {
  const upper = message.toUpperCase();
  if (upper.includes("[ERROR]") || upper.includes("ERROR:") || upper.includes(" ERROR ")) {
    return "ERROR";
  }
  if (upper.includes("[WARN]") || upper.includes("WARN:") || upper.includes(" WARN ")) {
    return "WARN";
  }
  if (upper.includes("[DEBUG]") || upper.includes("DEBUG:")) {
    return "DEBUG";
  }
  return "INFO";
}

/**
 * Fetch server logs from CloudWatch
 *
 * @param lineCount - Number of log lines to fetch (default 100)
 * @returns Array of log entries, newest last
 */
export async function getServerLogs(lineCount: number = 100): Promise<LogEntry[]> {
  const logsClient = getLogsClient();
  const logGroupName = import.meta.env.CLOUDWATCH_LOG_GROUP || "blockhaven-minecraft";

  try {
    // Find the latest log stream
    const streamsCommand = new DescribeLogStreamsCommand({
      logGroupName,
      orderBy: "LastEventTime",
      descending: true,
      limit: 1,
    });

    const streamsResponse = await logsClient.send(streamsCommand);
    const latestStream = streamsResponse.logStreams?.[0];

    if (!latestStream?.logStreamName) {
      console.log("[Logs] No log streams found in group:", logGroupName);
      return [];
    }

    // Fetch log events
    const eventsCommand = new GetLogEventsCommand({
      logGroupName,
      logStreamName: latestStream.logStreamName,
      limit: lineCount,
      startFromHead: false,  // Get most recent logs
    });

    const eventsResponse = await logsClient.send(eventsCommand);

    // Transform to LogEntry format
    const logs: LogEntry[] = (eventsResponse.events || []).map((event) => ({
      timestamp: event.timestamp
        ? new Date(event.timestamp).toISOString()
        : new Date().toISOString(),
      message: event.message || "",
      level: parseLogLevel(event.message || ""),
    }));

    // Events come in reverse order (newest first), reverse to show oldest first
    return logs.reverse();
  } catch (error) {
    // Check for common errors
    if ((error as any)?.name === "ResourceNotFoundException") {
      console.log("[Logs] Log group not found:", logGroupName);
      throw new Error("Log group not configured");
    }
    throw error;
  }
}
