# Epic 5: Quick Actions Panel (RCON)

**Epic ID:** BG-WEB-002-05
**Status:** Not Started
**Priority:** P2 (Could Have)
**Source:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md

---

## Business Goal

Enable admins to execute common server management commands directly from the dashboard, specifically whitelist management and basic server operations, without requiring SSH access.

## User Value

**Who Benefits:** Authorized admins

**How They Benefit:**
- Quick whitelist management: Add/remove players without SSH
- Instant server commands: Save, broadcast messages, check online players
- Mobile friendly: Manage players from any device
- Reduced friction: No terminal or RCON client needed

## Success Criteria

- [ ] Can execute whitelisted RCON commands from dashboard
- [ ] Whitelist add/remove/list commands work correctly
- [ ] Command output displays in UI
- [ ] Input validation prevents malicious commands
- [ ] Commands only work when server is running
- [ ] Rate limiting prevents command spam (10/minute)
- [ ] Clear error messages for failed commands

## Scope

### In Scope
- RCON API route (`POST /api/admin/rcon`)
- AWS Systems Manager (SSM) integration for secure command execution
- QuickActions component with command interface
- Whitelisted safe commands only
- Input validation and sanitization
- Command output display
- Rate limiting (10 commands per minute)
- Server-running check before execution

### Out of Scope
- Full RCON shell access
- Dangerous commands (stop, restart, op, deop, ban)
- Custom command input (only predefined commands)
- Scheduled commands
- Command history persistence
- Multi-server support

## Technical Notes

**Implementation Approach:**

The challenge: Executing commands on EC2 from Cloudflare Workers.

**Option A: AWS Systems Manager (SSM) - Recommended**
- Use SSM Run Command to execute commands on EC2
- No SSH keys needed, uses IAM for auth
- Pros: Secure, auditable, no ports to open
- Cons: Requires SSM agent on EC2, slight latency

**Option B: Lambda + EC2 SSH**
- Cloudflare calls Lambda, Lambda SSHs to EC2
- Pros: Works with existing SSH setup
- Cons: More complex, SSH key management

**Recommended: Option A (AWS SSM)**

**SSM Command Execution:**
```typescript
// src/lib/rcon.ts
import { SSMClient, SendCommandCommand, GetCommandInvocationCommand } from "@aws-sdk/client-ssm"

const ssmClient = new SSMClient({
  region: import.meta.env.AWS_REGION,
  credentials: {
    accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
  },
})

// Whitelist of allowed commands
const ALLOWED_COMMANDS = [
  'whitelist add',
  'whitelist remove',
  'whitelist list',
  'list',           // Show online players
  'save-all',       // Save world
  'say',            // Broadcast message
] as const

export async function executeRconCommand(command: string, args?: string): Promise<string> {
  // Validate command is allowed
  const baseCommand = ALLOWED_COMMANDS.find(c => command.startsWith(c))
  if (!baseCommand) {
    throw new Error('Command not allowed')
  }

  // Sanitize args (alphanumeric + spaces only for usernames/messages)
  if (args && !/^[a-zA-Z0-9_ ]+$/.test(args)) {
    throw new Error('Invalid characters in arguments')
  }

  const fullCommand = args ? `${command} ${args}` : command
  const dockerCommand = `docker exec blockhaven-mc rcon-cli ${fullCommand}`

  // Send command via SSM
  const sendCommand = new SendCommandCommand({
    InstanceIds: [import.meta.env.EC2_INSTANCE_ID],
    DocumentName: 'AWS-RunShellScript',
    Parameters: {
      commands: [dockerCommand],
    },
  })

  const response = await ssmClient.send(sendCommand)
  const commandId = response.Command?.CommandId

  // Wait for result (poll for completion)
  await sleep(1000) // Give it a moment

  const getResult = new GetCommandInvocationCommand({
    CommandId: commandId,
    InstanceId: import.meta.env.EC2_INSTANCE_ID,
  })

  const result = await ssmClient.send(getResult)
  return result.StandardOutputContent || 'Command executed'
}
```

**Command Interface:**
```typescript
interface RconCommand {
  id: string
  name: string
  description: string
  command: string
  requiresArg: boolean
  argPlaceholder?: string
  argValidation?: RegExp
}

const COMMANDS: RconCommand[] = [
  {
    id: 'whitelist-add',
    name: 'Whitelist Add',
    description: 'Add a player to the whitelist',
    command: 'whitelist add',
    requiresArg: true,
    argPlaceholder: 'Username',
    argValidation: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: 'whitelist-remove',
    name: 'Whitelist Remove',
    description: 'Remove a player from the whitelist',
    command: 'whitelist remove',
    requiresArg: true,
    argPlaceholder: 'Username',
    argValidation: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: 'whitelist-list',
    name: 'Whitelist List',
    description: 'Show all whitelisted players',
    command: 'whitelist list',
    requiresArg: false,
  },
  {
    id: 'list',
    name: 'Online Players',
    description: 'Show currently online players',
    command: 'list',
    requiresArg: false,
  },
  {
    id: 'save-all',
    name: 'Save World',
    description: 'Force save all worlds',
    command: 'save-all',
    requiresArg: false,
  },
  {
    id: 'say',
    name: 'Broadcast',
    description: 'Send a message to all online players',
    command: 'say',
    requiresArg: true,
    argPlaceholder: 'Message',
    argValidation: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/,
  },
]
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

## Dependencies

**Depends On:**
- Epic 1: Authentication (protected routes)
- Epic 2: Server Status (know if server is running)
- AWS SSM agent installed on EC2 instance

**Blocks:**
- Epic 6: Polish & Security Audit

## Risks & Mitigations

**Risk:** SSM agent not installed on EC2
- **Likelihood:** Medium
- **Impact:** High (feature won't work)
- **Mitigation:** SSM agent comes pre-installed on Amazon Linux 2, verify during setup

**Risk:** Command injection via unsanitized input
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Strict input validation, command whitelist, alphanumeric-only args

**Risk:** Rate limiting bypass
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Server-side rate limiting, per-user tracking

**Risk:** Long command execution times
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Timeout after 10 seconds, show loading state

## Acceptance Criteria

### RCON API Route (`POST /api/admin/rcon`)
- [ ] Accepts `command` and optional `args` in request body
- [ ] Validates command against whitelist
- [ ] Sanitizes arguments (alphanumeric + limited special chars)
- [ ] Executes command via AWS SSM
- [ ] Returns command output
- [ ] Returns error if command not allowed
- [ ] Returns error if server is stopped
- [ ] Rate limited to 10 commands per minute per user
- [ ] Protected by auth middleware

### QuickActions Component
- [ ] Dropdown to select command type
- [ ] Input field appears when command requires argument
- [ ] Input validation with error messages
- [ ] "Execute" button with loading state
- [ ] Output display area (monospace, dark background)
- [ ] Clear output button
- [ ] Disabled when server is offline
- [ ] Mobile-friendly layout

### Command Whitelist
- [ ] `whitelist add <username>` - Add player to whitelist
- [ ] `whitelist remove <username>` - Remove player from whitelist
- [ ] `whitelist list` - Show all whitelisted players
- [ ] `list` - Show online players
- [ ] `save-all` - Force world save
- [ ] `say <message>` - Broadcast to players
- [ ] NO dangerous commands: stop, restart, op, deop, ban, gamemode, etc.

### Input Validation
- [ ] Usernames: 3-16 characters, alphanumeric + underscore only
- [ ] Messages: 1-100 characters, safe characters only
- [ ] Rejects special characters that could enable injection
- [ ] Client-side validation for immediate feedback
- [ ] Server-side validation as source of truth

### Rate Limiting
- [ ] Maximum 10 commands per minute per authenticated user
- [ ] Clear error message when rate limited
- [ ] Rate limit resets after 1 minute
- [ ] Rate limit tracked in Cloudflare KV

### Server State Handling
- [ ] Commands disabled when server is stopped
- [ ] Clear message: "Server must be running to execute commands"
- [ ] Automatically re-enables when server starts

### Security
- [ ] All commands logged with timestamp, user, command, args
- [ ] No command echoing that could leak sensitive info
- [ ] Timeout commands after 10 seconds
- [ ] SSM command execution auditable in AWS

### Environment Variables
```bash
# Existing AWS credentials used
# EC2_INSTANCE_ID already defined
```

### IAM Policy Update
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

### Directory Structure Additions
```
/web/src/
├── pages/
│   └── api/
│       └── admin/
│           └── rcon.ts           # POST execute RCON command
├── components/
│   └── admin/
│       └── QuickActions.tsx      # Command execution UI
└── lib/
    └── rcon.ts                    # SSM command execution
```

### Verification Checklist
- [ ] Dashboard shows Quick Actions section after login
- [ ] Can add player to whitelist
- [ ] Can remove player from whitelist
- [ ] Can view whitelist
- [ ] Can see online players
- [ ] Can save world
- [ ] Can broadcast message
- [ ] Invalid username shows validation error
- [ ] Invalid characters rejected
- [ ] Commands disabled when server offline
- [ ] Rate limiting kicks in after 10 commands
- [ ] Command output displays correctly
- [ ] Mobile view is usable

## Related User Stories

From PRD:
- User Story 12: "As the admin, I want to execute RCON commands so I can manage the server remotely"
- User Story 13: "As the admin, I want to add/remove whitelist players so I don't need to SSH"

## Notes

- This is a P2 (Could Have) feature - implement if time permits
- SSM is more secure than SSH from serverless environments
- Command whitelist is intentionally restrictive for security
- Audit logging helps track who executed what commands
- Consider adding more commands in the future based on usage patterns
- Rate limiting prevents accidental command spam and potential abuse

---

**Next Epic:** Epic 6 - Polish & Security Audit
