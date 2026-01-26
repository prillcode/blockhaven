// src/lib/aws/rcon.ts
// AWS SSM integration for RCON command execution
//
// Uses AWS SSM Run Command to execute RCON commands on the EC2 instance.
// Commands are strictly whitelisted to prevent abuse.

import {
  SSMClient,
  SendCommandCommand,
  GetCommandInvocationCommand,
} from "@aws-sdk/client-ssm";

/**
 * Allowed RCON commands (whitelist)
 */
export const ALLOWED_COMMANDS = [
  "whitelist add",
  "whitelist remove",
  "whitelist list",
  "list",
  "save-all",
  "say",
] as const;

export type AllowedCommand = (typeof ALLOWED_COMMANDS)[number];

/**
 * Commands that require arguments
 */
const COMMANDS_WITH_ARGS: Record<string, { required: boolean; pattern: RegExp; example: string }> = {
  "whitelist add": {
    required: true,
    pattern: /^[a-zA-Z0-9_]{3,16}$/,
    example: "PlayerName",
  },
  "whitelist remove": {
    required: true,
    pattern: /^[a-zA-Z0-9_]{3,16}$/,
    example: "PlayerName",
  },
  "say": {
    required: true,
    pattern: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/,
    example: "Hello everyone!",
  },
};

/**
 * Get configured SSM client
 */
function getSSMClient(): SSMClient {
  return new SSMClient({
    region: import.meta.env.AWS_REGION || "us-east-2",
    credentials: {
      accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
    },
  });
}

/**
 * Validate command and arguments
 */
export function validateCommand(
  command: string,
  args?: string
): { valid: boolean; error?: string } {
  // Check command is allowed
  if (!ALLOWED_COMMANDS.includes(command as AllowedCommand)) {
    return {
      valid: false,
      error: `Command not allowed. Allowed commands: ${ALLOWED_COMMANDS.join(", ")}`,
    };
  }

  // Check arguments if required
  const argConfig = COMMANDS_WITH_ARGS[command];
  if (argConfig) {
    if (argConfig.required && !args) {
      return {
        valid: false,
        error: `This command requires an argument. Example: ${argConfig.example}`,
      };
    }
    if (args && !argConfig.pattern.test(args)) {
      return {
        valid: false,
        error: `Invalid argument format. Example: ${argConfig.example}`,
      };
    }
  } else if (args) {
    // Command doesn't accept arguments
    return {
      valid: false,
      error: "This command does not accept arguments",
    };
  }

  return { valid: true };
}

/**
 * Execute RCON command via AWS SSM
 *
 * @param command - RCON command (must be in whitelist)
 * @param args - Command arguments (optional, validated)
 * @returns Command output from RCON
 */
export async function executeRconCommand(
  command: AllowedCommand,
  args?: string
): Promise<string> {
  const ssmClient = getSSMClient();
  const instanceId = import.meta.env.EC2_INSTANCE_ID;

  if (!instanceId) {
    throw new Error("EC2_INSTANCE_ID not configured");
  }

  // Build the full RCON command
  const fullCommand = args ? `${command} ${args}` : command;

  // Docker command to execute RCON
  const dockerCommand = `docker exec blockhaven-mc rcon-cli ${fullCommand}`;

  // Send command via SSM
  const sendCommand = new SendCommandCommand({
    InstanceIds: [instanceId],
    DocumentName: "AWS-RunShellScript",
    Parameters: {
      commands: [dockerCommand],
    },
    TimeoutSeconds: 30,
  });

  const sendResponse = await ssmClient.send(sendCommand);
  const commandId = sendResponse.Command?.CommandId;

  if (!commandId) {
    throw new Error("Failed to send command - no command ID returned");
  }

  // Wait for command to complete (poll for result)
  await sleep(1500); // Initial wait for command to execute

  const maxAttempts = 10;
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const getResult = new GetCommandInvocationCommand({
      CommandId: commandId,
      InstanceId: instanceId,
    });

    try {
      const result = await ssmClient.send(getResult);

      if (result.Status === "Success") {
        return result.StandardOutputContent?.trim() || "Command executed successfully";
      }

      if (result.Status === "Failed") {
        throw new Error(result.StandardErrorContent || "Command execution failed");
      }

      if (result.Status === "InProgress" || result.Status === "Pending") {
        await sleep(1000);
        continue;
      }

      // Other status (Cancelled, TimedOut, etc.)
      throw new Error(`Command ${result.Status}: ${result.StatusDetails}`);
    } catch (error) {
      // InvocationDoesNotExist means command hasn't started yet
      if ((error as any)?.name === "InvocationDoesNotExist") {
        await sleep(1000);
        continue;
      }
      throw error;
    }
  }

  throw new Error("Command timed out waiting for result");
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
