# Epic BG-WEB-002-05: Quick Actions - Technical Specs Index

## Overview

This epic implements RCON command execution via AWS SSM for whitelist management and server commands.

**Total Stories:** 3
**Total Specs:** 1 (stories combined)

**Priority:** P2 (lower priority feature)

## Specs

| Spec | Stories | Title | Complexity | Status |
|------|---------|-------|------------|--------|
| [spec-01-02-03](spec-01-02-03-quick-actions.md) | 01, 02, 03 | AWS SSM Integration with RCON API and Quick Actions Component | Medium | Ready |

## Key Files Created

| File | Purpose |
|------|---------|
| `src/lib/aws/rcon.ts` | SSM client and RCON execution |
| `src/pages/api/admin/rcon.ts` | RCON API endpoint |
| `src/components/admin/QuickActions.tsx` | Command execution UI |

## Allowed Commands

| Command | Arguments | Description |
|---------|-----------|-------------|
| `whitelist list` | None | Show whitelisted players |
| `whitelist add` | `<username>` | Add player to whitelist |
| `whitelist remove` | `<username>` | Remove player from whitelist |
| `list` | None | Show online players |
| `save-all` | None | Force save worlds |
| `say` | `<message>` | Broadcast message |

## Prerequisites

- SSM agent running on EC2 (pre-installed on Amazon Linux 2)
- EC2 instance has IAM role for SSM
- Docker container named `blockhaven-mc` with `rcon-cli`

## IAM Permissions

```json
{
  "Action": ["ssm:SendCommand", "ssm:GetCommandInvocation"],
  "Resource": [
    "arn:aws:ssm:us-east-2:*:document/AWS-RunShellScript",
    "arn:aws:ec2:us-east-2:*:instance/i-xxx"
  ]
}
```

## To Execute

```bash
npm install @aws-sdk/client-ssm
/sl-develop .storyline/specs/epic-BG-WEB-002-05/spec-01-02-03-quick-actions.md
```
