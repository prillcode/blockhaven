---
story_id: 008
epic_id: 004
title: Performance Optimization & Code Splitting
status: ready_for_spec
created: 2026-01-12
---

# Story 008: Performance Optimization & Code Splitting

## User Story

**As a** website visitor,
**I want** the website to load quickly and perform smoothly,
**so that** I have a fast, responsive experience and don't wait for unnecessary code to download.

## Acceptance Criteria

### Scenario 1: Lazy load Contact page
**Given** I first visit the homepage
**When** the page loads
**Then** the Contact page code is NOT included in the initial bundle
**And** the Contact page only loads when I navigate to `/contact`
**And** I see a loading indicator during the lazy load
**And** the page transition is smooth (no flash of unstyled content)

### Scenario 2: Code splitting reduces initial bundle size
**Given** the app is built for production
**When** I analyze the bundle size
**Then** the initial bundle (homepage) is less than 150KB gzipped
**And** the Contact page is in a separate chunk
**And** common dependencies (React, Tailwind) are in a shared vendor chunk
**And** each route has its own code-split chunk

### Scenario 3: Images are optimized
**Given** the homepage includes images (hero background, logos, etc.)
**When** the page loads
**Then** images are lazy loaded (not loaded until visible)
**And** images use modern formats (WebP with fallback)
**And** images are properly sized for their display dimensions (no oversized images)
**And** images have proper width/height attributes (prevent layout shift)

### Scenario 4: React components are memoized
**Given** the ServerStatus widget re-fetches data every 30 seconds
**When** the server status updates
**Then** only the ServerStatus widget re-renders
**And** parent components (Layout, Home page) do NOT re-render unnecessarily
**And** other widgets on the page do NOT re-render
**And** performance profiler shows minimal re-render overhead

## Business Value

**Why this matters:** Website performance directly impacts user engagement and SEO. Fast sites have lower bounce rates, better conversion, and higher Google rankings.

**Impact:** Reduces initial load time by 40-60% through code splitting. Improves Core Web Vitals (LCP, FID, CLS) which affect SEO rankings. Better mobile experience for users on slow connections.

**Success metric:** Lighthouse performance score ≥90, initial bundle <150KB gzipped, homepage loads in <2 seconds on 3G.

## Technical Considerations

**Potential approaches:**
- Use React.lazy() and Suspense for route-based code splitting
- Use dynamic imports (`import()`) for Contact page and other non-critical routes
- Use React.memo() for widgets that receive frequent prop updates (ServerStatus)
- Use useMemo/useCallback for expensive computations and callback props
- Implement image lazy loading with native `loading="lazy"` attribute
- Use Vite's automatic code splitting for optimal chunk sizes

**Constraints:**
- Must not break user experience (no jarring loading states)
- Must maintain SEO (ensure critical content is in initial HTML)
- Must work with React Router (lazy loaded routes)
- Must support all modern browsers (no IE11 required)
- Target: Lighthouse performance score ≥90

**Data requirements:**
- Webpack/Vite bundle analyzer to measure bundle sizes
- Chrome DevTools Lighthouse for performance audit
- React Profiler for identifying unnecessary re-renders

## Dependencies

**Depends on stories:**
- All previous stories (01-07) - this optimizes their implementations

**Enables stories:**
- Epic 005 (Deployment) - production build must be optimized

## Out of Scope

- Advanced image optimization (CDN, image service like Cloudinary)
- Service worker caching (PWA features)
- Prefetching/preloading critical resources
- Server-side rendering (SSR) or static site generation (SSG)
- Advanced bundle optimization (tree shaking is handled by Vite automatically)
- Font optimization (if using custom fonts)

## Notes

- Vite provides automatic code splitting and tree shaking out of the box
- React.lazy() requires Suspense boundary with fallback UI
- Consider using `React.memo()` for ServerStatus, ContactForm, and CopyIPButton widgets
- Image optimization should use Vite's asset handling (automatic hashing, optimization)
- Monitor bundle size in CI/CD to prevent regression (future enhancement)
- Consider using `loading="lazy"` for images below the fold

## Traceability

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

**Related stories:** All stories 01-07 (optimizes their implementations)

---

**Next step:** Run `/spec-story .storyline/stories/epic-004/story-08-performance-code-splitting.md`
