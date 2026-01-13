# Epic Index

**Generated from:** web/WEB-COMPLETE-PLAN.md
**Created:** 2026-01-10
**Total epics:** 5
**Package manager:** pnpm
**Backend framework:** Hono (instead of Express.js per user preference)

---

## Epics Overview

### Epic 001: Website Foundation & Theme System
**Goal:** Establish Vite + React 19 + TypeScript + Tailwind CSS v4 foundation with dark/light mode
**Stories:** ~6 user stories
**Complexity:** Medium
**Status:** Ready for story creation
**Dependencies:** None (foundation epic)

Provides the technical foundation, base layout components (Header, Footer, Navigation), theme system with localStorage persistence, and Minecraft-themed color palette.

---

### Epic 002: Content Pages & UI Component Library
**Goal:** Build complete content-rich marketing website showcasing 6 worlds and server features
**Stories:** ~10 user stories
**Complexity:** Medium-High
**Status:** Ready for story creation
**Dependencies:** Epic 001 (needs foundation)

Creates reusable UI component library, data structures (worlds, features, rules), all 4 pages (Home, Worlds, Rules, Contact), section components (Hero, WorldsShowcase, FeaturesGrid), and React Router setup.

---

### Epic 003: Backend API Services
**Goal:** Provide secure Hono API for server status monitoring and contact form submissions
**Stories:** ~6 user stories
**Complexity:** Medium
**Status:** Ready for story creation
**Dependencies:** None (can run parallel with Epic 002)

Implements Hono API with two endpoints: GET `/api/server-status` (mcstatus.io integration, 30s caching) and POST `/api/contact` (Discord webhook with rate limiting, input validation).

---

### Epic 004: Interactive Features & Frontend Integration
**Goal:** Transform static site into interactive experience with live server status and functional contact form
**Stories:** ~8 user stories
**Complexity:** Medium-High
**Status:** Ready for story creation
**Dependencies:** Epics 001, 002, 003 (needs foundation, pages, and API)

Creates custom React hooks (useServerStatus, useToast, useLocalStorage), interactive widgets (ServerStatus, ContactForm, CopyIPButton), API integration, toast notifications, and performance optimization.

---

### Epic 005: Docker Deployment & Production Release
**Goal:** Deploy to production on Hetzner VPS with Docker, nginx, SSL, and DNS
**Stories:** ~7 user stories
**Complexity:** Medium
**Status:** Ready for story creation
**Dependencies:** All previous epics (needs complete app)

Handles containerization (Docker + docker-compose), nginx configuration (SPA routing, API proxy), VPS deployment, SSL certificates (Certbot), DNS configuration, and production optimization (Lighthouse 90+).

---

## Execution Order

### Recommended sequence based on dependencies:

**Phase 1 (Parallel Development Possible):**
1. **Epic 001** - Website Foundation & Theme System *(Start here, no dependencies)*
2. **Epic 003** - Backend API Services *(Can start in parallel with Epic 001)*

**Phase 2 (Sequential, depends on Phase 1):**
3. **Epic 002** - Content Pages & UI Component Library *(Depends on: Epic 001)*

**Phase 3 (Sequential, depends on Phase 1 & 2):**
4. **Epic 004** - Interactive Features & Frontend Integration *(Depends on: Epics 001, 002, 003)*

**Phase 4 (Final, depends on all):**
5. **Epic 005** - Docker Deployment & Production Release *(Depends on: All previous epics)*

---

## Technical Stack Summary

**Frontend:**
- React 19 (concurrent rendering)
- TypeScript 5.7
- Vite 6.0 (build tool with HMR)
- Tailwind CSS v4 (with @tailwindcss/vite plugin)
- React Router v7 (client-side routing)
- lucide-react (icons)
- Framer Motion 12 (animations)
- clsx + tailwind-merge (className utilities)

**Backend:**
- **Hono** (modern web framework, TypeScript-first)
- Node.js 20
- @hono/node-server (Node.js adapter)
- mcstatus.io API (server status queries)

**DevOps:**
- Docker + Docker Compose
- Nginx (reverse proxy & static file serving)
- Certbot (SSL certificates)
- Hetzner VPS (hosting)

**Package Manager:**
- **pnpm** (preferred over npm)

---

## Key Features to Implement

1. **6 Unique Worlds Showcase** - Primary focus with detailed pages
2. **Golden Shovel Land Claims** - Prominently featured (FREE, no pay-to-claim)
3. **Live Server Status** - Real-time player count, auto-refresh every 30s
4. **Dark/Light Mode** - Persistent theme with system preference detection
5. **Discord Contact Form** - Secure webhook integration with rate limiting
6. **One-Click IP Copy** - Server IP: 5.161.69.191:25565
7. **Cross-Platform Play** - Java + Bedrock support highlighted
8. **Family-Friendly** - Strict rules, welcoming community

---

## Business Goals

**Primary:** Attract players to BlockHaven Minecraft server
**Secondary:** Showcase unique features (6 worlds, anti-grief, family-friendly)
**Tertiary:** Enable easy server connection and support contact

**Target Outcome:** Live, performant marketing website at https://bhsmp.com that converts visitors into players by highlighting world variety and protection features.

---

## Success Metrics

- Website loads with Lighthouse performance score ≥90
- All 4 pages accessible and functional
- Server status displays accurate real-time data
- Contact form successfully sends to Discord
- Dark/light mode persists across sessions
- Responsive design works on mobile, tablet, desktop
- Zero-downtime deployment achieved

---

## Next Steps

**To begin implementation:**

```bash
# Start with Epic 001 (Foundation)
/story-creator .storyline/epics/epic-001-website-foundation-theme.md

# Or start Epic 003 in parallel (Backend API)
/story-creator .storyline/epics/epic-003-backend-api-services.md
```

**After Epic 001 completes:**
```bash
/story-creator .storyline/epics/epic-002-content-pages-ui-library.md
```

**After Epics 001, 002, 003 complete:**
```bash
/story-creator .storyline/epics/epic-004-interactive-features-integration.md
```

**Final deployment:**
```bash
/story-creator .storyline/epics/epic-005-docker-deployment-production.md
```

---

## Notes

- **Hono vs Express**: User prefers Hono for modern TypeScript support and cleaner API design
- **pnpm vs npm**: User prefers pnpm as package manager
- **No Monetization**: No ranks or donation features in initial launch
- **World Focus**: "Explore Worlds" is primary CTA, not "Join Now"
- **UltimateLandClaim**: FREE golden shovel claiming prominently featured
- **Simplified Navigation**: Only 4 pages (Home, Worlds, Rules, Contact)

---

**Status:** ✅ All epics ready for story creation
**Last Updated:** 2026-01-10
