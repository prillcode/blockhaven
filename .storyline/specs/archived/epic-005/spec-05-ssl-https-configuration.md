---
spec_id: 05
story_id: 005
epic_id: 005
title: SSL Certificates and HTTPS Configuration
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 05: SSL Certificates and HTTPS Configuration

## Overview

**User story:** [.storyline/stories/epic-005/story-05-ssl-https-configuration.md](../../stories/epic-005/story-05-ssl-https-configuration.md)

**Goal:** Install Let's Encrypt SSL certificates using Certbot, configure nginx to serve the website over HTTPS with automatic HTTP→HTTPS and www→non-www redirects, and set up automatic certificate renewal.

**Approach:** Use Certbot with the webroot plugin to obtain Let's Encrypt certificates for both bhsmp.com and www.bhsmp.com, configure nginx with strong SSL settings and security headers, set up redirects for HTTP and www traffic, and enable Certbot's auto-renewal mechanism.

## Technical Design

### Architecture Decision

**Chosen approach:** Let's Encrypt with Certbot (webroot authentication)

**Alternatives considered:**
- **Cloudflare SSL** - Requires using Cloudflare as DNS proxy, adds dependency, limits control
- **Paid SSL certificates** - Unnecessary expense (~$50-100/year), no technical advantage over Let's Encrypt
- **Self-signed certificates** - Not trusted by browsers, only suitable for development

**Rationale:** Let's Encrypt is free, trusted by all browsers, and Certbot provides full automation for issuance and renewal. Webroot authentication is non-disruptive (doesn't require stopping nginx).

### System Components

**Frontend:**
- No changes (served over HTTPS transparently)

**Backend:**
- No changes (API served over HTTPS transparently)

**Infrastructure:**
- `/etc/nginx/sites-available/blockhaven` - nginx SSL configuration (modify existing)
- `/etc/letsencrypt/live/bhsmp.com/` - SSL certificate files (created by Certbot)
- Certbot cron/systemd timer for auto-renewal (created by Certbot)

**External integrations:**
- Let's Encrypt CA servers (certificate issuance and renewal)

## Implementation Details

### Files to Create

#### `/etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh`
**Purpose:** Script to reload nginx after certificate renewal
**Created by:** Manual creation (Certbot doesn't create this)

```bash
#!/bin/bash
# Reload nginx after certificate renewal
systemctl reload nginx
```

Make executable:
```bash
chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

### Files to Modify

#### `/etc/nginx/sites-available/blockhaven`
**Changes:** Add SSL configuration, redirects, and security headers
**Location:** Replace existing HTTP-only configuration
**Reason:** Enable HTTPS and enforce secure connections

**Before (HTTP-only from Spec 04):**
```nginx
server {
    listen 80;
    server_name bhsmp.com www.bhsmp.com;

    location / {
        proxy_pass http://localhost:80;
        # ... proxy headers
    }
}
```

**After (HTTPS with redirects):**
```nginx
# HTTP → HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name bhsmp.com www.bhsmp.com;

    # Certbot webroot for Let's Encrypt validation
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirect all other HTTP traffic to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# www → non-www redirect (HTTPS)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name www.bhsmp.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/bhsmp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bhsmp.com/privkey.pem;

    # Redirect www to non-www
    return 301 https://bhsmp.com$request_uri;
}

# Main HTTPS server block
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name bhsmp.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/bhsmp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bhsmp.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';

    # SSL session cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/bhsmp.com/chain.pem;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.hypixel.net;" always;

    # Proxy to Docker container
    location / {
        proxy_pass http://localhost:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### API Contracts

None - Infrastructure configuration only.

### Database Changes

None

### State Management

None - Stateless infrastructure configuration.

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** SSL certificate installed via Certbot
**Verification:**
- Manual: Run `sudo certbot certonly --webroot -w /var/www/certbot -d bhsmp.com -d www.bhsmp.com`
- Check: Verify certificates exist at `/etc/letsencrypt/live/bhsmp.com/`
- Check: `sudo nginx -t` (test nginx configuration)
- Check: `sudo systemctl reload nginx`
- Test: Visit https://bhsmp.com in browser
- Assert: Green padlock appears, no certificate warnings

**Story criterion 2:** HTTP automatically redirects to HTTPS
**Verification:**
- Manual: Visit http://bhsmp.com in browser
- Assert: Browser automatically redirects to https://bhsmp.com
- Test: `curl -I http://bhsmp.com`
- Assert: Response includes `HTTP/1.1 301 Moved Permanently` and `Location: https://bhsmp.com`

**Story criterion 3:** www subdomain redirects to non-www
**Verification:**
- Manual: Visit https://www.bhsmp.com in browser
- Assert: Browser automatically redirects to https://bhsmp.com
- Test: `curl -I https://www.bhsmp.com`
- Assert: Response includes `HTTP/1.1 301 Moved Permanently` and `Location: https://bhsmp.com`

**Story criterion 4:** SSL certificate auto-renewal configured
**Verification:**
- Check: `sudo systemctl list-timers | grep certbot` (systemd timer exists)
- Or check: `cat /etc/cron.d/certbot` (cron job exists)
- Test: `sudo certbot renew --dry-run` (test renewal process)
- Assert: Dry run succeeds without errors
- Verify: Renewal hook script exists and is executable

## Testing Requirements

### Unit Tests

N/A - Infrastructure configuration, no code to unit test.

### Integration Tests

**Test script:** `test-ssl.sh`

```bash
#!/bin/bash
set -e

DOMAIN="bhsmp.com"

echo "Testing HTTPS accessibility..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✓ HTTPS site accessible (200 OK)"
else
    echo "✗ HTTPS site returned $HTTP_CODE"
    exit 1
fi

echo "Testing HTTP → HTTPS redirect..."
REDIRECT=$(curl -s -o /dev/null -w "%{redirect_url}" http://$DOMAIN)
if [[ $REDIRECT == https://$DOMAIN* ]]; then
    echo "✓ HTTP redirects to HTTPS"
else
    echo "✗ HTTP redirect failed: $REDIRECT"
    exit 1
fi

echo "Testing www → non-www redirect..."
WWW_REDIRECT=$(curl -s -o /dev/null -w "%{redirect_url}" https://www.$DOMAIN)
if [[ $WWW_REDIRECT == https://$DOMAIN* ]]; then
    echo "✓ www redirects to non-www"
else
    echo "✗ www redirect failed: $WWW_REDIRECT"
    exit 1
fi

echo "Testing HSTS header..."
HSTS=$(curl -s -I https://$DOMAIN | grep -i "strict-transport-security" || echo "")
if [[ $HSTS == *"max-age=31536000"* ]]; then
    echo "✓ HSTS header present"
else
    echo "✗ HSTS header missing"
    exit 1
fi

echo "Testing SSL certificate validity..."
CERT_EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
echo "Certificate expires: $CERT_EXPIRY"

echo "✓ All SSL tests passed!"
```

### Manual Testing

- [ ] Visit https://bhsmp.com - verify green padlock in browser
- [ ] Click padlock icon - verify "Connection is secure"
- [ ] Check certificate details - verify issued by Let's Encrypt
- [ ] Check certificate domains - verify bhsmp.com and www.bhsmp.com both covered
- [ ] Visit http://bhsmp.com - verify auto-redirect to HTTPS
- [ ] Visit https://www.bhsmp.com - verify redirect to https://bhsmp.com (non-www)
- [ ] Check SSL Labs test: https://www.ssllabs.com/ssltest/analyze.html?d=bhsmp.com
  - [ ] Verify A or A+ rating
- [ ] Test on multiple browsers (Chrome, Firefox, Safari, Edge)
- [ ] Test on mobile devices (no certificate warnings)
- [ ] Verify contact form submission works over HTTPS
- [ ] Check browser console - no mixed content warnings

## Dependencies

**Must complete first:**
- Spec 04: VPS Deployment with nginx - nginx must be installed and running
- Spec 06: DNS Configuration - domain must point to VPS for Certbot domain validation

**Enables:**
- Spec 07: Production Testing - HTTPS required for full production testing
- Modern browser features (service workers, geolocation, etc.) require HTTPS

## Risks & Mitigations

**Risk 1:** Certbot domain validation fails if DNS not propagated
**Mitigation:** Verify DNS resolution before running Certbot: `dig bhsmp.com +short`
**Fallback:** Wait 24-48 hours for DNS propagation, then retry

**Risk 2:** Certificate renewal fails silently, certificates expire
**Mitigation:** Certbot sends email notifications before expiry
**Fallback:** Monitor certificate expiry with external tool (e.g., SSL Labs monitoring)

**Risk 3:** nginx reload during renewal causes brief downtime
**Mitigation:** nginx reload is graceful (existing connections maintained)
**Fallback:** Use `nginx -s reload` instead of `systemctl reload` for faster reload

**Risk 4:** Strong cipher suite breaks compatibility with old browsers
**Mitigation:** Chosen ciphers support 99%+ of browsers (TLS 1.2+, released 2008)
**Fallback:** Add weaker ciphers if specific legacy browser support required

## Performance Considerations

**SSL/TLS overhead:**
- Initial handshake: ~100-200ms additional latency (one-time per session)
- Session resumption: ~10ms (cached sessions)
- HTTP/2 over HTTPS: Faster than HTTP/1.1 (multiplexing, header compression)

**Optimization strategy:**
- Enable HTTP/2 (already in config: `listen 443 ssl http2`)
- SSL session cache (10MB cache stores ~40,000 sessions)
- OCSP stapling (reduces client-side certificate verification time)

**Benchmarks:**
- HTTPS overhead: <5% compared to HTTP (negligible)
- SSL Labs test should show A or A+ rating
- Certificate verification: <50ms with OCSP stapling

## Security Considerations

**SSL/TLS security:**
- TLS 1.2 and 1.3 only (TLS 1.0/1.1 deprecated, vulnerable)
- Modern cipher suites (ECDHE for forward secrecy, AES-GCM for authenticated encryption)
- OCSP stapling (prevents OCSP privacy leak)

**HTTP Strict Transport Security (HSTS):**
- max-age=31536000 (1 year) - browsers remember to use HTTPS
- includeSubDomains - applies to all subdomains
- preload - eligible for browser HSTS preload list (future enhancement)

**Content Security Policy (CSP):**
- Restricts resource loading to prevent XSS attacks
- Allows self-hosted assets, inline scripts/styles (required by React), external API calls

**Certificate management:**
- Let's Encrypt certificates valid for 90 days
- Auto-renewal runs twice daily (Certbot default)
- Email notifications if renewal fails
- Renewal occurs 30 days before expiry (60-day buffer)

## Success Verification

After implementation, verify:
- [ ] Certbot certificate issuance succeeds
- [ ] Certificates exist at `/etc/letsencrypt/live/bhsmp.com/`
- [ ] nginx configuration test passes (`sudo nginx -t`)
- [ ] nginx reload succeeds (`sudo systemctl reload nginx`)
- [ ] Website accessible via https://bhsmp.com (green padlock)
- [ ] HTTP → HTTPS redirect works (test with curl)
- [ ] www → non-www redirect works (test with curl)
- [ ] HSTS header present (test with curl -I)
- [ ] SSL Labs test shows A or A+ rating
- [ ] No certificate warnings in browser
- [ ] No mixed content warnings in browser console
- [ ] Certbot auto-renewal test succeeds (`sudo certbot renew --dry-run`)
- [ ] Renewal hook script executable and working
- [ ] All manual testing checklist items pass

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-05-ssl-https-configuration.md](../../stories/epic-005/story-05-ssl-https-configuration.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**Prerequisites:**
- Domain bhsmp.com must point to VPS (DNS A record)
- nginx must be running on VPS
- Port 80 open for Certbot domain validation

**Installation commands:**

```bash
# Install Certbot
sudo apt update
sudo apt install -y certbot

# Create webroot directory for Certbot
sudo mkdir -p /var/www/certbot

# Obtain certificate (interactive, provide email when prompted)
sudo certbot certonly --webroot \
  -w /var/www/certbot \
  -d bhsmp.com \
  -d www.bhsmp.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email

# Create renewal hook script
sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy
sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh > /dev/null <<'EOF'
#!/bin/bash
systemctl reload nginx
EOF
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh

# Update nginx configuration (use content from "Files to Modify" section)
sudo nano /etc/nginx/sites-available/blockhaven

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx

# Test auto-renewal
sudo certbot renew --dry-run
```

**Troubleshooting:**

- **Certbot fails with "Domain not found"**: Verify DNS with `dig bhsmp.com +short`, wait for propagation
- **Certbot fails with "Port 80 connection refused"**: Ensure nginx is running and port 80 is open
- **nginx reload fails**: Check `sudo nginx -t` for syntax errors
- **Mixed content warnings**: Update frontend to use relative URLs or HTTPS URLs
- **Certificate not trusted**: Check `/etc/letsencrypt/live/bhsmp.com/fullchain.pem` is used (not `cert.pem`)
- **HSTS not working**: Ensure `add_header` directive is in server block, not location block

**Open questions:**
- Should we submit domain to HSTS preload list? (Decided: Not for MVP, can do later after stable)
- Should we enable CAA DNS records for additional security? (Decided: Optional enhancement, not critical)

**Assumptions:**
- DNS is fully propagated before running Certbot
- Email address provided for Let's Encrypt notifications
- VPS has sufficient disk space for certificates (~10KB per cert)
- Certbot auto-renewal timer/cron is enabled by default (it is on Ubuntu)

**Future enhancements:**
- Submit to HSTS preload list: https://hstspreload.org/
- Add CAA DNS records: `bhsmp.com. CAA 0 issue "letsencrypt.org"`
- Monitor certificate expiry with external service (e.g., Uptime Robot, SSL Labs)
- Consider wildcard certificates if adding subdomains (e.g., api.bhsmp.com)

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-05-ssl-https-configuration.md`
