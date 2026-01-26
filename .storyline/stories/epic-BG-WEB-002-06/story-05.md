---
story_id: 05
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Security Audit & Hardening
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-06-polish-security.md
created: 2026-01-25
---

# Story 05: Security Audit & Hardening

## User Story

**As a** system administrator,
**I want** a comprehensive security audit of the dashboard,
**so that** I'm confident there are no vulnerabilities.

## Acceptance Criteria

### Scenario 1: Authentication audit
**Given** the auth system is implemented
**When** I audit authentication
**Then** GitHub OAuth callback validates state parameter
**And** sessions are cryptographically secure
**And** sessions expire after 7 days
**And** logout properly invalidates sessions

### Scenario 2: Authorization audit
**Given** the auth middleware is implemented
**When** I audit authorization
**Then** all /dashboard routes check authentication
**And** all /api/admin/* routes check authentication
**And** GitHub username is verified against whitelist
**And** no privilege escalation is possible

### Scenario 3: Input validation audit
**Given** API endpoints accept user input
**When** I audit input validation
**Then** all inputs are validated server-side
**And** RCON commands are strictly whitelisted
**And** usernames only allow alphanumeric characters
**And** no injection vectors exist

### Scenario 4: Output encoding audit
**Given** the UI displays data
**When** I audit output encoding
**Then** user-generated content is escaped
**And** API responses don't leak sensitive data
**And** error messages don't reveal internals

### Scenario 5: Transport security audit
**Given** the site uses HTTPS
**When** I audit transport security
**Then** HTTPS is enforced (Cloudflare handles)
**And** cookies have Secure, HttpOnly, SameSite attributes
**And** CORS is configured for same-origin only

### Scenario 6: Secrets management audit
**Given** the system uses API keys
**When** I audit secrets
**Then** no secrets appear in code
**And** no secrets appear in logs
**And** all credentials are in environment variables
**And** AWS credentials have minimal permissions

### Scenario 7: Cross-browser testing
**Given** the dashboard is deployed
**When** I test in different browsers
**Then** Chrome latest works correctly
**And** Firefox latest works correctly
**And** Safari latest works correctly
**And** Edge latest works correctly

### Scenario 8: No console errors
**Given** the production build is deployed
**When** I use the dashboard
**Then** no JavaScript errors appear in console
**And** no unhandled promise rejections occur

## Business Value

**Why this matters:** Security is paramount for a system that controls server infrastructure. A vulnerability could lead to unauthorized access or server abuse.

**Impact:** Confidence that the system is secure for production use.

**Success metric:** Zero critical or high vulnerabilities identified.

## Technical Considerations

**Security Checklist:**
```markdown
## Authentication
- [ ] OAuth state parameter validated
- [ ] Session tokens use crypto.randomUUID() or equivalent
- [ ] Session cookie has HttpOnly flag
- [ ] Session cookie has Secure flag
- [ ] Session cookie has SameSite=Lax or Strict
- [ ] Sessions expire after 7 days
- [ ] Logout clears session from KV
- [ ] Failed login attempts are rate limited

## Authorization
- [ ] Middleware protects /dashboard routes
- [ ] Middleware protects /api/admin/* routes
- [ ] API routes double-check authentication
- [ ] GitHub username check is case-insensitive
- [ ] No way to bypass auth middleware

## Input Validation
- [ ] Username: /^[a-zA-Z0-9_]{3,16}$/
- [ ] RCON commands: strict whitelist
- [ ] Message text: safe character set only
- [ ] No eval() or dynamic code execution
- [ ] JSON.parse wrapped in try/catch

## Output
- [ ] React escapes output by default
- [ ] No dangerouslySetInnerHTML with user data
- [ ] Error messages generic for users
- [ ] Stack traces only in development
- [ ] API errors don't leak paths or config

## Infrastructure
- [ ] HTTPS enforced
- [ ] CORS: Access-Control-Allow-Origin is specific or omitted
- [ ] No Access-Control-Allow-Credentials with wildcard origin
- [ ] CSP headers if applicable
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY (if not in iframe)

## Secrets
- [ ] .env not committed to git
- [ ] No hardcoded API keys
- [ ] No secrets in console.log
- [ ] No secrets in error messages
- [ ] AWS credentials follow least privilege
```

**Testing Tools:**
- Browser DevTools for network/security analysis
- Lighthouse for security headers
- Manual testing of auth flows
- Review IAM policy in AWS Console

## Dependencies

**Depends on stories:**
- All Epic 1-5 stories complete
- Story 01: Rate Limiting
- Story 02: Audit Logging

**Enables stories:**
- Story 06: Documentation

## Out of Scope

- Automated penetration testing
- Third-party security certification
- Bug bounty program
- External security audit

## Notes

- This is a manual audit, not automated scanning
- Focus on OWASP Top 10 categories
- Document any findings and fixes
- Consider having another developer review

## Traceability

**Parent epic:** [epic-BG-WEB-002-06-polish-security.md](../../epics/epic-BG-WEB-002-06-polish-security.md)

**Related stories:** All stories (security applies everywhere)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-06/story-05.md`
