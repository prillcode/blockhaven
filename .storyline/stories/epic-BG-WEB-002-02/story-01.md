---
story_id: 01
epic_id: BG-WEB-002-02
identifier: BG-WEB-002
title: Setup AWS SDK for EC2
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-02-server-controls.md
created: 2026-01-25
---

# Story 01: Setup AWS SDK for EC2

## User Story

**As a** developer,
**I want** to configure the AWS SDK for EC2 operations,
**so that** the dashboard can interact with the Minecraft server's EC2 instance.

## Acceptance Criteria

### Scenario 1: AWS SDK installed
**Given** the web project exists
**When** I install the AWS SDK
**Then** `@aws-sdk/client-ec2` is added to dependencies
**And** packages install without errors

### Scenario 2: EC2 client configured
**Given** the SDK is installed
**When** I create the EC2 client helper
**Then** `src/lib/aws.ts` exports a configured EC2Client
**And** it reads credentials from environment variables

### Scenario 3: Credentials from environment
**Given** the EC2 client is configured
**When** it initializes
**Then** it uses `AWS_ACCESS_KEY_ID` from env
**And** it uses `AWS_SECRET_ACCESS_KEY` from env
**And** it uses `AWS_REGION` from env

### Scenario 4: Works in Cloudflare Workers
**Given** the EC2 client is configured
**When** deployed to Cloudflare Workers
**Then** API calls work from the edge runtime
**And** no Node.js-specific dependencies are used

### Scenario 5: Environment documented
**Given** the SDK is configured
**When** I check `.env.example`
**Then** it includes `AWS_ACCESS_KEY_ID`
**And** it includes `AWS_SECRET_ACCESS_KEY`
**And** it includes `AWS_REGION`
**And** it includes `EC2_INSTANCE_ID`

## Business Value

**Why this matters:** The AWS SDK is the foundation for all server control features. Proper configuration ensures reliable communication with EC2.

**Impact:** Enables start/stop controls and status monitoring.

**Success metric:** EC2 API calls succeed from Cloudflare Workers.

## Technical Considerations

**AWS SDK v3 Setup:**
```typescript
// src/lib/aws.ts
import { EC2Client } from "@aws-sdk/client-ec2"

export const ec2Client = new EC2Client({
  region: import.meta.env.AWS_REGION || "us-east-2",
  credentials: {
    accessKeyId: import.meta.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: import.meta.env.AWS_SECRET_ACCESS_KEY,
  },
})
```

**IAM User Setup (documented, not implemented):**
1. Create IAM user `blockhaven-dashboard`
2. Attach policy with minimal permissions:
   - `ec2:DescribeInstances`
   - `ec2:StartInstances` (restricted to specific instance)
   - `ec2:StopInstances` (restricted to specific instance)

**Constraints:**
- Must use AWS SDK v3 (modular, tree-shakeable)
- Must work in Cloudflare Workers (no Node.js APIs)
- Credentials must never be exposed to client

**Environment Variables:**
```bash
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2
EC2_INSTANCE_ID=i-026059416cf185c9f
```

## Dependencies

**Depends on stories:** Epic 1 complete (authentication)

**Enables stories:**
- Story 02: Server Status API
- Story 04: Start Server API
- Story 05: Stop Server API

## Out of Scope

- IAM user creation (manual AWS Console task)
- Server status API (Story 02)
- Start/stop APIs (Stories 04, 05)

## Notes

- AWS SDK v3 is modular - only import needed clients/commands
- IAM policy should follow least privilege (documented in epic)
- Test SDK works locally with `wrangler dev` before deploying

## Traceability

**Parent epic:** [epic-BG-WEB-002-02-server-controls.md](../../epics/epic-BG-WEB-002-02-server-controls.md)

**Related stories:** Story 02 (Status API), Story 04-05 (Start/Stop APIs)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-01.md`
