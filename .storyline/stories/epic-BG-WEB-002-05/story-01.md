---
story_id: 01
epic_id: BG-WEB-002-05
identifier: BG-WEB-002
title: Setup AWS SSM Integration
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-05-quick-actions.md
created: 2026-01-25
---

# Story 01: Setup AWS SSM Integration

## User Story

**As a** developer,
**I want** to configure AWS SSM for remote command execution,
**so that** the dashboard can execute RCON commands on the Minecraft server.

## Acceptance Criteria

### Scenario 1: SSM SDK installed
**Given** the web project exists
**When** I install the SSM SDK
**Then** `@aws-sdk/client-ssm` is added to dependencies
**And** packages install without errors

### Scenario 2: SSM client configured
**Given** the SDK is installed
**When** I create the SSM client helper
**Then** `src/lib/rcon.ts` exports SSM command execution functions
**And** it uses existing AWS credentials from environment

### Scenario 3: Command whitelist defined
**Given** the RCON module is implemented
**When** I check the allowed commands
**Then** only safe commands are whitelisted:
  - `whitelist add`
  - `whitelist remove`
  - `whitelist list`
  - `list`
  - `save-all`
  - `say`

### Scenario 4: Command execution function
**Given** the RCON module is implemented
**When** I call `executeRconCommand(command, args)`
**Then** it validates command against whitelist
**And** it sanitizes arguments
**And** it executes via SSM Run Command
**And** it returns command output

### Scenario 5: IAM policy documented
**Given** the integration is implemented
**When** I check documentation
**Then** required IAM permissions are documented:
  - `ssm:SendCommand`
  - `ssm:GetCommandInvocation`

## Business Value

**Why this matters:** AWS SSM provides secure command execution without SSH. Commands are auditable and don't require open ports.

**Impact:** Enables whitelist management and server commands from the dashboard.

**Success metric:** RCON commands execute successfully via SSM.

## Technical Considerations

**SSM Setup:**
```typescript
// src/lib/rcon.ts
import {
  SSMClient,
  SendCommandCommand,
  GetCommandInvocationCommand,
} from "@aws-sdk/client-ssm"

const ssmClient = new SSMClient({
  region: import.meta.env.AWS_REGION,
  credentials: {
    accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
  },
})

const ALLOWED_COMMANDS = [
  "whitelist add",
  "whitelist remove",
  "whitelist list",
  "list",
  "save-all",
  "say",
] as const

type AllowedCommand = (typeof ALLOWED_COMMANDS)[number]

export async function executeRconCommand(
  command: AllowedCommand,
  args?: string
): Promise<string> {
  // Validate command
  if (!ALLOWED_COMMANDS.includes(command)) {
    throw new Error("Command not allowed")
  }

  // Sanitize args
  if (args && !/^[a-zA-Z0-9_ !?.,'"-]{1,100}$/.test(args)) {
    throw new Error("Invalid characters in arguments")
  }

  const fullCommand = args ? `${command} ${args}` : command
  const dockerCommand = `docker exec blockhaven-mc rcon-cli ${fullCommand}`

  // Send command via SSM
  const sendCommand = new SendCommandCommand({
    InstanceIds: [import.meta.env.EC2_INSTANCE_ID],
    DocumentName: "AWS-RunShellScript",
    Parameters: { commands: [dockerCommand] },
    TimeoutSeconds: 30,
  })

  const sendResponse = await ssmClient.send(sendCommand)
  const commandId = sendResponse.Command?.CommandId

  if (!commandId) {
    throw new Error("Failed to send command")
  }

  // Poll for result
  await sleep(1500) // Give it time to execute

  const getResult = new GetCommandInvocationCommand({
    CommandId: commandId,
    InstanceId: import.meta.env.EC2_INSTANCE_ID,
  })

  const result = await ssmClient.send(getResult)

  if (result.Status === "Failed") {
    throw new Error(result.StandardErrorContent || "Command failed")
  }

  return result.StandardOutputContent || "Command executed"
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}
```

**IAM Policy Addition:**
```json
{
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

**Prerequisites (Server-Side):**
- SSM agent installed on EC2 (pre-installed on Amazon Linux 2)
- EC2 instance has IAM role for SSM
- Security group allows SSM traffic

## Dependencies

**Depends on stories:**
- Epic 1: Authentication (AWS credentials)

**Enables stories:**
- Story 02: RCON API Endpoint
- Story 03: QuickActions Component

## Out of Scope

- SSM agent installation on EC2
- Full RCON shell access
- Command history persistence

## Notes

- SSM is more secure than SSH from serverless environments
- Command whitelist is intentionally restrictive
- Arguments are sanitized to prevent injection
- SSM agent comes pre-installed on Amazon Linux 2

## Traceability

**Parent epic:** [epic-BG-WEB-002-05-quick-actions.md](../../epics/epic-BG-WEB-002-05-quick-actions.md)

**Related stories:** Story 02 (API), Story 03 (Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-05/story-01.md`
