---
epic_id: 002
title: Content Pages & UI Component Library
status: ready_for_stories
source: web/WEB-COMPLETE-PLAN.md
created: 2026-01-10
---

# Epic 002: Content Pages & UI Component Library

## Business Goal

Build a complete content-rich marketing website that showcases BlockHaven's 6 unique worlds, anti-grief protection, and family-friendly features, enabling potential players to understand the server's value and easily join.

**Target outcome:** Four fully-functional pages (Home, Worlds, Rules, Contact) with reusable UI components, compelling content, and responsive design that converts visitors into players.

## User Value

**Who benefits:** Potential Minecraft server players researching where to play

**How they benefit:** Users discover BlockHaven's unique offerings through an engaging, informative website that highlights the 6 different worlds, FREE golden shovel land claims, and family-friendly environment. The "Explore Worlds" CTA guides them on a journey that leads to copying the server IP and joining.

**Current pain point:** Without this content, users cannot learn about the server's features, understand what makes it unique, or be convinced to join.

## Success Criteria

When this epic is complete:

- [ ] Home page renders with Hero, WorldsShowcase, FeaturesGrid, ServerRules, and CallToAction sections
- [ ] Worlds page displays detailed information about all 6 worlds with screenshots
- [ ] Rules page shows complete server rules with expandable sections
- [ ] Contact page includes FAQ and placeholder for contact form
- [ ] React Router navigation works between all pages with active state highlighting
- [ ] All UI components (Button, Card, Badge, Input, Textarea, Toast, LoadingSpinner) are functional
- [ ] WorldCard component displays world information with difficulty badges
- [ ] Responsive design verified on mobile (320px), tablet (768px), and desktop (1024px+)
- [ ] All world data, features data, and rules data properly structured in TypeScript files

**Definition of Done:**
- All user stories completed
- All 4 pages render without errors
- Routing tested (navigation, back button, direct URLs)
- Responsive design verified on multiple breakpoints
- Content data properly typed with TypeScript
- Framer Motion animations working smoothly
- No console errors or warnings

## Scope

### In Scope
- UI Component Library (8 components): Button, Card, Badge, Input, Textarea, Toast, LoadingSpinner, WorldCard
- Data files: worlds.ts, features.ts, rules.ts (fully populated with BlockHaven content)
- Section components (5): Hero, WorldsShowcase, FeaturesGrid, ServerRules, CallToAction
- Page components (4): Home, Worlds, Rules, Contact
- React Router setup with 4 routes
- TypeScript types: world.ts, rank.ts
- Responsive grid layouts for world showcase
- Framer Motion animations for page transitions and section reveals
- SEO meta tags for all pages
- Utility functions (clsx, tailwind-merge for className management)

### Out of Scope
- Interactive ServerStatus widget - handled in Epic 004
- Functional ContactForm with backend integration - handled in Epic 003 & 004
- ThemeToggle widget - already in Epic 001
- Custom hooks (useServerStatus, useToast, etc.) - handled in Epic 004
- Backend API - handled in Epic 003
- Docker deployment - handled in Epic 005

### Boundaries
This epic focuses on static content, visual design, and page structure. Interactive features that require backend integration or custom hooks are separate epics.

## Dependencies

**Depends on:**
- Epic 001: Website Foundation & Theme System - needs base layout, theme context, and Tailwind configuration

**Enables:**
- Epic 004: Interactive Features & Frontend Integration - provides pages where interactive widgets will be embedded

**Parallel with:**
- Epic 003: Backend API Services - can be developed simultaneously as they're independent

## Estimated Stories

**Story count:** ~10 user stories

**Complexity:** Medium-High

**Estimated effort:** Medium epic (3-4 days)

## Technical Considerations

- **Component Reusability**: UI components must be generic enough to use across all pages
- **Data Structure**: TypeScript interfaces for worlds, features, and rules must be extensible for future enhancements
- **Icon Library**: Use lucide-react for all icons (Shield, Users, Coins, Heart, Globe, Gamepad2)
- **Animation Performance**: Framer Motion animations should use transform/opacity for 60fps performance
- **Image Optimization**: World screenshots should be optimized (<200KB each) for fast loading
- **SEO**: Each page needs unique title, description, and Open Graph tags

## Risks & Assumptions

**Risks:**
- Large number of components could lead to inconsistent design patterns (mitigation: establish clear component API conventions early)
- World screenshots may not be available yet (mitigation: use placeholder images with correct dimensions)
- Content copy may need iteration (mitigation: structure data files for easy updates)

**Assumptions:**
- All 6 world screenshots will be provided or can be generated from the server
- Server rules content is finalized and approved
- UltimateLandClaim feature description is accurate and approved
- Discord invite link is available for Contact page

## Related Epics

- Epic 001: Website Foundation & Theme System - provides base layout and theme
- Epic 003: Backend API Services - provides backend for contact form
- Epic 004: Interactive Features & Frontend Integration - adds interactive widgets to these pages

## Source Reference

**Original PRD/Spec:** web/WEB-COMPLETE-PLAN.md

**Relevant sections:**
- Phase 2: Content & UI (lines 739-768)
- Component Architecture (lines 323-524)
- Pages & Routing (lines 526-618)
- Data Structure (lines 619-704)
- FeaturesGrid - Golden Shovel Land Claims (lines 389-392)
- WorldsShowcase (lines 369-382)

---

**Next step:** Run `/story-creator .storyline/epics/epic-002-content-pages-ui-library.md`
