# Epic 5: Deployment & Production

**Epic ID:** BH-WEB-001-05
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-PRD.md

---

## Business Goal

Deploy the BlockHaven marketing website to production on Cloudflare Pages with custom domain (bhsmp.com), achieving 90+ Lighthouse performance score, ensuring accessibility compliance, and establishing automated deployment pipeline for future updates via git push.

## User Value

**Who Benefits:** All users, server administrators

**How They Benefit:**
- **Visitors:** Fast-loading website (< 2 seconds) with 99.9% uptime
- **Mobile users:** Optimized performance on slow connections
- **Admins:** Automatic deployments on git push (no manual deployment steps)
- **Everyone:** Professional custom domain (bhsmp.com) builds trust and credibility
- **Accessibility:** WCAG AA compliance ensures site is usable by everyone

## Success Criteria

- [ ] Website deployed to Cloudflare Pages and accessible via URL
- [ ] Custom domain `bhsmp.com` configured and DNS propagated
- [ ] HTTPS working with valid SSL certificate
- [ ] All environment variables configured in Cloudflare Pages
- [ ] Lighthouse performance score 90+ on desktop and mobile
- [ ] Lighthouse accessibility score 90+
- [ ] Lighthouse SEO score 90+
- [ ] All pages load in < 2 seconds on 3G connection
- [ ] Automated deployments working (git push triggers build)
- [ ] Production form submissions work and emails deliver

## Scope

### In Scope
- **Cloudflare Pages Setup:**
  - Create Cloudflare Pages project
  - Connect to git repository (GitHub)
  - Configure build settings (Astro build command, output directory)
  - Set up automatic deployments on git push

- **Domain Configuration:**
  - Configure custom domain `bhsmp.com` in Cloudflare Pages
  - Update Cloudflare DNS records
  - Verify SSL certificate provisioning
  - Test HTTPS redirect (HTTP → HTTPS)

- **Environment Variables:**
  - Add all required env vars to Cloudflare Pages
  - Verify secrets are encrypted and not exposed to client
  - Test API routes with production environment variables

- **Performance Optimization:**
  - Image optimization (WebP format, lazy loading, proper sizing)
  - Add favicon and Open Graph image
  - Minimize JavaScript bundle size
  - Enable Astro's built-in optimizations
  - Test and optimize Core Web Vitals (LCP, FID, CLS)

- **Accessibility Audit:**
  - Run Lighthouse accessibility checks
  - Fix any WCAG AA violations
  - Test keyboard navigation
  - Verify screen reader compatibility
  - Ensure color contrast meets standards

- **SEO & Meta Tags:**
  - Add proper meta descriptions to all pages
  - Configure Open Graph tags (og:title, og:description, og:image)
  - Add robots.txt
  - Add sitemap.xml
  - Verify Google indexing (optional, for future)

- **Production Testing:**
  - Verify all pages load correctly
  - Test request form submission end-to-end
  - Verify admin receives email
  - Test rate limiting in production
  - Test on real mobile devices
  - Cross-browser testing (Chrome, Firefox, Safari, Edge)

### Out of Scope
- Content creation beyond technical SEO (content already authored in Epic 2)
- Marketing or social media setup
- Analytics beyond basic Cloudflare analytics
- CDN configuration beyond Cloudflare's default
- Database setup (no database needed)
- Monitoring/alerting setup (rely on Cloudflare uptime)

## Technical Notes

**Cloudflare Pages Build Settings:**
```bash
Build command: npm run build
Build output directory: dist
Root directory: web
Node version: 18 or 20
```

**Environment Variables for Cloudflare Pages:**
```
RESEND_API_KEY=re_xxxxxxxxxxxxx
ADMIN_EMAIL=your-email@example.com
MC_SERVER_IP=play.bhsmp.com
MC_SERVER_PORT=25565
```

**DNS Configuration:**
```
bhsmp.com          A     (Cloudflare proxy)
www.bhsmp.com      CNAME bhsmp.com
```

**Performance Targets:**
- Lighthouse Performance: 90+
- First Contentful Paint (FCP): < 1.8s
- Largest Contentful Paint (LCP): < 2.5s
- Cumulative Layout Shift (CLS): < 0.1
- Total Blocking Time (TBT): < 300ms

**Image Optimization:**
```astro
<!-- Use Astro's Image component -->
<Image
  src={worldImage}
  alt="SMP Plains world"
  width={800}
  height={600}
  format="webp"
  loading="lazy"
/>
```

**Open Graph Tags:**
```html
<meta property="og:title" content="BlockHaven - Family-Friendly Minecraft Server" />
<meta property="og:description" content="Join our invite-only Minecraft server..." />
<meta property="og:image" content="https://bhsmp.com/og-image.png" />
<meta property="og:url" content="https://bhsmp.com" />
```

## Dependencies

**Depends On:**
- Epic 1: Site Foundation & Infrastructure
- Epic 2: Content System & Data Layer
- Epic 3: Core Pages & Components
- Epic 4: Request Form & API Integration

**Blocks:** Nothing (final epic)

## Risks & Mitigations

**Risk:** DNS propagation delays
- **Likelihood:** Medium
- **Impact:** Low
- **Mitigation:** DNS typically propagates in minutes with Cloudflare; can use Cloudflare preview URL temporarily

**Risk:** Environment variable misconfiguration in production
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Test thoroughly with Wrangler locally; verify env vars after deployment

**Risk:** Performance issues on slow connections
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Test on 3G throttled connection; optimize images; minimize JS

**Risk:** Form submissions fail in production
- **Likelihood:** Low
- **Impact:** High
- **Mitigation:** Test end-to-end before announcing site; have fallback contact method

## Acceptance Criteria

### Cloudflare Pages Setup
- [ ] Cloudflare Pages project created and linked to git repository
- [ ] Build succeeds on Cloudflare (view build logs)
- [ ] Preview URL accessible and functional
- [ ] Automatic deployments enabled (git push triggers build)
- [ ] Build time < 5 minutes

### Custom Domain
- [ ] `bhsmp.com` configured as custom domain
- [ ] DNS records updated in Cloudflare
- [ ] SSL certificate provisioned automatically
- [ ] HTTPS working (`https://bhsmp.com`)
- [ ] HTTP redirects to HTTPS
- [ ] `www.bhsmp.com` redirects to `bhsmp.com` (or vice versa)

### Environment Variables
- [ ] All required env vars added to Cloudflare Pages
- [ ] `RESEND_API_KEY` set and working
- [ ] `ADMIN_EMAIL` set correctly
- [ ] `MC_SERVER_IP` and `MC_SERVER_PORT` configured
- [ ] Secrets not exposed in client-side code

### Performance - Lighthouse Scores
- [ ] **Performance: 90+** (desktop)
- [ ] **Performance: 85+** (mobile - more lenient)
- [ ] **Accessibility: 90+**
- [ ] **Best Practices: 90+**
- [ ] **SEO: 90+**

### Performance - Core Web Vitals
- [ ] Largest Contentful Paint (LCP) < 2.5s
- [ ] First Input Delay (FID) < 100ms
- [ ] Cumulative Layout Shift (CLS) < 0.1
- [ ] First Contentful Paint (FCP) < 1.8s
- [ ] Time to Interactive (TTI) < 3.8s

### Image Optimization
- [ ] All images converted to WebP format
- [ ] Images have proper width/height attributes (prevent CLS)
- [ ] Images lazy-load (below-the-fold images)
- [ ] Favicon added (16x16, 32x32, 192x192)
- [ ] Open Graph image created (1200x630)

### Accessibility
- [ ] All links have descriptive text (no "click here")
- [ ] All images have alt text
- [ ] Form inputs have proper labels
- [ ] Color contrast meets WCAG AA (4.5:1 for normal text, 3:1 for large)
- [ ] Keyboard navigation works on all pages
- [ ] Focus indicators visible on interactive elements
- [ ] Semantic HTML used throughout (header, nav, main, footer, article)
- [ ] No accessibility errors in Lighthouse

### SEO & Meta Tags
- [ ] Every page has unique `<title>` tag
- [ ] Every page has meta description (150-160 chars)
- [ ] Open Graph tags on all pages
- [ ] Canonical URLs set correctly
- [ ] `robots.txt` allows indexing
- [ ] `sitemap.xml` generated and accessible
- [ ] Structured data for organization/website (optional)

### Production Testing - Functional
- [ ] All 6 pages load without errors
- [ ] Navigation works (header, footer links)
- [ ] Request form submits successfully
- [ ] Admin receives email after form submission
- [ ] Server Status widget displays correctly
- [ ] Copy IP button works
- [ ] All internal links work (no 404s)

### Production Testing - Cross-Browser
- [ ] Chrome (latest version)
- [ ] Firefox (latest version)
- [ ] Safari (latest version, macOS + iOS)
- [ ] Edge (latest version)

### Production Testing - Devices
- [ ] iPhone (Safari, iOS latest)
- [ ] Android phone (Chrome, latest)
- [ ] iPad (Safari, iPadOS latest)
- [ ] Desktop (1920x1080)
- [ ] Laptop (1366x768)

### Production Testing - Network Conditions
- [ ] Fast 4G (throttle to 4G in DevTools)
- [ ] Slow 3G (throttle to 3G in DevTools)
- [ ] Pages load in < 2 seconds on 3G

### Deployment Pipeline
- [ ] Git push to main branch triggers automatic build
- [ ] Build logs accessible in Cloudflare Pages dashboard
- [ ] Build failures send notifications (optional)
- [ ] Preview deployments work for pull requests (optional)

### Documentation
- [ ] Deployment process documented in web/README.md
- [ ] Environment variables listed in web/.env.example
- [ ] Domain configuration documented
- [ ] Troubleshooting guide for common issues

## Related User Stories

From PRD:
- User Story 11: "As a mobile user, I want the site to work perfectly on my phone" (performance on mobile)
- All user stories benefit from successful deployment

## Cloudflare Pages Setup Steps

1. **Create Project:**
   - Log in to Cloudflare dashboard
   - Go to Pages → Create a project
   - Connect to GitHub repository
   - Select `blockhaven` repository
   - Configure build settings

2. **Build Settings:**
   - Build command: `npm run build`
   - Build output directory: `dist`
   - Root directory: `web`
   - Node version: 18

3. **Environment Variables:**
   - Add all env vars from `.env.example`
   - Verify secrets are encrypted

4. **Custom Domain:**
   - Pages → Custom domains → Add domain
   - Enter `bhsmp.com`
   - Update DNS as instructed

5. **Test Deployment:**
   - Trigger manual build
   - Wait for build to complete
   - Visit preview URL
   - Verify site works

## Performance Optimization Checklist

- [ ] Enable Astro's built-in image optimization
- [ ] Lazy-load images below the fold
- [ ] Minify CSS and JavaScript (Astro does this automatically)
- [ ] Use system fonts or load Google Fonts efficiently
- [ ] Minimize number of fonts and weights
- [ ] Remove unused CSS (PurgeCSS via Tailwind)
- [ ] Inline critical CSS (Astro handles this)
- [ ] Compress images (use WebP, optimize quality to 80-85%)
- [ ] Set proper cache headers (Cloudflare handles this)
- [ ] Enable HTTP/3 (Cloudflare enables by default)

## Success Metrics

After deployment, verify:
- [ ] Website accessible at https://bhsmp.com
- [ ] All pages load in < 2 seconds
- [ ] Form submissions deliver emails within 10 seconds
- [ ] Lighthouse scores meet targets
- [ ] No console errors in production
- [ ] Cloudflare analytics showing traffic

## Notes

- Cloudflare Pages provides unlimited bandwidth on free tier
- SSL certificates auto-renew every 90 days
- Automatic deployments reduce deployment friction for future updates
- Keep an eye on Resend email quota (3,000/month free tier)

---

**Previous Epic:** Epic 4 - Request Form & API Integration

**All Epics Complete!** Ready to proceed with story creation via `/storyline:sl-story-creator`
