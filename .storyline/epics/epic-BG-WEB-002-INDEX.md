# BlockHaven Admin Dashboard - Epic Index

**Project:** BlockHaven Astro Admin Dashboard
**Identifier:** BG-WEB-002
**Source PRD:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md
**Created:** January 25, 2026

---

## Overview

This epic collection covers the implementation of an authenticated admin dashboard for the BlockHaven Minecraft server, building on top of the existing Astro marketing website (BH-WEB-001). The dashboard provides remote server management capabilities without requiring SSH or AWS Console access.

**Key Goals:**
1. Simplify server management - Reduce start/stop operations from 5 steps to 1 click
2. Mobile accessibility - Manage server from phone/tablet
3. Secure access - GitHub OAuth with single authorized user
4. Cost monitoring - Display estimated monthly EC2 costs
5. Remote operations - View logs and execute RCON commands without SSH

**Prerequisites:**
- BlockHaven marketing website deployed (BH-WEB-001)
- Cloudflare Pages with SSR adapter configured
- Cloudflare KV namespace available

---

## Epic Breakdown

### Epic 1: GitHub OAuth Authentication
**ID:** BG-WEB-002-01
**File:** epic-BG-WEB-002-01-authentication.md
**Priority:** P0 (Must Have)

**Summary:** Implement secure GitHub OAuth authentication using Auth.js, supporting multiple authorized users via comma-separated username list. Sessions stored in Cloudflare KV with 7-day TTL. All `/dashboard` and `/api/admin/*` routes protected.

**Key Deliverables:**
- Auth.js integration with Astro adapter
- GitHub OAuth provider configuration
- Cloudflare KV session storage
- `/login` page with GitHub sign-in
- `/dashboard` protected route (placeholder)
- Auth middleware for protected routes
- 7-day session expiry
- Logout functionality

**Blocks:** Epic 2, 3, 4, 5, 6

---

### Epic 2: Server Status & Controls
**ID:** BG-WEB-002-02
**File:** epic-BG-WEB-002-02-server-controls.md
**Priority:** P0 (Must Have)

**Summary:** Build real-time EC2 and Minecraft server status display with one-click start/stop controls. Uses AWS SDK for instance management and mcstatus.io for Minecraft status.

**Key Deliverables:**
- AWS SDK integration (`@aws-sdk/client-ec2`)
- Server status API route (`GET /api/admin/server/status`)
- Start server API route (`POST /api/admin/server/start`)
- Stop server API route (`POST /api/admin/server/stop`)
- ServerStatusCard component (EC2 state, IP, player count, uptime)
- ServerControls component (start/stop buttons with confirmation)
- Auto-refresh every 30 seconds
- Loading states and error handling
- IAM user with minimal permissions

**Depends On:** Epic 1
**Blocks:** Epic 3, 4, 5, 6

---

### Epic 3: Cost Estimation
**ID:** BG-WEB-002-03
**File:** epic-BG-WEB-002-03-cost-estimation.md
**Priority:** P1 (Should Have)

**Summary:** Display estimated monthly EC2 costs based on instance runtime hours, with projected full-month cost and breakdown by service (EC2, EBS, data transfer).

**Key Deliverables:**
- Cost calculation logic (t3a.large @ $0.0752/hour + EBS)
- Cost estimation API route or client-side calculation
- CostEstimator component with breakdown display
- Month-to-date and projected costs
- Updates when instance state changes

**Depends On:** Epic 1, 2
**Blocks:** Epic 6

---

### Epic 4: Server Logs Viewer
**ID:** BG-WEB-002-04
**File:** epic-BG-WEB-002-04-logs-viewer.md
**Priority:** P1 (Should Have)

**Summary:** View recent Minecraft server logs (100-500 lines) without SSH access. Uses CloudWatch Logs or direct log retrieval through secure API endpoint.

**Key Deliverables:**
- Logs API route (`GET /api/admin/logs`)
- CloudWatch Logs integration OR SSH-based log retrieval
- LogsViewer component with monospace display
- Syntax highlighting for log levels (INFO, WARN, ERROR)
- Auto-scroll to bottom option
- Search/filter functionality
- Refresh button
- Mobile-friendly horizontal scroll

**Depends On:** Epic 1, 2
**Blocks:** Epic 6

---

### Epic 5: Quick Actions Panel (RCON)
**ID:** BG-WEB-002-05
**File:** epic-BG-WEB-002-05-quick-actions.md
**Priority:** P2 (Could Have)

**Summary:** Execute common RCON commands directly from dashboard, including whitelist management, save operations, and player broadcasts. Command whitelist prevents dangerous operations.

**Key Deliverables:**
- RCON API route (`POST /api/admin/rcon`)
- SSH-based command execution (docker exec rcon-cli)
- QuickActions component with command dropdown
- Whitelisted commands: whitelist add/remove/list, save-all, say, list
- Input validation and sanitization
- Rate limiting (10 commands per minute)
- Command output display
- Security: no stop/restart/op commands allowed

**Depends On:** Epic 1, 2
**Blocks:** Epic 6

---

### Epic 6: Polish & Security Audit
**ID:** BG-WEB-002-06
**File:** epic-BG-WEB-002-06-polish-security.md
**Priority:** P0 (Must Have)

**Summary:** Final polish including mobile responsiveness testing, comprehensive security review, rate limiting implementation, audit logging, and documentation updates.

**Key Deliverables:**
- Mobile responsiveness testing and fixes
- Security audit (auth, API routes, input validation)
- Rate limiting on all API routes (60 req/min/session)
- Audit logging for start/stop actions
- CORS configuration
- Documentation updates
- Cross-browser testing
- Error boundary components

**Depends On:** Epic 1, 2, 3, 4, 5
**Blocks:** Nothing (final epic)

---

## Technical Stack

**Framework:** Astro 4.x with hybrid rendering (extends BH-WEB-001)
**Authentication:** Auth.js (NextAuth.js) with GitHub OAuth
**Session Storage:** Cloudflare KV (7-day TTL)
**AWS Integration:** @aws-sdk/client-ec2
**Styling:** Tailwind CSS (shared with marketing site)
**Deployment:** Cloudflare Pages + Workers
**Monitoring:** Cloudflare Workers Analytics

---

## Success Criteria

The project is successful when:

1. GitHub OAuth authentication works reliably
2. Only authorized user can access `/dashboard`
3. Server status displays accurately with auto-refresh
4. Start/stop buttons work consistently with < 3s response time
5. Cost estimation is within 10% accuracy
6. Dashboard is fully functional on mobile devices
7. No security vulnerabilities in auth or API routes
8. Admin can manage server without SSH or AWS Console

---

## Dependencies & Sequencing

**Critical Path:**
```
Epic 1 (Authentication)
  → Epic 2 (Server Controls)
    → Epic 3 (Cost Estimation)
    → Epic 4 (Logs Viewer)
    → Epic 5 (Quick Actions)
      → Epic 6 (Polish & Security)
```

**Parallel Work Opportunities:**
- Epics 3, 4, and 5 can be worked on in parallel after Epic 2 completes
- AWS IAM user setup can happen during Epic 1
- GitHub OAuth app creation can happen before development starts

---

## Environment Variables Required

```bash
# GitHub OAuth
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ADMIN_GITHUB_USERNAMES=prillcode,familymember1,familymember2  # Comma-separated list

# Auth.js
AUTH_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# AWS Credentials
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2

# EC2 Instance
EC2_INSTANCE_ID=i-026059416cf185c9f

# Minecraft Server
MC_SERVER_IP=play.bhsmp.com
```

---

## Architecture Notes

**Hybrid Rendering Extensions:**
- `/dashboard` uses **SSR** with authentication
- `/login` uses **SSR** for OAuth flow
- `/api/admin/*` routes use **SSR** (Cloudflare Workers)
- Marketing pages remain **static**

**Security Model:**
- Multiple authorized users (GitHub username whitelist via env var)
- Session-based authentication (KV storage)
- IAM least privilege (only start/stop one instance)
- RCON command whitelist
- Rate limiting on all endpoints

---

## Related Documentation

- **Source PRD:** [web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md](../../web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md)
- **Marketing Site PRD:** [web/.docs/ASTRO-SITE-PRD.md](../../web/.docs/ASTRO-SITE-PRD.md)
- **Marketing Site Epics (BH-WEB-001):** [INDEX.md](./INDEX.md)
- **AWS Deployment:** [mc-server/aws/README.md](../../mc-server/aws/README.md)

---

## Next Steps

To proceed with story creation:

```bash
/sl-story-creator epic-BG-WEB-002-01-authentication.md
```

Or use the guided story creation to break down each epic into implementable user stories.

---

**Status:** Ready for Story Creation
**Last Updated:** January 25, 2026
