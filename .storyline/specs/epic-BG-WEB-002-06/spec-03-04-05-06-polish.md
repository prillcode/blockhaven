---
spec_id: 03-04-05-06
story_ids: [03, 04, 05, 06]
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Error Boundaries, Mobile Polish, Security Audit, and Documentation
status: ready_for_implementation
complexity: medium
parent_stories:
  - ../../stories/epic-BG-WEB-002-06/story-03.md
  - ../../stories/epic-BG-WEB-002-06/story-04.md
  - ../../stories/epic-BG-WEB-002-06/story-05.md
  - ../../stories/epic-BG-WEB-002-06/story-06.md
created: 2026-01-25
---

# Technical Spec 03-04-05-06: Polish and Security

## Overview

**User stories:**
- [Story 03: Create Error Boundary Components](../../stories/epic-BG-WEB-002-06/story-03.md)
- [Story 04: Mobile Responsiveness Polish](../../stories/epic-BG-WEB-002-06/story-04.md)
- [Story 05: Security Audit & Hardening](../../stories/epic-BG-WEB-002-06/story-05.md)
- [Story 06: Update Documentation](../../stories/epic-BG-WEB-002-06/story-06.md)

**Goal:** Finalize the admin dashboard with error handling, mobile polish, security verification, and comprehensive documentation.

## Story 03: Error Boundaries

### Files to Create

#### Error Boundary Component

**`web/src/components/admin/ErrorBoundary.tsx`**

```tsx
// src/components/admin/ErrorBoundary.tsx
// React error boundary for graceful component failure handling

import React, { Component, ErrorInfo, ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  sectionName?: string;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(
      `[ErrorBoundary] ${this.props.sectionName || "Component"} error:`,
      error
    );
    console.error("Component stack:", errorInfo.componentStack);
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: undefined });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="p-6 bg-accent-redstone/10 border border-accent-redstone/30 rounded-lg">
          <h3 className="text-accent-redstone font-semibold mb-2">
            {this.props.sectionName || "This section"} encountered an error
          </h3>
          <p className="text-text-muted text-sm mb-4">
            Something went wrong. Please try again or refresh the page.
          </p>
          <button
            onClick={this.handleRetry}
            className="px-4 py-2 bg-accent-redstone hover:bg-accent-redstone/80 text-white text-sm rounded-lg transition-colors"
          >
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Update Dashboard Page

Wrap each dashboard component with ErrorBoundary:

```tsx
import { ErrorBoundary } from "../components/admin/ErrorBoundary";

// In dashboard:
<ErrorBoundary sectionName="Server Status">
  <ServerStatusCard ... />
</ErrorBoundary>

<ErrorBoundary sectionName="Server Controls">
  <ServerControls ... />
</ErrorBoundary>

<ErrorBoundary sectionName="Cost Estimation">
  <CostEstimator ... />
</ErrorBoundary>

<ErrorBoundary sectionName="Server Logs">
  <LogsViewer ... />
</ErrorBoundary>

<ErrorBoundary sectionName="Quick Actions">
  <QuickActions ... />
</ErrorBoundary>
```

## Story 04: Mobile Responsiveness

### CSS Updates

**`web/src/styles/global.css`** - Add responsive utilities:

```css
/* Touch-friendly minimum sizes */
.btn, button, [role="button"] {
  min-height: 44px;
  min-width: 44px;
}

/* Prevent iOS zoom on input focus */
input, select, textarea {
  font-size: 16px;
}

/* Mobile-friendly spacing */
@media (max-width: 640px) {
  .dashboard-grid {
    gap: 1rem;
  }

  /* Stack controls vertically */
  .controls-row {
    flex-direction: column;
  }
}

/* Safe area insets for notched devices */
@supports (padding: env(safe-area-inset-bottom)) {
  .dashboard-footer {
    padding-bottom: env(safe-area-inset-bottom);
  }
}
```

### Component Updates

Update dashboard grid for responsive layout:

```tsx
// DashboardContent.tsx
<div className="grid gap-4 sm:gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
```

Update LogsViewer for horizontal scroll:

```tsx
// LogsViewer.tsx - ensure long lines scroll horizontally
<div className="overflow-x-auto whitespace-pre">
  {/* log content */}
</div>
```

### Testing Checklist

- [ ] Test at 320px width (iPhone SE)
- [ ] Test at 375px width (iPhone standard)
- [ ] Test at 768px width (iPad)
- [ ] Verify touch targets are 44x44px minimum
- [ ] Verify no horizontal scroll on main content
- [ ] Verify forms work with mobile keyboard
- [ ] Verify confirmation dialogs work on touch
- [ ] Test OAuth flow on mobile Safari/Chrome

## Story 05: Security Audit

### Security Checklist

#### Authentication

- [ ] OAuth state parameter validated (Auth.js handles)
- [ ] Session tokens use secure random generation
- [ ] Session cookie has `HttpOnly` flag
- [ ] Session cookie has `Secure` flag (production)
- [ ] Session cookie has `SameSite=Lax`
- [ ] Sessions expire after 7 days
- [ ] Logout properly clears session
- [ ] Failed login attempts are logged

#### Authorization

- [ ] Middleware protects `/dashboard*` routes
- [ ] Middleware protects `/api/admin/*` routes
- [ ] API routes double-check authentication
- [ ] GitHub username check is case-insensitive
- [ ] No way to bypass auth middleware

#### Input Validation

- [ ] Minecraft usernames: `/^[a-zA-Z0-9_]{3,16}$/`
- [ ] RCON commands: strict whitelist only
- [ ] Message text: safe character set
- [ ] No `eval()` or dynamic code execution
- [ ] `JSON.parse` wrapped in try/catch

#### Output Security

- [ ] React escapes output by default
- [ ] No `dangerouslySetInnerHTML` with user data
- [ ] Error messages are generic (no stack traces)
- [ ] API errors don't leak paths or config

#### Infrastructure

- [ ] HTTPS enforced (Cloudflare handles)
- [ ] CORS: not configured (same-origin by default)
- [ ] Session cookies not accessible from JS
- [ ] No sensitive data in console.log (except audit)

#### Secrets

- [ ] `.env` in `.gitignore`
- [ ] No hardcoded API keys in code
- [ ] No secrets in error messages
- [ ] AWS credentials follow least privilege

### Files to Review

1. `src/lib/auth.ts` - Auth configuration
2. `src/middleware.ts` - Route protection
3. `src/lib/aws/rcon.ts` - Command whitelist
4. `src/pages/api/admin/*.ts` - API endpoints
5. `.env.example` - No real secrets

## Story 06: Documentation

### Files to Create/Update

#### Update .env.example

**`web/.env.example`**

```bash
# ===========================================
# BlockHaven Web - Environment Configuration
# ===========================================

# ===================
# Marketing Site
# ===================

# Email service for contact forms (https://resend.com)
RESEND_API_KEY=re_xxxxxxxxxxxx

# Admin email to receive contact form submissions
ADMIN_EMAIL=admin@bhsmp.com

# Minecraft server address for status widget
MC_SERVER_IP=play.bhsmp.com

# ===================
# Admin Dashboard - Authentication
# ===================

# Auth.js secret for signing JWTs (generate: openssl rand -base64 32)
AUTH_SECRET=your-32-character-or-longer-secret-here

# GitHub OAuth App credentials (https://github.com/settings/developers)
# Callback URL: https://bhsmp.com/api/auth/callback/github
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Authorized GitHub usernames (comma-separated, case-insensitive)
ADMIN_GITHUB_USERNAMES=yourusername,familymember1,familymember2

# Required for Cloudflare Workers
AUTH_TRUST_HOST=true

# ===================
# Admin Dashboard - AWS
# ===================

# AWS IAM user credentials (see docs/ADMIN-SETUP.md for IAM policy)
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2

# EC2 instance to manage
EC2_INSTANCE_ID=i-xxxxxxxxxxxxxxxxx

# CloudWatch log group for server logs
CLOUDWATCH_LOG_GROUP=blockhaven-minecraft
```

#### Create Admin Setup Guide

**`web/docs/ADMIN-SETUP.md`**

```markdown
# BlockHaven Admin Dashboard Setup Guide

This guide covers setting up the admin dashboard for the BlockHaven Minecraft server.

## Prerequisites

- GitHub account
- AWS account with EC2 instance
- Cloudflare account (for hosting)

## 1. GitHub OAuth App

1. Go to https://github.com/settings/developers
2. Click "New OAuth App"
3. Fill in:
   - **Application name:** BlockHaven Admin
   - **Homepage URL:** https://bhsmp.com
   - **Authorization callback URL:** https://bhsmp.com/api/auth/callback/github
4. Click "Register application"
5. Copy **Client ID** to `GITHUB_CLIENT_ID`
6. Generate a new **Client Secret** and copy to `GITHUB_CLIENT_SECRET`

### For Local Development

Create a separate OAuth app with:
- Homepage URL: http://localhost:4321
- Callback URL: http://localhost:4321/api/auth/callback/github

## 2. AWS IAM User

Create an IAM user with the following policy:

\`\`\`json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Management",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:GetLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:us-east-2:*:log-group:blockhaven-minecraft:*"
    },
    {
      "Sid": "SSMCommands",
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Resource": [
        "arn:aws:ssm:us-east-2:*:document/AWS-RunShellScript",
        "arn:aws:ec2:us-east-2:*:instance/i-*"
      ]
    }
  ]
}
\`\`\`

## 3. Cloudflare KV Namespaces

Create two KV namespaces:

\`\`\`bash
wrangler kv:namespace create BLOCKHAVEN_RATE_LIMITS
wrangler kv:namespace create BLOCKHAVEN_AUDIT
\`\`\`

Add the IDs to `wrangler.toml`.

## 4. Environment Variables

### Local Development

Copy `.env.example` to `.env` and fill in values.

### Production (Cloudflare)

Set secrets in Cloudflare Pages dashboard or via CLI:

\`\`\`bash
wrangler pages secret put AUTH_SECRET
wrangler pages secret put GITHUB_CLIENT_ID
wrangler pages secret put GITHUB_CLIENT_SECRET
wrangler pages secret put AWS_ACCESS_KEY_ID
wrangler pages secret put AWS_SECRET_ACCESS_KEY
# ... etc
\`\`\`

## 5. CloudWatch Logs (Optional)

For the logs viewer to work, install CloudWatch agent on EC2:

1. Install agent: \`sudo yum install -y amazon-cloudwatch-agent\`
2. Configure to send Docker logs to `blockhaven-minecraft` log group
3. Start agent: \`sudo systemctl start amazon-cloudwatch-agent\`

## 6. Verify Setup

1. Run locally: \`npm run dev\`
2. Visit http://localhost:4321/login
3. Sign in with GitHub
4. Verify dashboard loads with server status

## Troubleshooting

### "Access denied" on login
- Check `ADMIN_GITHUB_USERNAMES` includes your username (case-insensitive)

### AWS errors
- Verify credentials are correct
- Check IAM policy allows required actions
- Verify region matches EC2 instance

### Rate limiting issues in dev
- KV may not be available locally
- Rate limiting will skip if KV undefined
```

#### Update README

**`web/README.md`** - Add admin section:

```markdown
## Admin Dashboard

The admin dashboard at `/dashboard` provides server management for authorized users.

### Features

- **GitHub OAuth authentication** - Secure login via GitHub
- **Server status** - Real-time EC2 and Minecraft status
- **Server controls** - Start/stop with one click
- **Cost estimation** - Track monthly AWS costs
- **Logs viewer** - View Minecraft server logs
- **Quick actions** - Whitelist management and commands

### Setup

See [docs/ADMIN-SETUP.md](./docs/ADMIN-SETUP.md) for complete setup instructions.

### Environment Variables

Copy `.env.example` to `.env` and configure all required values.
```

## Acceptance Criteria Mapping

### Story 03: Error Boundaries

| Criterion | Verification |
|-----------|--------------|
| Catches component errors | Throw error in component, verify boundary catches |
| Friendly error message | Check message text |
| Retry functionality | Click retry, verify component re-renders |
| Error logged to console | Check browser console |
| Each section wrapped | Verify all 5 components have boundaries |

### Story 04: Mobile Polish

| Criterion | Verification |
|-----------|--------------|
| 320px width works | Test on narrow viewport |
| Touch targets 44px | Measure buttons |
| No horizontal scroll | Test on mobile |
| Forms work with keyboard | Test input focus |
| Real device testing | Test on iPhone/Android |

### Story 05: Security Audit

| Criterion | Verification |
|-----------|--------------|
| All checklist items passed | Go through each item |
| No console errors | Check production build |
| Cross-browser tested | Chrome, Firefox, Safari |

### Story 06: Documentation

| Criterion | Verification |
|-----------|--------------|
| .env.example complete | All vars documented |
| Setup guide exists | docs/ADMIN-SETUP.md |
| README updated | Admin section added |

## Success Verification

- [ ] Error boundaries catch and display errors gracefully
- [ ] Dashboard is fully functional on mobile devices
- [ ] Security checklist passes all items
- [ ] Documentation is complete and accurate
- [ ] Production build has no console errors

## Traceability

**Parent stories:**
- [Story 03: Error Boundaries](../../stories/epic-BG-WEB-002-06/story-03.md)
- [Story 04: Mobile Polish](../../stories/epic-BG-WEB-002-06/story-04.md)
- [Story 05: Security Audit](../../stories/epic-BG-WEB-002-06/story-05.md)
- [Story 06: Documentation](../../stories/epic-BG-WEB-002-06/story-06.md)

**Parent epic:** [Epic BG-WEB-002-06: Polish & Security](../../epics/epic-BG-WEB-002-06-polish-security.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-06/spec-03-04-05-06-polish.md`
