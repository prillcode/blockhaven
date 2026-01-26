---
spec_id: 01-02-03
story_ids: [01, 02, 03]
epic_id: BG-WEB-002-05
identifier: BG-WEB-002
title: AWS SSM Integration with RCON API and Quick Actions Component
status: ready_for_implementation
complexity: medium
parent_stories:
  - ../../stories/epic-BG-WEB-002-05/story-01.md
  - ../../stories/epic-BG-WEB-002-05/story-02.md
  - ../../stories/epic-BG-WEB-002-05/story-03.md
created: 2026-01-25
---

# Technical Spec 01-02-03: Quick Actions with SSM and RCON

## Overview

**User stories:**
- [Story 01: Setup AWS SSM Integration](../../stories/epic-BG-WEB-002-05/story-01.md)
- [Story 02: Create RCON API Endpoint](../../stories/epic-BG-WEB-002-05/story-02.md)
- [Story 03: Build QuickActions Component](../../stories/epic-BG-WEB-002-05/story-03.md)

**Goal:** Enable executing whitelisted RCON commands (whitelist management, player list, etc.) from the dashboard using AWS SSM Run Command to execute on the EC2 instance.

**Approach:** Install `@aws-sdk/client-ssm`, create helper functions with strict command whitelist, build an API endpoint that validates and executes commands, and create a UI component for selecting and running commands.

## Technical Design

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  Dashboard - QuickActions Component                                  │
│  ├── Command selector dropdown                                      │
│  ├── Argument input (when required)                                 │
│  ├── Execute button                                                 │
│  └── Output display                                                 │
└─────────────────────────────────────┬───────────────────────────────┘
                                      │ POST /api/admin/rcon
                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│  RCON API Endpoint                                                   │
│  ├── Validate command against whitelist                             │
│  ├── Sanitize arguments                                             │
│  └── Execute via AWS SSM                                            │
└─────────────────────────────────────┬───────────────────────────────┘
                                      │ SSM SendCommand
                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│  EC2 Instance                                                        │
│  └── docker exec blockhaven-mc rcon-cli {command}                   │
│      └── Minecraft Server                                           │
└─────────────────────────────────────────────────────────────────────┘
```

### Allowed Commands (Whitelist)

| Command | Arguments | Description |
|---------|-----------|-------------|
| `whitelist add` | `<username>` | Add player to whitelist |
| `whitelist remove` | `<username>` | Remove player from whitelist |
| `whitelist list` | None | Show all whitelisted players |
| `list` | None | Show online players |
| `save-all` | None | Force save all worlds |
| `say` | `<message>` | Broadcast message to all players |

### Security Model

```
Client Input → Whitelist Validation → Argument Sanitization → SSM Execution
     │                │                       │                    │
     │                │                       │                    ▼
     │                │                       │         docker exec rcon-cli
     │                │                       │
     │                │                       ▼
     │                │            Regex: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/
     │                │
     │                ▼
     │    ALLOWED_COMMANDS array check
     │
     ▼
POST body: { command, args }
```

## Implementation Details

### Files to Create

#### 1. SSM/RCON Helper Module

**`web/src/lib/aws/rcon.ts`**

```typescript
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
```

#### 2. Update AWS Index

**`web/src/lib/aws/index.ts`**

```typescript
export { executeRconCommand, validateCommand, ALLOWED_COMMANDS } from "./rcon";
export type { AllowedCommand } from "./rcon";
```

#### 3. RCON API Endpoint

**`web/src/pages/api/admin/rcon.ts`**

```typescript
// src/pages/api/admin/rcon.ts
// RCON command execution API endpoint
//
// Executes whitelisted RCON commands via AWS SSM.
// Protected by auth middleware.

import type { APIRoute } from "astro";
import {
  executeRconCommand,
  validateCommand,
  ALLOWED_COMMANDS,
  type AllowedCommand,
} from "../../../lib/aws/rcon";
import { getSession } from "../../../lib/auth-helpers";

export const POST: APIRoute = async ({ request }) => {
  // Get session for audit logging
  const session = await getSession(request);
  const username = session?.user?.githubUsername || session?.user?.name || "unknown";

  try {
    // Parse request body
    const body = await request.json();
    const { command, args } = body as { command: string; args?: string };

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

    // Log the command (audit)
    console.log(
      `[AUDIT] RCON: "${command}${args ? ` ${args}` : ""}" by ${username} at ${new Date().toISOString()}`
    );

    // Execute the command
    const output = await executeRconCommand(command as AllowedCommand, args);

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
    console.error(`[AUDIT] RCON FAILED by ${username}:`, error);

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
```

#### 4. QuickActions Component

**`web/src/components/admin/QuickActions.tsx`**

```tsx
// src/components/admin/QuickActions.tsx
// Quick actions panel for common server commands

import React, { useState } from "react";

interface QuickActionsProps {
  serverState: string | null;
}

interface Command {
  id: string;
  name: string;
  command: string;
  description: string;
  requiresArg: boolean;
  argPlaceholder?: string;
  argPattern?: RegExp;
}

const COMMANDS: Command[] = [
  {
    id: "whitelist-list",
    name: "View Whitelist",
    command: "whitelist list",
    description: "Show all whitelisted players",
    requiresArg: false,
  },
  {
    id: "whitelist-add",
    name: "Whitelist Add",
    command: "whitelist add",
    description: "Add a player to the whitelist",
    requiresArg: true,
    argPlaceholder: "Minecraft username",
    argPattern: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: "whitelist-remove",
    name: "Whitelist Remove",
    command: "whitelist remove",
    description: "Remove a player from the whitelist",
    requiresArg: true,
    argPlaceholder: "Minecraft username",
    argPattern: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: "list",
    name: "Online Players",
    command: "list",
    description: "Show currently online players",
    requiresArg: false,
  },
  {
    id: "save-all",
    name: "Save World",
    command: "save-all",
    description: "Force save all worlds",
    requiresArg: false,
  },
  {
    id: "say",
    name: "Broadcast Message",
    command: "say",
    description: "Send a message to all players",
    requiresArg: true,
    argPlaceholder: "Message to broadcast",
    argPattern: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/,
  },
];

export function QuickActions({ serverState }: QuickActionsProps) {
  const [selectedCommand, setSelectedCommand] = useState<Command | null>(null);
  const [args, setArgs] = useState("");
  const [output, setOutput] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const isServerRunning = serverState === "running";

  const isValidArg = !selectedCommand?.requiresArg ||
    (args && selectedCommand.argPattern?.test(args));

  const canExecute = isServerRunning && selectedCommand && isValidArg && !loading;

  const handleExecute = async () => {
    if (!selectedCommand || !canExecute) return;

    setLoading(true);
    setOutput(null);
    setError(null);

    try {
      const response = await fetch("/api/admin/rcon", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          command: selectedCommand.command,
          args: selectedCommand.requiresArg ? args : undefined,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setOutput(data.output);
        // Clear args after successful execution (for add/remove commands)
        if (selectedCommand.id.includes("add") || selectedCommand.id.includes("remove")) {
          setArgs("");
        }
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError("Failed to execute command");
    } finally {
      setLoading(false);
    }
  };

  const handleCommandChange = (commandId: string) => {
    const cmd = COMMANDS.find((c) => c.id === commandId);
    setSelectedCommand(cmd || null);
    setArgs("");
    setOutput(null);
    setError(null);
  };

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 className="text-lg font-semibold text-text-light mb-4">Quick Actions</h2>

      {/* Server Offline Warning */}
      {!isServerRunning && (
        <div className="mb-4 p-3 bg-accent-gold/20 border border-accent-gold/40 rounded-lg">
          <p className="text-accent-gold text-sm">
            Server must be running to execute commands
          </p>
        </div>
      )}

      {/* Command Selection */}
      <div className="space-y-4">
        <select
          value={selectedCommand?.id || ""}
          onChange={(e) => handleCommandChange(e.target.value)}
          disabled={!isServerRunning}
          className="w-full px-4 py-3 bg-bg-dark text-text-light rounded-lg border border-secondary-stone/30 disabled:opacity-50"
        >
          <option value="">Select a command...</option>
          {COMMANDS.map((cmd) => (
            <option key={cmd.id} value={cmd.id}>
              {cmd.name}
            </option>
          ))}
        </select>

        {/* Command Description */}
        {selectedCommand && (
          <p className="text-sm text-text-muted">{selectedCommand.description}</p>
        )}

        {/* Argument Input */}
        {selectedCommand?.requiresArg && (
          <input
            type="text"
            placeholder={selectedCommand.argPlaceholder}
            value={args}
            onChange={(e) => setArgs(e.target.value)}
            disabled={!isServerRunning || loading}
            className="w-full px-4 py-3 bg-bg-dark text-text-light rounded-lg border border-secondary-stone/30 placeholder-text-muted disabled:opacity-50"
          />
        )}

        {/* Execute Button */}
        <button
          onClick={handleExecute}
          disabled={!canExecute}
          className="w-full px-4 py-3 bg-accent-diamond hover:bg-accent-diamond/80 text-white font-medium rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? "Executing..." : "Execute"}
        </button>
      </div>

      {/* Output Display */}
      {output && (
        <div className="mt-4 p-4 bg-gray-900 rounded-lg font-mono text-sm text-mc-green whitespace-pre-wrap">
          {output}
        </div>
      )}

      {/* Error Display */}
      {error && (
        <div className="mt-4 p-4 bg-accent-redstone/20 border border-accent-redstone/40 rounded-lg">
          <p className="text-accent-redstone text-sm">{error}</p>
        </div>
      )}
    </div>
  );
}
```

### Update Dashboard Content

Add QuickActions to `DashboardContent.tsx`:

```tsx
import { QuickActions } from "./QuickActions";

// In the grid:
<QuickActions serverState={status?.ec2?.state || null} />
```

### IAM Policy Addition

```json
{
  "Sid": "BlockHavenSSM",
  "Effect": "Allow",
  "Action": [
    "ssm:SendCommand",
    "ssm:GetCommandInvocation"
  ],
  "Resource": [
    "arn:aws:ssm:us-east-2:*:document/AWS-RunShellScript",
    "arn:aws:ec2:us-east-2:*:instance/i-026059416cf185c9f"
  ]
}
```

### Dependencies to Install

```bash
npm install @aws-sdk/client-ssm
```

## Acceptance Criteria Mapping

### Story 01: SSM Setup

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| SDK installed | `@aws-sdk/client-ssm` | Check package.json |
| Client configured | `getSSMClient()` | Import check |
| Command whitelist defined | `ALLOWED_COMMANDS` array | Check code |
| Command execution function | `executeRconCommand()` | Function exists |
| IAM permissions documented | JSON policy provided | Check docs |

### Story 02: RCON API

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Executes valid command | POST `/api/admin/rcon` | Test with whitelist list |
| Handles arguments | `args` parameter | Test whitelist add |
| Rejects disallowed commands | Validation check | Test with "stop" |
| Validates arguments | `validateCommand()` | Test with bad input |
| Protected by auth | Middleware | Test unauthenticated |
| Logs commands | `[AUDIT]` logs | Check logs |

### Story 03: QuickActions Component

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Command selector | Dropdown with all commands | Visual check |
| Argument input | Shows when required | Select whitelist add |
| Execute button | Triggers API call | Click test |
| Output display | Monospace box | Execute and check |
| Error handling | Red error box | Test invalid input |
| Disabled when offline | `isServerRunning` check | Stop server, check |
| Input validation | Client-side pattern check | Enter bad username |
| Mobile responsive | Touch-friendly controls | Test on mobile |

## Testing Requirements

### Manual Testing Checklist

**API Endpoint:**
```bash
# View whitelist
curl -X POST http://localhost:4321/api/admin/rcon \
  -H "Content-Type: application/json" \
  -d '{"command":"whitelist list"}'

# Add to whitelist
curl -X POST http://localhost:4321/api/admin/rcon \
  -H "Content-Type: application/json" \
  -d '{"command":"whitelist add","args":"TestPlayer"}'

# Disallowed command
curl -X POST http://localhost:4321/api/admin/rcon \
  -H "Content-Type: application/json" \
  -d '{"command":"stop"}'
# Expected: 400 error

# Invalid argument
curl -X POST http://localhost:4321/api/admin/rcon \
  -H "Content-Type: application/json" \
  -d '{"command":"whitelist add","args":"a;rm -rf /"}'
# Expected: 400 error
```

**Component:**
- [ ] Command dropdown shows all options
- [ ] Selecting whitelist add shows username input
- [ ] Invalid username disables execute button
- [ ] Execute shows loading state
- [ ] Output displays in green monospace
- [ ] Error displays in red box
- [ ] Commands disabled when server offline

### Build Verification

```bash
npm run build
```

Expected: Build succeeds with SSM SDK bundled.

## Security Considerations

- **Strict whitelist:** Only predefined commands allowed
- **Argument sanitization:** Regex patterns prevent injection
- **Audit logging:** All commands logged with user and timestamp
- **Auth required:** Middleware protects endpoint
- **No shell expansion:** Arguments passed directly, not through shell

## Success Verification

After implementation:

- [ ] `@aws-sdk/client-ssm` installed
- [ ] `/api/admin/rcon` executes whitelisted commands
- [ ] Disallowed commands are rejected
- [ ] QuickActions component works with all commands
- [ ] Audit logs show command execution
- [ ] Server offline disables commands

## Traceability

**Parent stories:**
- [Story 01: Setup AWS SSM Integration](../../stories/epic-BG-WEB-002-05/story-01.md)
- [Story 02: Create RCON API Endpoint](../../stories/epic-BG-WEB-002-05/story-02.md)
- [Story 03: Build QuickActions Component](../../stories/epic-BG-WEB-002-05/story-03.md)

**Parent epic:** [Epic BG-WEB-002-05: Quick Actions](../../epics/epic-BG-WEB-002-05-quick-actions.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-05/spec-01-02-03-quick-actions.md`
