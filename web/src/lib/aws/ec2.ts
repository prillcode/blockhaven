// src/lib/aws/ec2.ts
// AWS EC2 client configuration for server management
//
// This module provides a configured EC2Client for use in API routes.
// The client uses credentials from environment variables and is compatible
// with Cloudflare Workers runtime.

import { EC2Client } from "@aws-sdk/client-ec2";

/**
 * Configured EC2 client for server management operations.
 *
 * Uses credentials from environment variables:
 * - AWS_ACCESS_KEY_ID
 * - AWS_SECRET_ACCESS_KEY
 * - AWS_REGION
 *
 * Compatible with Cloudflare Workers runtime (no Node.js dependencies).
 */
export function getEC2Client(): EC2Client {
  return new EC2Client({
    region: import.meta.env.AWS_REGION || "us-east-2",
    credentials: {
      accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
    },
  });
}

/**
 * Get the EC2 instance ID from environment.
 */
export function getInstanceId(): string {
  const instanceId = import.meta.env.EC2_INSTANCE_ID;
  if (!instanceId) {
    throw new Error("EC2_INSTANCE_ID environment variable is not set");
  }
  return instanceId;
}

/**
 * EC2 instance states
 */
export type EC2State =
  | "pending"
  | "running"
  | "shutting-down"
  | "terminated"
  | "stopping"
  | "stopped";

/**
 * Normalized server status response
 */
export interface ServerStatus {
  state: EC2State;
  publicIp: string | null;
  instanceId: string;
  launchTime: string | null;
  uptimeSeconds: number | null;
}
