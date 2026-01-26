---
spec_id: 01
story_ids: [01]
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Setup AWS SDK for EC2 Operations
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BG-WEB-002-02/story-01.md
created: 2026-01-25
---

# Technical Spec 01: Setup AWS SDK for EC2 Operations

## Overview

**User story:** [Story 01: Setup AWS SDK for EC2](../../stories/epic-BG-WEB-002-02/story-01.md)

**Goal:** Install and configure AWS SDK v3 for EC2 operations. Create a helper module that provides a configured EC2Client for use in API routes. The SDK must work in Cloudflare Workers runtime.

**Approach:** Install `@aws-sdk/client-ec2`, create `src/lib/aws/ec2.ts` with configured EC2Client, and document required IAM permissions.

## Technical Design

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Cloudflare Workers                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  src/lib/aws/ec2.ts                                        │ │
│  │  ├── EC2Client (configured with credentials)               │ │
│  │  └── Exported for use in API routes                        │ │
│  └────────────────────────────────────────────────────────────┘ │
│                             │                                    │
│                             ▼                                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  API Routes (Epic 2 Stories 02-05)                         │ │
│  │  ├── /api/admin/server/status  (DescribeInstances)         │ │
│  │  ├── /api/admin/server/start   (StartInstances)            │ │
│  │  └── /api/admin/server/stop    (StopInstances)             │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         AWS EC2 API                              │
│  Instance: i-026059416cf185c9f                                  │
│  Region: us-east-2                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | IAM user access key | `AKIAxxxxxxxx` |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key | `xxxxxxxx` |
| `AWS_REGION` | AWS region for EC2 | `us-east-2` |
| `EC2_INSTANCE_ID` | Target EC2 instance | `i-026059416cf185c9f` |

## Implementation Details

### Files to Create

#### 1. EC2 Client Module

**`web/src/lib/aws/ec2.ts`**

```typescript
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
```

#### 2. AWS Module Index

**`web/src/lib/aws/index.ts`**

```typescript
// src/lib/aws/index.ts
// AWS SDK module exports

export { getEC2Client, getInstanceId } from "./ec2";
export type { EC2State, ServerStatus } from "./ec2";
```

### Files to Modify

#### 1. Update .env.example

Add AWS-related variables to `web/.env.example`:

```bash
# ===================
# Admin Dashboard - AWS Configuration
# ===================

# AWS Credentials (create IAM user with minimal EC2 permissions)
# See docs/ADMIN-SETUP.md for IAM policy
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2

# EC2 Instance to manage
EC2_INSTANCE_ID=i-xxxxxxxxxxxxxxxxx
```

### Dependencies to Install

```bash
npm install @aws-sdk/client-ec2
```

### IAM Policy (Documentation)

Create minimal IAM user with this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BlockHavenEC2Management",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Name": "blockhaven-minecraft"
        }
      }
    },
    {
      "Sid": "BlockHavenEC2DescribeAll",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note:** The DescribeInstances action requires `Resource: "*"` but only returns instances the user has access to view. Start/Stop are restricted by instance tag.

## Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| `@aws-sdk/client-ec2` installed | `npm install` | Check `package.json` |
| EC2 client configured | `getEC2Client()` function | Import and check type |
| Uses env vars | `import.meta.env.*` | Check code |
| Works in Cloudflare Workers | No Node.js APIs | `npm run build` succeeds |
| .env.example updated | AWS vars documented | Check file |

## Testing Requirements

### Manual Testing Checklist

**Installation:**
- [ ] `npm install @aws-sdk/client-ec2` succeeds
- [ ] No peer dependency warnings
- [ ] Package appears in `package.json`

**Build Verification:**
```bash
npm run build
```
- [ ] Build succeeds without errors
- [ ] No "Node.js API not available" errors

**Type Checking:**
```bash
npm run check
```
- [ ] TypeScript types resolve correctly

**Integration Test (after API routes created):**
```typescript
// Quick test in dev console
import { getEC2Client, getInstanceId } from "./lib/aws";
const client = getEC2Client();
const instanceId = getInstanceId();
console.log("Client configured for:", instanceId);
```

### Build Verification

```bash
cd web
npm run build
```

Expected:
- Build succeeds
- AWS SDK is tree-shaken (only EC2Client included)
- No runtime errors in Cloudflare Workers

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| SDK not compatible with Workers | Low | High | AWS SDK v3 is designed for edge runtimes |
| Credentials exposed in logs | Low | Critical | Never log credentials; use env vars |
| Wrong region configured | Medium | Medium | Document correct region; validate on startup |

## Security Considerations

- **Credentials in environment variables:** Never hardcode in source code
- **Minimal IAM permissions:** Only DescribeInstances, StartInstances, StopInstances
- **Instance tag restriction:** Limit Start/Stop to tagged instances only
- **No credential logging:** Never log AWS credentials

## Success Verification

After implementation:

- [ ] `@aws-sdk/client-ec2` in `package.json`
- [ ] `src/lib/aws/ec2.ts` exists with `getEC2Client()`
- [ ] `src/lib/aws/index.ts` exports functions
- [ ] `.env.example` has AWS variables documented
- [ ] `npm run build` succeeds
- [ ] No TypeScript errors

## Traceability

**Parent story:** [Story 01: Setup AWS SDK for EC2](../../stories/epic-BG-WEB-002-02/story-01.md)

**Parent epic:** [Epic BG-WEB-002-02: Server Controls](../../epics/epic-BG-WEB-002-02-server-controls.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-01-aws-sdk-setup.md`
