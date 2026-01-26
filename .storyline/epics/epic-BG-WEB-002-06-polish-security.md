# Epic 6: Polish & Security Audit

**Epic ID:** BG-WEB-002-06
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md

---

## Business Goal

Ensure the admin dashboard is production-ready with comprehensive security hardening, mobile responsiveness, proper error handling, and documentation. This final epic validates the entire system before launch.

## User Value

**Who Benefits:** Authorized admins, server security

**How They Benefit:**
- Secure access: Confidence that the dashboard is protected against attacks
- Smooth experience: Polish mobile UX for management on the go
- Reliability: Proper error handling prevents confusing failures
- Maintainability: Documentation enables future updates

## Success Criteria

- [ ] Security audit complete with no critical/high vulnerabilities
- [ ] All API routes rate limited appropriately
- [ ] Mobile UX is smooth on iOS Safari and Android Chrome
- [ ] Error boundaries prevent component crashes from breaking dashboard
- [ ] Audit logging captures all sensitive actions
- [ ] Documentation updated with admin dashboard information
- [ ] Cross-browser testing complete (Chrome, Firefox, Safari, Edge)
- [ ] No console errors in production build

## Scope

### In Scope
- Mobile responsiveness testing and fixes
- Security audit (authentication, authorization, input validation)
- Rate limiting on all API routes
- CORS configuration verification
- Audit logging for start/stop and RCON actions
- Error boundary components
- Loading state consistency
- Cross-browser testing
- Accessibility review (WCAG AA)
- Documentation updates
- Production environment verification

### Out of Scope
- New features
- Performance optimization beyond basics
- Automated security scanning tools
- Penetration testing (manual audit only)
- Third-party security certification

## Technical Notes

**Rate Limiting Strategy:**
```typescript
// src/lib/rateLimit.ts
import { KVNamespace } from '@cloudflare/workers-types'

interface RateLimitConfig {
  windowMs: number     // Time window in ms
  maxRequests: number  // Max requests per window
}

const RATE_LIMITS: Record<string, RateLimitConfig> = {
  '/api/admin/server/status': { windowMs: 60000, maxRequests: 120 }, // 2/sec
  '/api/admin/server/start': { windowMs: 60000, maxRequests: 5 },    // 5/min
  '/api/admin/server/stop': { windowMs: 60000, maxRequests: 5 },     // 5/min
  '/api/admin/logs': { windowMs: 60000, maxRequests: 30 },           // 30/min
  '/api/admin/rcon': { windowMs: 60000, maxRequests: 10 },           // 10/min
}

export async function checkRateLimit(
  kv: KVNamespace,
  userId: string,
  endpoint: string
): Promise<{ allowed: boolean; remaining: number; resetAt: number }> {
  const config = RATE_LIMITS[endpoint] || { windowMs: 60000, maxRequests: 60 }
  const key = `ratelimit:${userId}:${endpoint}`

  // Implementation using KV for distributed rate limiting
  // ...
}
```

**Audit Logging:**
```typescript
// src/lib/audit.ts
interface AuditLog {
  timestamp: string
  userId: string
  githubUsername: string
  action: 'server_start' | 'server_stop' | 'rcon_command' | 'login' | 'logout'
  details?: Record<string, unknown>
  ip?: string
  userAgent?: string
}

export async function logAuditEvent(kv: KVNamespace, log: AuditLog): Promise<void> {
  const key = `audit:${Date.now()}:${crypto.randomUUID()}`
  await kv.put(key, JSON.stringify(log), { expirationTtl: 90 * 24 * 60 * 60 }) // 90 days
}
```

**Error Boundary Component:**
```tsx
// src/components/admin/ErrorBoundary.tsx
import { Component, ErrorInfo, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Dashboard error:', error, errorInfo)
    // Could send to error tracking service
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-4 bg-red-900/20 border border-red-500 rounded">
          <h3>Something went wrong</h3>
          <button onClick={() => this.setState({ hasError: false })}>
            Try again
          </button>
        </div>
      )
    }
    return this.props.children
  }
}
```

**Security Checklist Items:**
```markdown
## Authentication
- [ ] GitHub OAuth callback validates state parameter
- [ ] Session tokens are cryptographically secure
- [ ] Sessions expire after 7 days
- [ ] Logout invalidates session in KV

## Authorization
- [ ] All /dashboard routes check authentication
- [ ] All /api/admin/* routes check authentication
- [ ] GitHub username verified against whitelist
- [ ] No privilege escalation possible

## Input Validation
- [ ] All API inputs validated server-side
- [ ] RCON commands strictly whitelisted
- [ ] Username inputs alphanumeric only
- [ ] No SQL/NoSQL injection vectors
- [ ] No command injection vectors

## Output Encoding
- [ ] All user-generated content escaped in UI
- [ ] API responses don't leak sensitive data
- [ ] Error messages don't reveal internals

## Transport Security
- [ ] HTTPS enforced (Cloudflare handles)
- [ ] Secure cookies (HttpOnly, Secure, SameSite)
- [ ] CORS configured for same-origin only

## Secrets Management
- [ ] No secrets in code or logs
- [ ] Environment variables for all credentials
- [ ] AWS credentials have minimal permissions
```

## Dependencies

**Depends On:**
- Epic 1: Authentication
- Epic 2: Server Status & Controls
- Epic 3: Cost Estimation
- Epic 4: Server Logs Viewer
- Epic 5: Quick Actions Panel (if implemented)

**Blocks:**
- Nothing (final epic, production launch)

## Risks & Mitigations

**Risk:** Security vulnerability discovered during audit
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Fix issues before launch, prioritize security over timeline

**Risk:** Mobile UX issues on specific devices
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Test on real devices (not just simulators), fix critical issues

**Risk:** Rate limiting too aggressive
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Start with conservative limits, adjust based on usage

## Acceptance Criteria

### Security Audit
- [ ] Authentication flow reviewed and secure
- [ ] Authorization checks on all protected routes
- [ ] Input validation on all API endpoints
- [ ] No sensitive data in logs or error messages
- [ ] CORS configured for same-origin only
- [ ] Cookies have Secure, HttpOnly, SameSite attributes
- [ ] AWS IAM permissions follow least privilege
- [ ] All security checklist items verified

### Rate Limiting
- [ ] `/api/admin/server/status`: 120 requests/minute
- [ ] `/api/admin/server/start`: 5 requests/minute
- [ ] `/api/admin/server/stop`: 5 requests/minute
- [ ] `/api/admin/logs`: 30 requests/minute
- [ ] `/api/admin/rcon`: 10 requests/minute
- [ ] Rate limit errors return 429 with clear message
- [ ] Rate limits tracked per authenticated user

### Audit Logging
- [ ] Login events logged (success and failure)
- [ ] Logout events logged
- [ ] Server start actions logged with user
- [ ] Server stop actions logged with user
- [ ] RCON commands logged with user and command
- [ ] Logs stored in Cloudflare KV (90-day retention)
- [ ] Logs include timestamp, user, action, IP, user-agent

### Mobile Responsiveness
- [ ] Dashboard layout works on 320px width
- [ ] Touch targets minimum 44x44px
- [ ] No horizontal scroll on main layout
- [ ] Logs viewer has controlled horizontal scroll
- [ ] Buttons large enough for touch
- [ ] Forms work with mobile keyboards
- [ ] Tested on iOS Safari (iPhone)
- [ ] Tested on Android Chrome

### Error Handling
- [ ] Error boundary wraps dashboard sections
- [ ] Network errors show retry option
- [ ] API errors show user-friendly messages
- [ ] Loading states on all async operations
- [ ] No unhandled promise rejections
- [ ] No console errors in production

### Cross-Browser Testing
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] iOS Safari
- [ ] Android Chrome

### Accessibility (WCAG AA)
- [ ] Keyboard navigation works throughout
- [ ] Focus indicators visible
- [ ] Color contrast meets 4.5:1 ratio
- [ ] ARIA labels on interactive elements
- [ ] Error messages associated with inputs
- [ ] Screen reader tested (basic)

### Documentation Updates
- [ ] README updated with admin dashboard info
- [ ] Environment variables documented
- [ ] IAM policy documented
- [ ] CloudWatch setup documented (if using logs)
- [ ] SSM setup documented (if using RCON)
- [ ] Deployment instructions updated

### Production Verification
- [ ] Environment variables set in Cloudflare
- [ ] KV namespaces created (sessions, rate limits, audit)
- [ ] GitHub OAuth callback URL updated for production
- [ ] Test login flow on production
- [ ] Test start/stop on production
- [ ] Monitor for errors after launch

### Directory Structure Additions
```
/web/src/
├── components/
│   └── admin/
│       └── ErrorBoundary.tsx     # Error boundary component
└── lib/
    ├── rateLimit.ts              # Rate limiting utilities
    └── audit.ts                  # Audit logging utilities
```

### Verification Checklist
- [ ] Security audit complete (all checklist items)
- [ ] Rate limiting working on all endpoints
- [ ] Audit logs capturing all actions
- [ ] Mobile testing complete (iOS + Android)
- [ ] Cross-browser testing complete
- [ ] Accessibility basics verified
- [ ] Documentation updated
- [ ] Production deployment verified
- [ ] No critical bugs remaining

## Related User Stories

From PRD:
- Security Considerations section (all items)
- Success Criteria: "No security vulnerabilities in auth or API routes"
- Success Criteria: "Dashboard is fully functional on mobile devices"

## Notes

- This epic should not be rushed - security is critical
- Mobile testing should use real devices when possible
- Consider having another developer review the security audit
- Audit logs help with incident response and debugging
- Rate limiting prevents both abuse and accidental DOS from buggy clients
- Error boundaries prevent one component failure from breaking entire dashboard

---

**Project Complete:** After this epic, the admin dashboard is ready for production use.
