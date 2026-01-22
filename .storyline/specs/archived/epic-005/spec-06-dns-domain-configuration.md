---
spec_id: 06
story_id: 006
epic_id: 005
title: DNS Configuration and Domain Setup
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 06: DNS Configuration and Domain Setup

## Overview

**User story:** [.storyline/stories/epic-005/story-06-dns-domain-configuration.md](../../stories/epic-005/story-06-dns-domain-configuration.md)

**Goal:** Configure DNS A records for bhsmp.com and www.bhsmp.com to point to the Hetzner VPS IP address (5.161.69.191), verify DNS propagation globally, and ensure the domain is accessible via web browsers.

**Approach:** Access the domain registrar's DNS management interface, create/update A records for both the root domain (@) and www subdomain pointing to the VPS IP, set appropriate TTL values, and monitor DNS propagation using dig and online DNS checkers.

## Technical Design

### Architecture Decision

**Chosen approach:** Standard DNS A records pointing directly to VPS IP

**Alternatives considered:**
- **Cloudflare DNS proxy (orange cloud)** - Adds DDoS protection and CDN, but adds dependency and complexity; can be added later if needed
- **CNAME for root domain** - Not supported by DNS standards (root must be A record)
- **Route 53 or other managed DNS** - Unnecessary cost/complexity for single domain

**Rationale:** Direct A records are simple, standard, and work with any registrar. No additional services needed. Cloudflare can be added later as an enhancement without changing the core DNS configuration.

### System Components

**Frontend:**
- No code changes - accessible via domain instead of IP

**Backend:**
- No code changes - accessible via domain instead of IP

**Infrastructure:**
- DNS A records at registrar (external configuration)
- No VPS configuration changes needed

**External integrations:**
- Domain registrar DNS management (Namecheap, GoDaddy, Cloudflare, etc.)
- DNS propagation checker services (dnschecker.org, whatsmydns.net)

## Implementation Details

### Files to Create

None - DNS configuration is external (registrar interface).

### Files to Modify

None - DNS configuration is external.

### DNS Records Configuration

#### Required DNS Records

| Type | Name | Value | TTL | Purpose |
|------|------|-------|-----|---------|
| A | @ | 5.161.69.191 | 3600 | Root domain → VPS |
| A | www | 5.161.69.191 | 3600 | www subdomain → VPS |

**Configuration details:**
- **Type:** A record (IPv4 address)
- **Name:**
  - `@` = root domain (bhsmp.com)
  - `www` = www subdomain (www.bhsmp.com)
- **Value:** 5.161.69.191 (Hetzner VPS IP address)
- **TTL:** 3600 seconds (1 hour) during initial setup
  - Lower TTL allows faster changes if mistakes occur
  - Can be increased to 86400 (24 hours) after stable

#### Optional DNS Records (Future Enhancements)

| Type | Name | Value | TTL | Purpose |
|------|------|-------|-----|---------|
| AAAA | @ | (IPv6 address) | 3600 | IPv6 support (if VPS has IPv6) |
| AAAA | www | (IPv6 address) | 3600 | IPv6 support for www |
| CAA | @ | 0 issue "letsencrypt.org" | 3600 | Restrict SSL CA to Let's Encrypt |

### API Contracts

None - DNS configuration is external.

### Database Changes

None

### State Management

None - Stateless DNS configuration.

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** DNS A records configured
**Verification:**
- Access registrar DNS management panel
- Create/update A record: `@ → 5.161.69.191` with TTL 3600
- Create/update A record: `www → 5.161.69.191` with TTL 3600
- Screenshot configuration for documentation
- Wait 5-10 minutes for registrar to save changes

**Story criterion 2:** DNS propagation complete
**Verification:**
- Local test: `dig bhsmp.com +short` (should return 5.161.69.191)
- Local test: `dig www.bhsmp.com +short` (should return 5.161.69.191)
- Global test: https://dnschecker.org/#A/bhsmp.com (check multiple locations)
- Assert: All DNS servers worldwide return 5.161.69.191
- Timeline: Typically propagates in 1-4 hours, max 48 hours

**Story criterion 3:** Domain accessible via browser
**Verification:**
- Open browser (incognito mode to avoid cache)
- Navigate to http://bhsmp.com
- Assert: Website loads (homepage visible)
- Assert: No DNS_PROBE_FINISHED_NXDOMAIN error
- Assert: Browser address bar shows bhsmp.com

**Story criterion 4:** Both www and non-www work
**Verification:**
- Navigate to http://www.bhsmp.com
- Assert: Website loads
- Assert: nginx redirects to https://bhsmp.com (after SSL is configured in Spec 05)
- Test both: `curl -I http://bhsmp.com` and `curl -I http://www.bhsmp.com`

## Testing Requirements

### Unit Tests

N/A - DNS configuration is external infrastructure, no code to test.

### Integration Tests

**Test script:** `test-dns.sh`

```bash
#!/bin/bash
set -e

DOMAIN="bhsmp.com"
EXPECTED_IP="5.161.69.191"

echo "Testing DNS resolution for root domain..."
ROOT_IP=$(dig +short $DOMAIN | tail -n1)
if [ "$ROOT_IP" == "$EXPECTED_IP" ]; then
    echo "✓ Root domain resolves correctly: $DOMAIN → $ROOT_IP"
else
    echo "✗ Root domain resolves to $ROOT_IP (expected $EXPECTED_IP)"
    exit 1
fi

echo "Testing DNS resolution for www subdomain..."
WWW_IP=$(dig +short www.$DOMAIN | tail -n1)
if [ "$WWW_IP" == "$EXPECTED_IP" ]; then
    echo "✓ www subdomain resolves correctly: www.$DOMAIN → $WWW_IP"
else
    echo "✗ www subdomain resolves to $WWW_IP (expected $EXPECTED_IP)"
    exit 1
fi

echo "Testing website accessibility..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN || echo "000")
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 301 ] || [ "$HTTP_CODE" -eq 302 ]; then
    echo "✓ Website accessible via domain (HTTP $HTTP_CODE)"
else
    echo "✗ Website returned HTTP $HTTP_CODE"
    exit 1
fi

echo "Checking DNS TTL..."
TTL=$(dig $DOMAIN | grep "^$DOMAIN" | awk '{print $2}')
echo "Current TTL: $TTL seconds"

echo "✓ All DNS tests passed!"
```

### Manual Testing

- [ ] Configure A records in registrar DNS management
  - [ ] @ (root) → 5.161.69.191, TTL 3600
  - [ ] www → 5.161.69.191, TTL 3600
- [ ] Wait 10 minutes for initial propagation
- [ ] Test local DNS: `dig bhsmp.com +short` (should return 5.161.69.191)
- [ ] Test local DNS: `dig www.bhsmp.com +short` (should return 5.161.69.191)
- [ ] Test global DNS: https://dnschecker.org/#A/bhsmp.com
  - [ ] Check at least 10 locations worldwide
  - [ ] Verify all show correct IP
- [ ] Test website accessibility:
  - [ ] Open http://bhsmp.com in browser
  - [ ] Open http://www.bhsmp.com in browser
  - [ ] Verify homepage loads
- [ ] Test from different devices/networks:
  - [ ] Home network
  - [ ] Mobile data (4G/5G)
  - [ ] VPN or different geographic location
- [ ] Clear browser DNS cache if needed:
  - Chrome: chrome://net-internals/#dns → Clear host cache
  - Firefox: Restart browser
  - Safari: Clear cache
  - Edge: edge://net-internals/#dns → Clear host cache

## Dependencies

**Must complete first:**
- Spec 04: VPS Deployment - VPS must be running and accessible at 5.161.69.191

**Enables:**
- Spec 05: SSL Configuration - Certbot requires DNS to resolve for domain validation
- Spec 07: Production Testing - domain required for final testing

## Risks & Mitigations

**Risk 1:** DNS propagation takes longer than expected (24-48 hours)
**Mitigation:** Set TTL to 3600 (1 hour) before making changes to speed up propagation
**Fallback:** Use https://dnschecker.org to monitor global propagation, wait patiently

**Risk 2:** Old DNS records cached by ISPs or browsers
**Mitigation:** Use incognito/private browsing mode, test from multiple devices/networks
**Fallback:** Clear browser DNS cache, flush local DNS: `sudo dnsmasq --clear-cache` or `ipconfig /flushdns` (Windows)

**Risk 3:** Typo in IP address (wrong VPS IP configured)
**Mitigation:** Double-check IP with `curl ifconfig.me` from VPS to verify correct public IP
**Fallback:** Correct DNS record, wait for TTL to expire (1 hour with TTL 3600)

**Risk 4:** Registrar DNS management interface issues
**Mitigation:** Keep registrar credentials secure, use registrar support if needed
**Fallback:** Transfer DNS management to Cloudflare (free) if registrar is problematic

## Performance Considerations

**DNS resolution time:**
- Initial lookup: 20-100ms (varies by DNS server location)
- Cached lookup: 0ms (browser caches for TTL duration)
- TTL 3600 = browser caches for 1 hour

**Propagation time:**
- Registrar DNS update: 5-10 minutes
- Global propagation: 1-4 hours (typical), up to 48 hours (maximum)
- Lower TTL = faster propagation but more DNS queries

**Optimization strategy:**
- Use TTL 3600 (1 hour) during setup for flexibility
- Increase to TTL 86400 (24 hours) after stable for better caching
- Consider Cloudflare DNS (faster propagation, ~5 minutes globally)

**Benchmarks:**
- DNS query time: <50ms (typical)
- TTL 3600 = 24 DNS queries per day per client
- TTL 86400 = 1 DNS query per day per client

## Security Considerations

**DNS security:**
- A records are public information (not sensitive)
- Consider DNSSEC for added security (prevents DNS spoofing)
- CAA records restrict which CAs can issue certificates for your domain

**Domain security:**
- Enable domain lock at registrar (prevents unauthorized transfers)
- Enable two-factor authentication on registrar account
- Use strong, unique password for registrar account
- Keep registrar contact email secure

**DDoS protection:**
- Cloudflare can provide free DDoS protection (optional)
- Hetzner provides some DDoS protection at network level
- Consider adding Cloudflare if site becomes high-traffic target

## Success Verification

After implementation, verify:
- [ ] A records configured in registrar DNS panel
- [ ] Screenshot of DNS configuration saved for documentation
- [ ] `dig bhsmp.com +short` returns 5.161.69.191
- [ ] `dig www.bhsmp.com +short` returns 5.161.69.191
- [ ] https://dnschecker.org shows correct IP globally (10+ locations)
- [ ] http://bhsmp.com loads in browser (homepage visible)
- [ ] http://www.bhsmp.com loads in browser
- [ ] No DNS errors in browser (no NXDOMAIN, no SERVFAIL)
- [ ] Test from multiple devices/networks (home, mobile, VPN)
- [ ] DNS test script passes (`./test-dns.sh`)
- [ ] Ready to proceed with SSL configuration (Spec 05)

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-06-dns-domain-configuration.md](../../stories/epic-005/story-06-dns-domain-configuration.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**Step-by-step procedure:**

1. **Log in to domain registrar**
   - Common registrars: Namecheap, GoDaddy, Google Domains, Cloudflare
   - Navigate to DNS management for bhsmp.com

2. **Verify current VPS IP**
   ```bash
   # From VPS, check public IP
   curl ifconfig.me
   # Should return: 5.161.69.191
   ```

3. **Configure A records**
   - Root domain (@ or blank):
     - Type: A
     - Name: @ (or leave blank for root)
     - Value: 5.161.69.191
     - TTL: 3600
   - www subdomain:
     - Type: A
     - Name: www
     - Value: 5.161.69.191
     - TTL: 3600

4. **Save and wait**
   - Click "Save" or "Update" in registrar interface
   - Wait 5-10 minutes for registrar to process changes

5. **Verify local DNS**
   ```bash
   # Test root domain
   dig bhsmp.com +short
   # Expected: 5.161.69.191

   # Test www subdomain
   dig www.bhsmp.com +short
   # Expected: 5.161.69.191

   # Check full DNS info
   dig bhsmp.com
   ```

6. **Monitor global propagation**
   - Visit https://dnschecker.org/#A/bhsmp.com
   - Check multiple locations (US, Europe, Asia)
   - Green checkmarks = propagated
   - Red X = not yet propagated
   - Refresh every 15-30 minutes

7. **Test accessibility**
   ```bash
   # Test HTTP connectivity
   curl -I http://bhsmp.com
   # Should return 200 OK or redirect

   # Test from browser
   # Open http://bhsmp.com in incognito mode
   ```

8. **Increase TTL after stable (optional)**
   - After 24-48 hours of stable operation
   - Change TTL from 3600 to 86400
   - Reduces DNS query load, improves performance

**Common registrar-specific notes:**

- **Namecheap:**
  - Advanced DNS → Host Records
  - Use `@` for root, `www` for www subdomain
  - TTL is dropdown (select "1 Hour")

- **GoDaddy:**
  - DNS Management → Add Record
  - Use `@` for root, `www` for www
  - TTL defaults to 600 (10 min), change to 3600

- **Cloudflare:**
  - DNS → Add Record
  - Use `@` for root, `www` for www
  - Orange cloud = proxied (DDoS protection), Gray cloud = DNS only
  - For initial setup, use **gray cloud** (DNS only) to verify VPS works
  - Can enable orange cloud later for DDoS protection

- **Google Domains:**
  - DNS → Custom Records
  - Use `@` for root, `www` for www
  - TTL defaults to 3600

**Troubleshooting:**

- **dig returns NXDOMAIN**: DNS not yet propagated, wait longer
- **dig returns old IP**: DNS cached, wait for TTL to expire (max 1 hour with TTL 3600)
- **Browser shows DNS_PROBE_FINISHED_NXDOMAIN**: Clear browser DNS cache, try incognito mode
- **Some locations show old IP, some show new**: Normal during propagation, wait 1-2 hours
- **Website times out**: DNS correct, but VPS firewall blocking port 80/443 (check Spec 04)

**Open questions:**
- Should we use Cloudflare for DNS? (Decided: Optional, can add later without disruption)
- Should we configure IPv6 (AAAA records)? (Decided: Not needed for MVP, Hetzner provides IPv6 but not required)

**Assumptions:**
- Domain bhsmp.com is owned and registrar credentials are available
- VPS is running and accessible at 5.161.69.191
- No existing DNS records conflict with this configuration
- Registrar supports standard A record configuration (all modern registrars do)

**Future enhancements:**
- Add CAA records: `bhsmp.com. CAA 0 issue "letsencrypt.org"`
- Enable DNSSEC at registrar for additional security
- Add Cloudflare DNS proxy for DDoS protection and CDN
- Configure IPv6 AAAA records if VPS has IPv6 address
- Set up subdomain for API if needed (api.bhsmp.com)

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-06-dns-domain-configuration.md`
