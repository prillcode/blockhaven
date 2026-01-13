---
spec_id: 07
story_id: 007
epic_id: 005
title: Production Testing and Lighthouse Optimization
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 07: Production Testing and Lighthouse Optimization

## Overview

**User story:** [.storyline/stories/epic-005/story-07-production-testing-optimization.md](../../stories/epic-005/story-07-production-testing-optimization.md)

**Goal:** Perform comprehensive testing of the production website at https://bhsmp.com across all browsers and devices, verify all features work correctly, run Google Lighthouse audits to ensure performance scores ≥90 in all categories, and optimize based on audit recommendations.

**Approach:** Execute systematic manual testing across browsers (Chrome, Firefox, Safari, Edge) and devices (desktop, tablet, mobile), verify all features end-to-end, run Lighthouse audits in Chrome DevTools, analyze Core Web Vitals (FCP, LCP, CLS, TBT), identify and fix performance bottlenecks, and achieve ≥90 scores in Performance, Accessibility, Best Practices, and SEO.

## Technical Design

### Architecture Decision

**Chosen approach:** Manual testing with Lighthouse audits + real device testing

**Alternatives considered:**
- **Automated E2E testing (Playwright, Cypress)** - Good for CI/CD but overkill for manual MVP launch verification
- **BrowserStack for cross-browser** - Paid service, not needed for MVP (test on local browsers + physical devices)
- **Load testing (k6, Artillery)** - Out of scope for MVP, single VPS sufficient for initial traffic

**Rationale:** Manual testing provides comprehensive verification for MVP launch. Lighthouse audits are free, accurate, and correlate with real-world performance. Real device testing catches issues browser DevTools emulation misses.

### System Components

**Frontend:**
- No code changes - verify existing implementation works

**Backend:**
- No code changes - verify existing API works

**Infrastructure:**
- No changes - verify existing deployment works

**External integrations:**
- Google Lighthouse (Chrome DevTools)
- PageSpeed Insights (https://pagespeed.web.dev/)
- WebPageTest (optional, additional insights)

## Implementation Details

### Files to Create

#### `docs/PRODUCTION-TEST-REPORT.md`
**Purpose:** Document production testing results and Lighthouse scores
**Template:**

```markdown
# Production Test Report

**Date:** 2026-01-12
**URL:** https://bhsmp.com
**Tester:** [Your Name]

## Lighthouse Scores

### Desktop
- Performance: __/100
- Accessibility: __/100
- Best Practices: __/100
- SEO: __/100

### Mobile
- Performance: __/100
- Accessibility: __/100
- Best Practices: __/100
- SEO: __/100

## Core Web Vitals

- First Contentful Paint (FCP): __s (target: <1.8s)
- Largest Contentful Paint (LCP): __s (target: <2.5s)
- Cumulative Layout Shift (CLS): __ (target: <0.1)
- Total Blocking Time (TBT): __ms (target: <200ms)

## Feature Testing

### All Pages Load
- [ ] Home (/)
- [ ] About (/about)
- [ ] Rules (/rules)
- [ ] Voting (/voting)
- [ ] Contact (/contact)

### Interactive Features
- [ ] Server status widget displays live data
- [ ] Server status updates every 30 seconds
- [ ] Contact form submits successfully
- [ ] Copy IP button copies to clipboard
- [ ] Dark mode toggles correctly
- [ ] Dark mode persists after page refresh
- [ ] All navigation links work

### Cross-Browser Compatibility
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)

### Cross-Device Testing
- [ ] Desktop (1920x1080)
- [ ] Laptop (1366x768)
- [ ] Tablet (768x1024)
- [ ] Mobile (375x667)

## Issues Found

| Issue | Severity | Page | Status |
|-------|----------|------|--------|
| | | | |

## Recommendations

1.
2.
3.

## Sign-off

- [ ] All critical issues resolved
- [ ] Lighthouse scores ≥90 in all categories
- [ ] Ready for public launch

**Tester Signature:** _______________
**Date:** _______________
```

### Files to Modify

None - Testing and verification only, no code changes.

### API Contracts

None - Testing verifies existing contracts work.

### Database Changes

None

### State Management

None

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Comprehensive production testing
**Verification:**
- Manual test: Navigate to all pages (Home, About, Rules, Voting, Contact)
- Assert: All pages load without 404 or 500 errors
- Manual test: Test server status widget
- Assert: Widget displays player count and online status
- Assert: Status updates after 30 seconds
- Manual test: Submit contact form
- Assert: Form submits successfully, toast notification appears
- Manual test: Click "Copy IP" button
- Assert: IP copied to clipboard, toast notification appears
- Manual test: Toggle dark mode
- Assert: Theme changes, preference persists after refresh
- Check: Browser console has no errors (F12 → Console tab)

**Story criterion 2:** Cross-browser compatibility
**Verification:**
- Test in Chrome: All features work, no console errors
- Test in Firefox: All features work, no console errors
- Test in Safari: All features work, no console errors
- Test in Edge: All features work, no console errors
- Visual check: Styling consistent across browsers
- Document: Screenshot each browser for reference

**Story criterion 3:** Mobile responsiveness
**Verification:**
- Test on iPhone (375x667 or actual device)
- Assert: Touch interactions work (tap, scroll, swipe)
- Assert: Text readable without zooming
- Assert: Navigation menu collapses to hamburger icon
- Assert: All features work (server status, contact form, dark mode, copy IP)
- Test on Android (360x640 or actual device)
- Assert: Same responsiveness as iPhone
- Test on tablet (768x1024)
- Assert: Layout adapts appropriately

**Story criterion 4:** Lighthouse performance audit passes
**Verification:**
- Open Chrome DevTools (F12) → Lighthouse tab
- Select: Desktop, Performance + Accessibility + Best Practices + SEO
- Run audit (incognito mode, clear cache)
- Assert: Performance ≥90/100
- Assert: Accessibility ≥90/100
- Assert: Best Practices ≥90/100
- Assert: SEO ≥90/100
- Check Core Web Vitals:
  - FCP <1.8s ✓
  - LCP <2.5s ✓
  - CLS <0.1 ✓
  - TBT <200ms ✓
- Repeat for Mobile device
- Export results as JSON/PDF for documentation

## Testing Requirements

### Unit Tests

N/A - Production verification, not new code.

### Integration Tests

N/A - Manual testing is the integration test.

### Manual Testing

#### Comprehensive Feature Testing Checklist

**All Pages Load (200 OK):**
- [ ] Home: https://bhsmp.com/
- [ ] About: https://bhsmp.com/about
- [ ] Rules: https://bhsmp.com/rules
- [ ] Voting: https://bhsmp.com/voting
- [ ] Contact: https://bhsmp.com/contact
- [ ] 404 page: https://bhsmp.com/nonexistent (should show custom 404)

**Server Status Widget:**
- [ ] Widget visible on homepage
- [ ] Displays online/offline status correctly
- [ ] Shows player count (e.g., "15/100 players online")
- [ ] Green indicator with pulse animation when online
- [ ] Red indicator (no pulse) when offline
- [ ] Status updates automatically after 30 seconds (watch Network tab)
- [ ] No errors in console during polling

**Contact Form:**
- [ ] Form visible on Contact page
- [ ] Required field validation works (try submitting empty form)
- [ ] Email format validation works (try invalid email)
- [ ] Submit button shows loading state (spinner, disabled)
- [ ] Success: Form submits, toast notification appears, form clears
- [ ] Check Discord webhook: Message appears in Discord channel
- [ ] Error handling: Stop backend API, verify error toast appears

**Copy IP Button:**
- [ ] Button visible on homepage (near server status)
- [ ] Click button → IP "5.161.69.191:25565" copied to clipboard
- [ ] Success toast appears: "IP copied to clipboard!"
- [ ] Paste test: Ctrl+V pastes the correct IP
- [ ] Button shows success state briefly (checkmark, green color)

**Dark Mode:**
- [ ] Toggle button visible in navigation
- [ ] Click toggle → Theme changes (light → dark or dark → light)
- [ ] Color scheme changes throughout site (background, text, borders)
- [ ] Preference persists: Refresh page, theme remains same
- [ ] localStorage check: Open DevTools → Application → Local Storage → verify "theme" key
- [ ] Works across pages: Toggle on homepage, navigate to About, verify theme persists

**Navigation:**
- [ ] All navigation links work (Home, About, Rules, Voting, Contact)
- [ ] Active page highlighted in navigation
- [ ] Logo link returns to homepage
- [ ] Footer links work (if any)
- [ ] Mobile: Hamburger menu opens/closes correctly
- [ ] Mobile: Menu links work, menu closes after click

**HTTPS and Security:**
- [ ] URL shows "https://" (not "http://")
- [ ] Green padlock in browser address bar
- [ ] Click padlock → "Connection is secure"
- [ ] Certificate valid (issued by Let's Encrypt)
- [ ] No mixed content warnings (check console)
- [ ] HTTP redirects to HTTPS (test http://bhsmp.com)
- [ ] www redirects to non-www (test https://www.bhsmp.com)

#### Cross-Browser Testing

**Chrome (latest):**
- [ ] All features work
- [ ] No console errors
- [ ] Styling correct
- [ ] Performance acceptable (<3s load time)

**Firefox (latest):**
- [ ] All features work
- [ ] No console errors
- [ ] Styling correct (check for Firefox-specific CSS issues)
- [ ] Performance acceptable

**Safari (latest):**
- [ ] All features work (test on macOS or iOS)
- [ ] No console errors
- [ ] Styling correct (Safari has strict CSS standards)
- [ ] Clipboard API works (Safari was late adopter)
- [ ] Dark mode respects system preference

**Edge (latest):**
- [ ] All features work
- [ ] No console errors
- [ ] Styling correct
- [ ] Performance acceptable

#### Cross-Device Testing

**Desktop (1920x1080):**
- [ ] Layout uses full width appropriately
- [ ] Navigation horizontal (not hamburger)
- [ ] All content visible without scrolling (above fold)
- [ ] Text readable (not too small, not too large)

**Laptop (1366x768):**
- [ ] Layout adapts to smaller width
- [ ] No horizontal scrolling
- [ ] Navigation still horizontal (if screen >768px)
- [ ] Content readable

**Tablet (768x1024 - iPad):**
- [ ] Layout responsive (1-2 columns depending on section)
- [ ] Touch interactions work (tap, scroll)
- [ ] Navigation may collapse to hamburger (design decision)
- [ ] Forms easy to fill on touchscreen
- [ ] Text readable without zooming

**Mobile (375x667 - iPhone SE):**
- [ ] Layout single column
- [ ] Navigation collapses to hamburger icon
- [ ] Hamburger opens/closes correctly
- [ ] Touch interactions work (buttons large enough, 44x44px minimum)
- [ ] Text readable without zooming (16px minimum)
- [ ] No horizontal scrolling
- [ ] Forms easy to fill (input fields large enough)
- [ ] Copy IP button works on mobile
- [ ] Dark mode toggle accessible

**Large Mobile (414x896 - iPhone 12):**
- [ ] Similar to 375x667 but test for layout edge cases

**Android Phone (360x640 - common size):**
- [ ] All mobile tests same as iPhone
- [ ] Test different browser (Chrome Android)

#### Lighthouse Audit Procedure

**Desktop Audit:**
1. Open https://bhsmp.com in Chrome Incognito mode
2. Open Chrome DevTools (F12)
3. Navigate to "Lighthouse" tab
4. Settings:
   - Mode: Navigation
   - Device: Desktop
   - Categories: Performance, Accessibility, Best Practices, SEO
5. Click "Analyze page load"
6. Wait for audit to complete (30-60 seconds)
7. Review scores:
   - Performance: Target ≥90 (ideal: 95+)
   - Accessibility: Target ≥90 (ideal: 100)
   - Best Practices: Target ≥90 (ideal: 100)
   - SEO: Target ≥90 (ideal: 100)
8. Expand "View Treemap" → Check bundle sizes
9. Export report: "Save as JSON" and "Save as HTML"

**Mobile Audit:**
1. Repeat same steps as Desktop
2. Change Device: Mobile (emulates slow 4G connection)
3. Mobile scores typically lower due to network throttling
4. Performance target: ≥85 (mobile is stricter)

**Core Web Vitals Verification:**
- FCP (First Contentful Paint): <1.8s (green), 1.8-3s (yellow), >3s (red)
- LCP (Largest Contentful Paint): <2.5s (green), 2.5-4s (yellow), >4s (red)
- CLS (Cumulative Layout Shift): <0.1 (green), 0.1-0.25 (yellow), >0.25 (red)
- TBT (Total Blocking Time): <200ms (green), 200-600ms (yellow), >600ms (red)

**Common Issues and Fixes:**

If Performance <90:
- Large bundle size → Check Epic 004 Spec 08 (code splitting)
- Large images → Compress images, use WebP format
- Render-blocking resources → Use async/defer on scripts
- No caching headers → Check Epic 005 Spec 01 (nginx caching)

If Accessibility <90:
- Missing alt text on images → Add descriptive alt attributes
- Low color contrast → Adjust text/background colors (WCAG AA: 4.5:1)
- Missing ARIA labels → Add aria-label to icon buttons
- No keyboard focus indicators → Ensure :focus styles visible

If Best Practices <90:
- Mixed content (HTTP resources on HTTPS page) → Update to HTTPS URLs
- Console errors → Fix JavaScript errors
- Deprecated APIs → Update code to use modern APIs
- No HTTPS → Check Epic 005 Spec 05 (SSL configuration)

If SEO <90:
- Missing meta description → Add <meta name="description">
- Missing title tag → Ensure every page has unique <title>
- Non-crawlable links → Use <a href> not <div onclick>
- Missing robots.txt → Create robots.txt allowing crawlers

## Dependencies

**Must complete first:**
- Spec 01-06: All deployment specs (Docker, VPS, SSL, DNS)
- Epic 004 Spec 08: Performance optimizations should be implemented

**Enables:**
- Public launch announcement
- Marketing campaigns
- Player acquisition efforts

## Risks & Mitigations

**Risk 1:** Lighthouse score <90 due to unforeseen performance issues
**Mitigation:** Epic 004 Spec 08 already implemented performance optimizations
**Fallback:** Analyze Lighthouse recommendations, implement quick fixes (compress images, defer scripts)

**Risk 2:** Critical bugs found in production that weren't caught in development
**Mitigation:** Comprehensive testing checklist covers all features
**Fallback:** Rollback to previous Docker image, fix bug, redeploy

**Risk 3:** Mobile devices show layout issues not visible in DevTools emulation
**Mitigation:** Test on real physical devices (iPhone, Android)
**Fallback:** Fix responsive CSS, redeploy frontend container

**Risk 4:** Third-party API (Hypixel) slow or unavailable, affecting Lighthouse score
**Mitigation:** Backend caches Hypixel responses (Epic 003 Spec 02)
**Fallback:** Accept slightly lower score if third-party issue, not our code

## Performance Considerations

**Lighthouse scoring factors:**
- Bundle size: Target <150KB gzipped (Epic 004 Spec 08 optimized)
- Image optimization: Use WebP, lazy loading (Epic 004 Spec 08)
- Caching headers: Set in nginx (Epic 005 Spec 01)
- Gzip compression: Enabled in nginx (Epic 005 Spec 01)
- Code splitting: Implemented in Epic 004 Spec 08

**Target metrics:**
- Desktop Performance: ≥95/100 (excellent)
- Mobile Performance: ≥85/100 (good)
- Page load time: <2 seconds on 3G (Lighthouse simulated)
- Time to Interactive: <3 seconds

**Real-world performance:**
- First visit (no cache): 2-3 seconds
- Return visit (cache): 0.5-1 second
- Navigation (SPA): instant (no page reload)

## Security Considerations

**Production security checks:**
- HTTPS enforced (HTTP redirects)
- SSL certificate valid and trusted
- Security headers present (HSTS, X-Frame-Options, X-Content-Type-Options)
- No mixed content warnings
- CORS configured correctly (backend API)
- Rate limiting active (backend API)
- No sensitive data exposed (API keys, env vars)

**Verify in browser:**
- Open DevTools → Security tab
- Should show: "This page is secure (valid HTTPS)"
- Certificate viewer shows Let's Encrypt cert

## Success Verification

After implementation, verify:
- [ ] All pages load successfully (200 OK)
- [ ] All features tested and working (server status, contact form, dark mode, copy IP)
- [ ] Cross-browser testing complete (Chrome, Firefox, Safari, Edge)
- [ ] Cross-device testing complete (desktop, tablet, mobile)
- [ ] Lighthouse Desktop: Performance ≥90, Accessibility ≥90, Best Practices ≥90, SEO ≥90
- [ ] Lighthouse Mobile: Performance ≥85, Accessibility ≥90, Best Practices ≥90, SEO ≥90
- [ ] Core Web Vitals: FCP <1.8s, LCP <2.5s, CLS <0.1, TBT <200ms
- [ ] No console errors on any page
- [ ] HTTPS enforced, green padlock in browser
- [ ] Production test report completed and saved
- [ ] Ready for public launch announcement

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-07-production-testing-optimization.md](../../stories/epic-005/story-07-production-testing-optimization.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**Testing tools:**
- Chrome DevTools Lighthouse (built-in)
- PageSpeed Insights: https://pagespeed.web.dev/
- WebPageTest: https://webpagetest.org/ (optional, more detailed)
- GTmetrix: https://gtmetrix.com/ (optional alternative)
- SSL Labs: https://www.ssllabs.com/ssltest/ (SSL verification)

**Real device testing:**
- Use physical devices if available (iPhone, Android phone, iPad)
- If not available, borrow from friends/family for testing
- BrowserStack/LambdaTest are paid alternatives (not needed for MVP)

**Lighthouse best practices:**
- Run in Incognito mode (no extensions interfering)
- Clear cache before audit (Cmd+Shift+R / Ctrl+Shift+R)
- Run audit 3 times, take average score (results vary slightly)
- Test at different times of day (network conditions vary)
- Mobile scores typically 5-10 points lower than desktop (normal)

**Documentation:**
- Save Lighthouse reports (JSON/HTML) for future reference
- Take screenshots of each browser/device
- Document all issues found and resolutions
- Create PRODUCTION-TEST-REPORT.md with findings

**Open questions:**
- Should we set up continuous Lighthouse monitoring? (Decided: Not for MVP, can add later with CI/CD)
- Should we run load testing? (Decided: Not for MVP, single VPS handles expected traffic)

**Assumptions:**
- All Epic 001-004 implementations are complete and bug-free
- Epic 005 Spec 01-06 deployments successful
- Production environment mirrors local development environment
- Expected initial traffic: <1000 visitors/day (VPS can handle easily)

**Future enhancements:**
- Implement Google Analytics or Plausible for real user monitoring (RUM)
- Set up automated Lighthouse CI checks on every deploy
- Configure real user monitoring (RUM) for actual Core Web Vitals data
- Set up Sentry or similar for error tracking
- Implement A/B testing for conversion optimization
- Add load testing (k6, Artillery) before scaling to high traffic

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-07-production-testing-optimization.md`
