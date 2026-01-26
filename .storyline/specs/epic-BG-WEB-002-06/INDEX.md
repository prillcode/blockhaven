# Epic BG-WEB-002-06: Polish & Security - Technical Specs Index

## Overview

This epic covers the final polish, security hardening, and documentation for the admin dashboard.

**Total Stories:** 6
**Total Specs:** 3 (stories combined logically)

## Specs

| Spec | Stories | Title | Complexity | Status |
|------|---------|-------|------------|--------|
| [spec-01](spec-01-rate-limiting.md) | 01 | Implement Rate Limiting for API Endpoints | Medium | Ready |
| [spec-02](spec-02-audit-logging.md) | 02 | Add Audit Logging for Sensitive Actions | Simple | Ready |
| [spec-03-04-05-06](spec-03-04-05-06-polish.md) | 03, 04, 05, 06 | Error Boundaries, Mobile Polish, Security Audit, and Documentation | Medium | Ready |

## Implementation Order

1. **spec-01** - Rate limiting (requires KV setup)
2. **spec-02** - Audit logging (requires KV setup)
3. **spec-03-04-05-06** - Polish and finalization

## KV Namespaces Required

```bash
# Create namespaces
wrangler kv:namespace create BLOCKHAVEN_RATE_LIMITS
wrangler kv:namespace create BLOCKHAVEN_AUDIT

# Add IDs to wrangler.toml
```

## Key Files Created

| File | Purpose |
|------|---------|
| `src/lib/rateLimit.ts` | Rate limiting module |
| `src/lib/audit.ts` | Audit logging module |
| `src/components/admin/ErrorBoundary.tsx` | Error handling |
| `docs/ADMIN-SETUP.md` | Setup documentation |

## Security Checklist Summary

- OAuth with state validation
- JWT sessions with 7-day expiry
- HttpOnly, Secure, SameSite cookies
- Protected routes via middleware
- Input validation on all endpoints
- Strict RCON command whitelist
- Rate limiting per user
- Audit logging of sensitive actions

## To Execute All Specs

```bash
# In order:
/sl-develop .storyline/specs/epic-BG-WEB-002-06/spec-01-rate-limiting.md
/sl-develop .storyline/specs/epic-BG-WEB-002-06/spec-02-audit-logging.md
/sl-develop .storyline/specs/epic-BG-WEB-002-06/spec-03-04-05-06-polish.md
```
