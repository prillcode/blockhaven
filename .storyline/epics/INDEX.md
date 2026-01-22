# BlockHaven Marketing Website - Epic Index

**Project:** BlockHaven Astro Marketing Website
**Identifier:** BH-WEB-001
**Source PRD:** web/.docs/ASTRO-SITE-PRD.md
**Created:** January 22, 2026

---

## Overview

This epic collection covers the complete implementation of the BlockHaven marketing website using Astro, Tailwind CSS, and Cloudflare Pages. The website serves as the public-facing presence for an invite-only, family-friendly Minecraft server, providing server information and handling whitelist requests via email.

**Key Goals:**
1. Inform invited players about server features, worlds, and gameplay
2. Capture whitelist requests from extended family and friends
3. Provide documentation on how to connect and play
4. Auto-generate content from existing markdown documentation
5. Deploy on Cloudflare Pages with custom domain (bhsmp.com)

---

## Epic Breakdown

### Epic 1: Site Foundation & Infrastructure
**ID:** BH-WEB-001-01
**File:** epic-BH-WEB-001-01-site-foundation.md
**Priority:** P0 (Must Have)

**Summary:** Establish the technical foundation with Astro 4.x, Cloudflare adapter for hybrid rendering, Tailwind CSS with Minecraft theme, and complete project structure supporting both static marketing pages and future SSR requirements.

**Key Deliverables:**
- Astro project with Cloudflare adapter
- Tailwind configured with Minecraft color palette
- TypeScript setup
- Project directory structure (pages, components, layouts, lib, content)
- Placeholder dashboard route
- Environment variables configuration

**Blocks:** Epic 2, 3, 4, 5

---

### Epic 2: Content System & Data Layer
**ID:** BH-WEB-001-02
**File:** epic-BH-WEB-001-02-content-system.md
**Priority:** P0 (Must Have)

**Summary:** Build automated content extraction system that parses existing markdown docs (README, PLUGINS, WORLDS) into structured, type-safe Astro Content Collections, eliminating manual duplication and ensuring website stays synchronized with server documentation.

**Key Deliverables:**
- Markdown parser utility
- Astro Content Collections for worlds and plugins
- TypeScript interfaces (World, Plugin, Command)
- World descriptions for all 6 worlds
- Server rules content
- Content extraction from 4 source docs

**Depends On:** Epic 1
**Blocks:** Epic 3

---

### Epic 3: Core Pages & Components
**ID:** BH-WEB-001-03
**File:** epic-BH-WEB-001-03-pages-components.md
**Priority:** P0 (Must Have)

**Summary:** Build complete user-facing website with all 6 pages, reusable components (Header, Footer, WorldCard, FeatureCard, ServerStatus), and fully responsive design inspired by Storyline site. Includes real-time server status widget using mcstatus.io API.

**Key Deliverables:**
- 6 pages: Home, Worlds, Rules, Plugins, Connect, Request
- Layout components (BaseLayout, Header, Footer)
- UI components (WorldCard, FeatureCard, ServerStatus, Badge, Button)
- Responsive design (mobile, tablet, desktop)
- Hamburger navigation for mobile
- Server Status widget with mcstatus.io integration

**Depends On:** Epic 1, 2
**Blocks:** Epic 4, 5

---

### Epic 4: Request Form & API Integration
**ID:** BH-WEB-001-04
**File:** epic-BH-WEB-001-04-form-api-integration.md
**Priority:** P0 (Must Have)

**Summary:** Implement secure whitelist request system with validated form, Cloudflare Worker API route, Resend email integration, and IP-based rate limiting (3 submissions per 15 minutes) to prevent spam abuse.

**Key Deliverables:**
- RequestForm component with client-side validation
- API route (`/api/request-access`) running on Cloudflare Workers
- Server-side validation and sanitization
- Resend API integration for email delivery
- Rate limiting (3 per 15 min per IP)
- Success/error states and loading indicators
- Accessible form (ARIA labels, keyboard navigation)

**Depends On:** Epic 1, 3
**Blocks:** Epic 5

---

### Epic 5: Deployment & Production
**ID:** BH-WEB-001-05
**File:** epic-BH-WEB-001-05-deployment-production.md
**Priority:** P0 (Must Have)

**Summary:** Deploy to Cloudflare Pages with custom domain (bhsmp.com), achieve 90+ Lighthouse scores, ensure WCAG AA accessibility compliance, optimize performance (< 2s load time), and establish automated git-based deployment pipeline.

**Key Deliverables:**
- Cloudflare Pages project setup
- Custom domain configuration (bhsmp.com)
- SSL certificate provisioning
- Environment variables in production
- Image optimization (WebP, lazy loading)
- Lighthouse scores: 90+ performance, accessibility, SEO
- Meta tags, Open Graph, sitemap.xml
- Cross-browser and mobile device testing
- Automated deployments on git push

**Depends On:** Epic 1, 2, 3, 4
**Blocks:** Nothing (final epic)

---

## Technical Stack

**Framework:** Astro 4.x with hybrid rendering
**Styling:** Tailwind CSS 3.x with Minecraft theme
**Deployment:** Cloudflare Pages + Workers
**Email:** Resend API (3,000 emails/month free)
**Form Backend:** Cloudflare Workers (100k requests/day free)
**Domain:** bhsmp.com
**Source Control:** Git + GitHub

---

## Success Criteria

The project is successful when:

1. ✅ Website deployed to bhsmp.com via Cloudflare Pages
2. ✅ All 6 pages live and functional
3. ✅ Request form sends emails to admin
4. ✅ Content accurately reflects server documentation
5. ✅ Site responsive on mobile, tablet, desktop
6. ✅ Lighthouse performance score 90+
7. ✅ Admin can update content by editing markdown and redeploying

---

## Dependencies & Sequencing

**Critical Path:**
```
Epic 1 (Foundation)
  → Epic 2 (Content System)
    → Epic 3 (Pages & Components)
      → Epic 4 (Form & API)
        → Epic 5 (Deployment)
```

**Parallel Work Opportunities:**
- Epic 2 and Epic 3 can be worked on in parallel after Epic 1 completes (if content is manually created initially)
- Epic 4 and Epic 5 preparation (Cloudflare account setup, domain purchase) can happen anytime

---

## Architecture Notes

**Hybrid Rendering:**
- Marketing pages (Home, Worlds, Rules, etc.) are **static** for optimal performance and SEO
- API routes (`/api/*`) use **SSR** (Cloudflare Workers)
- Future admin dashboard (`/dashboard`) will use **SSR** with auth (Phase 2)

**Future Phases:**
This project establishes the foundation for Phase 2 (Admin Dashboard), which will add:
- GitHub OAuth authentication
- AWS SDK integration for EC2 management
- Server start/stop controls
- Cost estimation and monitoring
- RCON command execution

See: `web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md`

---

## Related Documentation

- **Source PRD:** [web/.docs/ASTRO-SITE-PRD.md](../web/.docs/ASTRO-SITE-PRD.md)
- **Admin Dashboard PRD (Phase 2):** [web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md](../web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md)
- **Server README:** [README.md](../README.md)
- **AWS Deployment:** [mc-server/aws/README.md](../mc-server/aws/README.md)

---

## Next Steps

To proceed with story creation:

```bash
/storyline:sl-story-creator epic-BH-WEB-001-01-site-foundation.md
```

Or use the guided story creation to break down each epic into implementable user stories.

---

**Status:** Ready for Story Creation
**Last Updated:** January 22, 2026