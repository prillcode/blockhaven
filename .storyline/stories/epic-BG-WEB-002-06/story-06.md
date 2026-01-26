---
story_id: 06
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Update Documentation
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-06-polish-security.md
created: 2026-01-25
---

# Story 06: Update Documentation

## User Story

**As a** developer or administrator,
**I want** comprehensive documentation for the admin dashboard,
**so that** I can understand how to set up, configure, and use it.

## Acceptance Criteria

### Scenario 1: README updated
**Given** the dashboard is complete
**When** I read the web/README.md
**Then** it describes the admin dashboard feature
**And** includes a summary of capabilities

### Scenario 2: Environment variables documented
**Given** I'm setting up the project
**When** I check .env.example
**Then** all required variables are listed
**And** each variable has a comment explaining its purpose
**And** example values show correct format

### Scenario 3: IAM policy documented
**Given** I need to set up AWS access
**When** I check the documentation
**Then** the complete IAM policy is provided
**And** instructions explain how to create the IAM user
**And** principle of least privilege is explained

### Scenario 4: GitHub OAuth setup documented
**Given** I need to set up authentication
**When** I check the documentation
**Then** step-by-step instructions are provided
**And** callback URL format is specified
**And** both production and development setups are covered

### Scenario 5: Cloudflare KV setup documented
**Given** I need to configure session storage
**When** I check the documentation
**Then** KV namespace creation is documented
**And** wrangler.toml configuration is explained
**And** binding names are specified

### Scenario 6: CloudWatch setup documented (if applicable)
**Given** I want to use the logs viewer
**When** I check the documentation
**Then** CloudWatch agent installation is documented
**And** agent configuration is provided
**And** log group name is specified

### Scenario 7: Deployment instructions updated
**Given** I'm deploying the dashboard
**When** I follow the documentation
**Then** Cloudflare Pages setup is explained
**And** environment variable configuration is covered
**And** domain setup is referenced

## Business Value

**Why this matters:** Good documentation enables self-service setup and reduces support burden. Future maintainers need to understand the system.

**Impact:** Faster onboarding for new developers and easier maintenance.

**Success metric:** Someone can set up the dashboard from scratch using only the documentation.

## Technical Considerations

**Files to Update:**

**web/README.md:**
```markdown
## Admin Dashboard

The BlockHaven Admin Dashboard provides authenticated server management at `/dashboard`.

### Features
- GitHub OAuth authentication
- EC2 instance start/stop controls
- Real-time server status
- Minecraft player count
- Cost estimation
- Server logs viewer
- RCON quick actions (whitelist management)

### Setup

See [Admin Dashboard Setup Guide](./docs/ADMIN-SETUP.md) for complete instructions.
```

**web/.env.example:**
```bash
# ===================
# Marketing Site
# ===================
RESEND_API_KEY=re_xxxxxxxxxxxx
ADMIN_EMAIL=admin@example.com
MC_SERVER_IP=play.example.com

# ===================
# Admin Dashboard
# ===================

# GitHub OAuth (create at github.com/settings/developers)
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ADMIN_GITHUB_USERNAMES=username1,username2,username3

# Auth.js secret (generate: openssl rand -base64 32)
AUTH_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# AWS Credentials (create IAM user with minimal permissions)
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2

# EC2 Instance
EC2_INSTANCE_ID=i-xxxxxxxxxxxxxxxxx

# CloudWatch (for logs viewer)
CLOUDWATCH_LOG_GROUP=blockhaven-minecraft
```

**web/docs/ADMIN-SETUP.md:** (new file)
- Complete setup guide
- GitHub OAuth app creation
- AWS IAM user creation
- Cloudflare KV setup
- CloudWatch agent setup (optional)
- Deployment checklist

## Dependencies

**Depends on stories:**
- Story 05: Security Audit (all features finalized)

**Enables stories:** None (final story)

## Out of Scope

- Video tutorials
- Interactive setup wizard
- Auto-generated API documentation
- Changelog file

## Notes

- Documentation should be concise but complete
- Include copy-paste ready configuration where possible
- Screenshots optional but helpful for OAuth/AWS setup
- Keep documentation in sync with actual implementation

## Traceability

**Parent epic:** [epic-BG-WEB-002-06-polish-security.md](../../epics/epic-BG-WEB-002-06-polish-security.md)

**Related stories:** All stories (documentation covers entire feature)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-06/story-06.md`
