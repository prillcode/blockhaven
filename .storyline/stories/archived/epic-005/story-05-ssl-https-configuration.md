---
story_id: 005
epic_id: 005
title: SSL Certificates and HTTPS Configuration
status: ready_for_spec
created: 2026-01-12
---

# Story 005: SSL Certificates and HTTPS Configuration

## User Story

**As a** website visitor,
**I want** the website to use HTTPS encryption,
**so that** my data (especially contact form submissions) is transmitted securely.

## Acceptance Criteria

### Scenario 1: SSL certificate installed via Certbot
**Given** the domain bhsmp.com points to the VPS
**When** I run Certbot to obtain a Let's Encrypt certificate
**Then** Certbot successfully verifies domain ownership
**And** SSL certificates are installed in /etc/letsencrypt/live/bhsmp.com/
**And** nginx is configured to use the certificates
**And** the website is accessible via https://bhsmp.com

### Scenario 2: HTTP automatically redirects to HTTPS
**Given** the SSL certificates are installed
**When** I visit http://bhsmp.com
**Then** I am automatically redirected to https://bhsmp.com
**And** the redirect is a 301 Moved Permanently
**And** all HTTP traffic is encrypted

### Scenario 3: www subdomain redirects to non-www
**Given** the SSL certificates cover both bhsmp.com and www.bhsmp.com
**When** I visit https://www.bhsmp.com
**Then** I am automatically redirected to https://bhsmp.com
**And** the redirect is a 301 Moved Permanently
**And** only one canonical URL is used

### Scenario 4: SSL certificate auto-renewal configured
**Given** Let's Encrypt certificates expire every 90 days
**When** I check the Certbot auto-renewal cron job
**Then** Certbot is configured to renew certificates automatically
**And** the renewal cron runs twice daily (Certbot default)
**And** nginx reloads automatically after renewal
**And** certificates never expire

## Business Value

**Why this matters:** HTTPS is essential for user trust, data security (especially contact form), and SEO rankings. Google penalizes HTTP-only sites.

**Impact:** Improves user trust (green padlock in browser), protects contact form data, boosts SEO rankings, and enables modern browser features (service workers, geolocation).

**Success metric:** Website accessible via HTTPS, HTTP redirects to HTTPS, SSL certificates auto-renew, browser shows green padlock.

## Technical Considerations

**Potential approaches:**
- Let's Encrypt with Certbot (free, automated, industry standard)
- Alternative: Cloudflare SSL (requires Cloudflare DNS proxy)
- Alternative: Paid SSL certificates (unnecessary expense)

**Constraints:**
- Must use Let's Encrypt (free, trusted by all browsers)
- Must configure nginx for SSL termination
- Must set up HTTP → HTTPS redirect
- Must configure auto-renewal (cron or systemd timer)
- Certificates must cover both bhsmp.com and www.bhsmp.com

**Data requirements:**
- Domain: bhsmp.com
- DNS A records pointing to VPS (from Story 06)
- Email address for Let's Encrypt notifications
- nginx SSL configuration (ssl_certificate, ssl_certificate_key)

## Dependencies

**Depends on stories:**
- Story 04: VPS Deployment - nginx must be installed and configured
- Story 06: DNS Configuration - domain must point to VPS for Certbot verification

**Enables stories:**
- Story 07: Production Testing - HTTPS required for full production testing
- Modern browser features (service workers, PWA, etc.) require HTTPS

## Out of Scope

- Extended Validation (EV) certificates (overkill for small site)
- Custom SSL certificate (Let's Encrypt is sufficient)
- HSTS preload list submission (future security enhancement)
- Certificate pinning (unnecessary for Let's Encrypt)

## Notes

- Let's Encrypt certificates are valid for 90 days and auto-renew every 60 days
- Certbot creates a cron job or systemd timer automatically
- nginx must be configured with strong SSL settings (TLS 1.2+, modern cipher suites)
- Consider adding security headers: HSTS, X-Frame-Options, X-Content-Type-Options
- Certbot webroot or standalone mode (webroot is less disruptive)

## Traceability

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

**Related stories:** Story 04 (VPS nginx), Story 06 (DNS), Story 07 (Production Testing)

---

**Next step:** Run `/spec-story .storyline/stories/epic-005/story-05-ssl-https-configuration.md`
