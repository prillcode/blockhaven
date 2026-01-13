---
story_id: 006
epic_id: 005
title: DNS Configuration and Domain Setup
status: ready_for_spec
created: 2026-01-12
---

# Story 006: DNS Configuration and Domain Setup

## User Story

**As a** potential player,
**I want** to access the BlockHaven website at bhsmp.com,
**so that** I can easily remember and share the website URL.

## Acceptance Criteria

### Scenario 1: DNS A records configured
**Given** I own the domain bhsmp.com
**When** I configure DNS A records with my registrar
**Then** bhsmp.com points to 5.161.69.191 (VPS IP)
**And** www.bhsmp.com points to 5.161.69.191 (VPS IP)
**And** the A records have a TTL of 3600 seconds (1 hour)

### Scenario 2: DNS propagation complete
**Given** DNS A records are configured
**When** I check DNS propagation with `dig bhsmp.com` or online tools
**Then** the domain resolves to 5.161.69.191 globally
**And** DNS propagation completes within 1-24 hours
**And** all DNS servers return the correct IP address

### Scenario 3: Domain accessible via browser
**Given** DNS propagation is complete
**When** I visit http://bhsmp.com in a browser
**Then** the website loads successfully
**And** the browser shows the BlockHaven homepage
**And** no DNS resolution errors occur

### Scenario 4: Both www and non-www work
**Given** DNS A records are configured for both bhsmp.com and www.bhsmp.com
**When** I visit www.bhsmp.com
**Then** the website loads successfully
**And** nginx redirects www to non-www (from Story 05)
**And** both URLs work correctly

## Business Value

**Why this matters:** A memorable domain name (bhsmp.com) is easier to share and remember than an IP address (5.161.69.191), improving brand recognition and accessibility.

**Impact:** Players can easily find and share the website. Domain looks professional and builds trust. Essential for SEO and marketing.

**Success metric:** Website accessible at bhsmp.com and www.bhsmp.com, DNS resolves correctly worldwide.

## Technical Considerations

**Potential approaches:**
- DNS A records pointing directly to VPS IP (simple, standard approach)
- Alternative: Cloudflare DNS proxy (adds DDoS protection, CDN)
- Alternative: CNAME records (not suitable for root domain)

**Constraints:**
- Must configure A records for both root (@) and www subdomain
- TTL should be low (3600s) during initial setup for easy changes
- DNS registrar must support A record configuration
- Must wait for DNS propagation (1-48 hours, typically <24 hours)

**Data requirements:**
- Domain name: bhsmp.com
- VPS IP address: 5.161.69.191
- DNS registrar access
- Optional: Cloudflare account if using Cloudflare DNS

## Dependencies

**Depends on stories:**
- Story 04: VPS Deployment - VPS must be accessible at 5.161.69.191

**Enables stories:**
- Story 05: SSL Configuration - Certbot requires DNS to point to VPS for verification
- Story 07: Production Testing - domain required for final production testing

## Out of Scope

- Email configuration (MX records) - no email service needed
- Subdomain configuration (api.bhsmp.com, etc.) - not needed for MVP
- DNSSEC configuration (security enhancement, not critical)
- Geo-location DNS routing (single VPS, not needed)

## Notes

- DNS propagation time varies (1-48 hours), use https://dnschecker.org to verify
- During propagation, some users may see old IP, some may see new IP
- Consider using Cloudflare for free DDoS protection and CDN (optional)
- Keep old server running during DNS propagation if switching from old hosting
- TTL can be increased to 86400 (24 hours) after initial setup for caching

## Traceability

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

**Related stories:** Story 04 (VPS Deployment), Story 05 (SSL), Story 07 (Production Testing)

---

**Next step:** Run `/spec-story .storyline/stories/epic-005/story-06-dns-domain-configuration.md`
