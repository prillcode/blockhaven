# BlockHaven Admin Dashboard - Product Requirements Document

**Document Type:** Product Requirements Document (PRD)
**Project:** BlockHaven Astro Admin Dashboard
**Version:** 1.0
**Date:** January 22, 2026
**Status:** Draft - Future Phase
**Owner:** Aaron Prill
**Depends On:** ASTRO-SITE-PRD.md (Marketing site must be deployed first)

---

## Executive Summary

After the BlockHaven marketing website launches on Cloudflare Pages, Phase 2 will add an authenticated admin dashboard at `/dashboard` to manage the AWS EC2 Minecraft server remotely. This dashboard will provide:

1. **Server Control** - Start/stop the EC2 instance via AWS SDK
2. **Server Monitoring** - View status, player count, uptime
3. **Quick Actions** - RCON commands, log viewing
4. **Whitelist Management** - Add/remove players (future)

The dashboard will use GitHub OAuth for authentication (single admin user) and leverage Cloudflare Workers + AWS SDK for serverless server management.

---

## Problem Statement

### Current Situation
- Server management requires SSH access to EC2 instance
- Starting/stopping server requires AWS Console or AWS CLI
- No centralized dashboard for quick server operations
- Mobile management is cumbersome (SSH from phone)

### Desired Outcome
A secure, mobile-friendly admin dashboard that allows:
- One-click server start/stop from any device
- Real-time server status monitoring
- Quick access to common operations
- No need for SSH or AWS Console for routine tasks

---

## Goals & Success Metrics

### Primary Goals
1. **Simplify server management** - Reduce start/stop operations from 5 steps to 1 click
2. **Mobile accessibility** - Manage server from phone/tablet
3. **Secure access** - GitHub OAuth, single authorized user
4. **Cost monitoring** - Display estimated monthly EC2 costs

### Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| Authentication | GitHub OAuth only | Single admin user |
| Response Time | < 3 seconds | Time from button click to status update |
| Mobile UX | Fully functional on phone | Touch-friendly buttons, responsive layout |
| Security | Zero unauthorized access | Auth logs, session management |
| Uptime | 99.9% | Cloudflare Workers reliability |

---

## User Stories

### Must Have (P0)
1. **As the admin**, I want to log in with GitHub so only I can access the dashboard
2. **As the admin**, I want to see the current server status (online/offline/player count) so I know the server state
3. **As the admin**, I want to start the EC2 instance with one click so I don't need SSH or AWS Console
4. **As the admin**, I want to stop the EC2 instance with one click so I can save costs when not in use
5. **As the admin**, I want to see the server IP address so I can share it with players
6. **As the admin**, I want to be automatically logged out after 7 days so sessions don't stay open indefinitely

### Should Have (P1)
7. **As the admin**, I want to see server uptime (how long it's been running) so I can track usage
8. **As the admin**, I want to see estimated monthly costs so I can monitor AWS billing
9. **As the admin**, I want to view recent server logs so I can troubleshoot issues
10. **As the admin**, I want to see who's currently online so I know when players are active
11. **As the admin**, I want to receive feedback (loading states, success/error messages) so I know when actions complete

### Could Have (P2)
12. **As the admin**, I want to execute RCON commands so I can manage the server remotely
13. **As the admin**, I want to add/remove whitelist players so I don't need to SSH
14. **As the admin**, I want to see daily/weekly usage patterns so I can optimize costs
15. **As the admin**, I want to receive Discord notifications when server is started/stopped

---

## Features & Requirements

### Feature 1: GitHub OAuth Authentication
**Priority:** P0 (Must Have)
**Description:** Secure authentication using GitHub OAuth, restricted to a single authorized user.

**Implementation:**
- Use **Auth.js** (formerly NextAuth.js) with Astro adapter
- Configure GitHub OAuth application
- Store authorized GitHub username in environment variable
- Session stored in Cloudflare KV (7-day TTL)
- All `/dashboard` and `/api/admin/*` routes require authentication

**GitHub OAuth Flow:**
1. User visits `/dashboard`
2. If not authenticated, redirect to `/login`
3. User clicks "Sign in with GitHub"
4. GitHub OAuth redirects back with token
5. Verify user's GitHub username matches `ADMIN_GITHUB_USERNAME`
6. Create session, store in Cloudflare KV
7. Redirect to `/dashboard`

**Session Management:**
- Session expires after 7 days
- Logout clears session from KV
- No refresh tokens (re-auth required after expiry)

**Acceptance Criteria:**
- [ ] Only authorized GitHub user can access `/dashboard`
- [ ] Unauthorized users see error message
- [ ] Session persists across page reloads
- [ ] Logout button works correctly
- [ ] Session expires after 7 days
- [ ] Mobile login flow works smoothly

---

### Feature 2: Server Status Display
**Priority:** P0 (Must Have)
**Description:** Real-time display of EC2 instance and Minecraft server status.

**Data to Display:**
- **EC2 Status:** Running / Stopped / Stopping / Starting
- **Instance ID:** i-026059416cf185c9f
- **Server IP:** play.bhsmp.com (or public IP)
- **Minecraft Status:** Online / Offline / Player Count
- **Uptime:** Time since instance started
- **Region:** us-east-2

**Data Sources:**
1. **EC2 Status:** AWS SDK `describeInstances` API
2. **Minecraft Status:** mcstatus.io API or direct ping
3. **Uptime:** Calculate from EC2 `LaunchTime`

**Refresh:**
- Auto-refresh every 30 seconds
- Manual refresh button
- Loading skeleton during fetch

**Acceptance Criteria:**
- [ ] Status updates every 30 seconds
- [ ] Displays correct instance state
- [ ] Shows player count when server is online
- [ ] Uptime calculation is accurate
- [ ] Manual refresh button works
- [ ] Handles API errors gracefully

---

### Feature 3: Start/Stop Server Controls
**Priority:** P0 (Must Have)
**Description:** One-click buttons to start and stop the EC2 instance.

**Actions:**
- **Start Server:** Calls AWS SDK `startInstances` API
- **Stop Server:** Calls AWS SDK `stopInstances` API with confirmation dialog

**API Routes:**
- `POST /api/admin/server/start`
- `POST /api/admin/server/stop`

**Workflow:**

**Start Server:**
1. User clicks "Start Server" button
2. Button shows loading spinner
3. API route verifies auth
4. Calls AWS SDK to start instance
5. Returns success/error
6. UI updates to show "Starting..." status
7. Auto-refresh detects when instance is running

**Stop Server:**
1. User clicks "Stop Server" button
2. Confirmation dialog: "Stop server? Players will be disconnected."
3. User confirms
4. Button shows loading spinner
5. API route verifies auth
6. Calls AWS SDK to stop instance (with force=false)
7. Returns success/error
8. UI updates to show "Stopping..." status

**Error Handling:**
- AWS throttling errors (rate limits)
- Instance already in requested state
- Network errors
- Permission errors (IAM role issues)

**Acceptance Criteria:**
- [ ] Start button starts the instance
- [ ] Stop button shows confirmation dialog
- [ ] Loading states display during API calls
- [ ] Success/error messages are clear
- [ ] Buttons disabled when action is in progress
- [ ] Handles errors gracefully (retries, error messages)
- [ ] Instance state updates in UI after action

---

### Feature 4: Cost Estimation
**Priority:** P1 (Should Have)
**Description:** Display estimated monthly EC2 costs based on current usage.

**Calculations:**
- **Instance Type:** t3a.large ($0.0752/hour)
- **EBS Storage:** 50GB gp3 ($4.00/month base)
- **Hours This Month:** Track actual runtime hours
- **Projected Monthly Cost:** (Hours so far / Days elapsed) × Days in month × hourly rate + storage

**Display:**
```
💰 Estimated Monthly Cost
Current: $45.20 (15 days, 240 hours)
Projected: $90.40 (if usage continues)

Breakdown:
- EC2 (t3a.large): $72.00
- EBS Storage (50GB): $4.00
- Data Transfer: ~$1.00
```

**Data Source:**
- AWS Cost Explorer API (requires IAM permissions)
- OR calculate from instance start/stop times (simpler, less accurate)

**Acceptance Criteria:**
- [ ] Cost estimate displays on dashboard
- [ ] Shows current month-to-date cost
- [ ] Projects full month cost based on usage pattern
- [ ] Updates when instance state changes
- [ ] Breakdown by service (EC2, EBS)

---

### Feature 5: Server Logs Viewer
**Priority:** P1 (Should Have)
**Description:** View recent Minecraft server logs without SSH.

**Implementation:**
- Use CloudWatch Logs (EC2 instance sends Docker logs to CloudWatch)
- OR create API endpoint that SSH's into instance and runs `docker logs blockhaven-mc --tail 100`
- Display last 100-500 lines in scrollable container

**Display:**
- Monospace font
- Syntax highlighting for log levels (INFO, WARN, ERROR)
- Auto-scroll to bottom option
- Search/filter logs
- Refresh button

**Acceptance Criteria:**
- [ ] Displays last 100-500 log lines
- [ ] Logs are readable (monospace, wrapped)
- [ ] Refresh button fetches latest logs
- [ ] Handles case when server is stopped (shows message)
- [ ] Mobile view is usable (horizontal scroll, readable font size)

---

### Feature 6: Quick Actions Panel
**Priority:** P2 (Could Have)
**Description:** Execute common RCON commands directly from dashboard.

**Commands:**
- `whitelist add <username>`
- `whitelist remove <username>`
- `whitelist list`
- `save-all`
- `say <message>` (broadcast to players)
- `list` (show online players)

**Implementation:**
- API route: `POST /api/admin/rcon`
- SSH into EC2 instance
- Run `docker exec blockhaven-mc rcon-cli <command>`
- Return output

**UI:**
- Dropdown to select common command
- Input field for parameters (username, message, etc.)
- "Execute" button
- Output display

**Security:**
- Whitelist allowed commands (no `stop`, `restart`, etc.)
- Sanitize inputs (prevent command injection)
- Rate limit: 10 commands per minute

**Acceptance Criteria:**
- [ ] Can execute whitelisted RCON commands
- [ ] Command output displays in UI
- [ ] Input validation prevents malicious commands
- [ ] Works only when server is running
- [ ] Shows error if server is stopped

---

## Technical Requirements

### Tech Stack

**Framework:** Astro 4.x with Cloudflare adapter
- **SSR (Server-Side Rendering):** Required for API routes
- **Hybrid rendering:** Static pages for marketing site, SSR for `/dashboard`

**Authentication:** Auth.js (NextAuth.js)
- GitHub OAuth provider
- Session storage in Cloudflare KV
- Astro adapter: `@auth/astro`

**AWS SDK:** `@aws-sdk/client-ec2`
- Start/stop instances
- Describe instances (get status)
- Requires IAM role with permissions

**Styling:** Tailwind CSS (shared with marketing site)

**Deployment:** Cloudflare Pages
- Workers for API routes
- KV for session storage
- Environment variables for secrets

---

### Environment Variables

```bash
# GitHub OAuth (from GitHub Developer Settings)
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Authorized admin GitHub username
ADMIN_GITHUB_USERNAME=yourusername

# Auth.js secret (generate with: openssl rand -base64 32)
AUTH_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# AWS Credentials (IAM user with EC2 permissions)
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-2

# EC2 Instance Details
EC2_INSTANCE_ID=i-026059416cf185c9f
EC2_KEY_PATH=/path/to/blockhaven-key.pem  # For SSH-based features (logs, RCON)

# Minecraft Server
MC_SERVER_IP=play.bhsmp.com
```

---

### IAM Permissions Required

Create an IAM user `blockhaven-dashboard` with this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "arn:aws:ec2:us-east-2:*:instance/i-026059416cf185c9f"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
```

**Principle of Least Privilege:** This policy only allows:
- Describing any instance (needed for API)
- Starting/stopping the specific BlockHaven instance

---

### Project Structure (Additions)

```
/web/
├── src/
│   ├── pages/
│   │   ├── dashboard.astro         # Admin dashboard (protected)
│   │   ├── login.astro             # GitHub OAuth login page
│   │   └── api/
│   │       ├── auth/
│   │       │   └── [...auth].ts    # Auth.js API routes
│   │       └── admin/              # Protected admin API routes
│   │           ├── server/
│   │           │   ├── status.ts   # GET server status
│   │           │   ├── start.ts    # POST start server
│   │           │   └── stop.ts     # POST stop server
│   │           ├── logs.ts         # GET server logs
│   │           └── rcon.ts         # POST execute RCON command
│   ├── components/
│   │   ├── admin/                  # Admin-specific components
│   │   │   ├── ServerStatusCard.tsx
│   │   │   ├── ServerControls.tsx
│   │   │   ├── CostEstimator.tsx
│   │   │   ├── LogsViewer.tsx
│   │   │   └── QuickActions.tsx
│   │   └── AuthButton.astro        # Login/Logout button
│   ├── middleware/
│   │   └── auth.ts                 # Auth middleware for protected routes
│   └── lib/
│       ├── aws.ts                  # AWS SDK helper functions
│       ├── rcon.ts                 # RCON client (SSH + docker exec)
│       └── auth.ts                 # Auth utilities
└── astro.config.mjs                # Cloudflare adapter configuration
```

---

## Implementation Phases

### Phase 1: Authentication Setup (2-3 days)
**Tasks:**
- Configure GitHub OAuth application
- Install and configure Auth.js with Astro
- Set up Cloudflare KV for sessions
- Create `/login` page
- Create `/dashboard` page (placeholder)
- Implement auth middleware
- Test login/logout flow

**Deliverables:**
- [ ] GitHub OAuth working
- [ ] Session management in KV
- [ ] `/dashboard` requires authentication
- [ ] Unauthorized users redirected to login
- [ ] Logout button works

---

### Phase 2: Server Status & Controls (2-3 days)
**Tasks:**
- Set up AWS SDK with IAM credentials
- Create `describeInstances` helper
- Build server status API route
- Create start/stop API routes
- Build ServerStatusCard component
- Build ServerControls component
- Add loading states and error handling
- Test start/stop functionality

**Deliverables:**
- [ ] Server status displays correctly
- [ ] Start button starts instance
- [ ] Stop button stops instance (with confirmation)
- [ ] Loading states work
- [ ] Error messages display

---

### Phase 3: Cost Estimation (1 day)
**Tasks:**
- Implement cost calculation logic
- Create CostEstimator component
- Add to dashboard
- Test calculations

**Deliverables:**
- [ ] Cost estimate displays
- [ ] Calculation is accurate
- [ ] Updates when status changes

---

### Phase 4: Logs Viewer (1-2 days)
**Tasks:**
- Decide on log source (CloudWatch vs SSH)
- Create logs API route
- Build LogsViewer component
- Add syntax highlighting
- Test on mobile

**Deliverables:**
- [ ] Logs display on dashboard
- [ ] Refresh button works
- [ ] Readable on mobile

---

### Phase 5: Quick Actions (Optional, 1-2 days)
**Tasks:**
- Create RCON API route
- Build QuickActions component
- Implement command whitelist
- Add input validation
- Test commands

**Deliverables:**
- [ ] Can execute RCON commands
- [ ] Command output displays
- [ ] Input validation works

---

### Phase 6: Polish & Security Audit (1 day)
**Tasks:**
- Mobile responsiveness testing
- Security review (auth, API routes)
- Rate limiting on API routes
- Add logging/monitoring
- Documentation

**Deliverables:**
- [ ] Mobile UX is smooth
- [ ] Security audit complete
- [ ] Rate limiting implemented
- [ ] Documentation updated

---

## Security Considerations

### Authentication
- GitHub OAuth ensures only GitHub account owner can log in
- `ADMIN_GITHUB_USERNAME` env var restricts to single user
- Session tokens stored in Cloudflare KV (encrypted)
- Sessions expire after 7 days (no refresh tokens)

### API Routes
- All `/api/admin/*` routes verify session token
- Rate limiting: 60 requests per minute per session
- AWS credentials stored as environment variables (never exposed to client)
- CORS restricted to same origin

### AWS Access
- IAM user with minimal permissions (start/stop one specific instance)
- No EC2 termination or modification permissions
- No access to other AWS resources

### RCON Commands
- Command whitelist (only safe commands allowed)
- Input sanitization (prevent command injection)
- No destructive commands (`stop`, `restart`, etc.)

### Audit Logging
- Log all start/stop actions with timestamp and user
- Log failed authentication attempts
- Store logs in Cloudflare Workers Analytics

---

## Risks & Mitigations

### Risk 1: AWS API Rate Limits
**Risk:** AWS may throttle API calls if dashboard polls too frequently
**Impact:** Medium
**Likelihood:** Low
**Mitigation:**
- Refresh status every 30 seconds (well within limits)
- Implement exponential backoff on errors
- Cache status in Cloudflare KV for 10 seconds

---

### Risk 2: Cloudflare KV Latency
**Risk:** Session lookups may add latency to API routes
**Impact:** Low
**Likelihood:** Medium
**Mitigation:**
- KV is fast (< 50ms globally)
- Cache session in request context during single request
- Use edge caching where possible

---

### Risk 3: SSH-based Features Complexity
**Risk:** RCON and logs features require SSH, adding complexity
**Impact:** Medium
**Likelihood:** Medium
**Mitigation:**
- Make these features optional (P2 priority)
- Use CloudWatch Logs instead of SSH for logs (simpler)
- Evaluate if RCON features are truly needed

---

### Risk 4: Mobile UX Challenges
**Risk:** Admin dashboard may be hard to use on small screens
**Impact:** Medium
**Likelihood:** Low
**Mitigation:**
- Mobile-first design approach
- Large, touch-friendly buttons
- Test on real devices
- Simplify UI (only essential actions on mobile)

---

## Success Criteria

The admin dashboard is considered successful when:

1. ✅ GitHub OAuth authentication works reliably
2. ✅ Only authorized user can access `/dashboard`
3. ✅ Server status displays accurately
4. ✅ Start/stop buttons work consistently
5. ✅ Cost estimation is within 10% accuracy
6. ✅ Dashboard is fully functional on mobile devices
7. ✅ No security vulnerabilities in auth or API routes
8. ✅ Admin can manage server without SSH or AWS Console

---

## Appendix

### Reference Projects
- Auth.js Astro Example: https://github.com/nextauthjs/next-auth/tree/main/examples/astro
- Cloudflare KV Docs: https://developers.cloudflare.com/kv/
- AWS SDK v3 EC2 Docs: https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-ec2/

### Related Documents
- [ASTRO-SITE-PRD.md](./ASTRO-SITE-PRD.md) - Marketing site (must be built first)
- [AWS README](../../mc-server/aws/README.md) - EC2 deployment details

---

**Document Status:** Draft - Future Phase
**Next Steps:**
1. Build marketing site (ASTRO-SITE-PRD.md)
2. Deploy to Cloudflare Pages with SSR adapter
3. Return to this PRD to implement admin dashboard
