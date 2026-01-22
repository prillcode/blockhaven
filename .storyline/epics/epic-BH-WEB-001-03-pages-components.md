# Epic 3: Core Pages & Components

**Epic ID:** BH-WEB-001-03
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-PRD.md

---

## Business Goal

Build the complete user-facing website with all 6 pages, reusable components, and responsive design that provides invited players and parents with comprehensive server information in a family-friendly, mobile-optimized interface inspired by the Storyline site design.

## User Value

**Who Benefits:** Prospective players, parents, server administrators

**How They Benefit:**
- Visitors can browse all server information without SSH or game access
- Parents can verify family-friendliness before allowing children to play
- Mobile-first design works on any device (phones, tablets, desktops)
- Clear navigation and consistent layout make information easy to find
- Professional, Minecraft-themed design builds trust and excitement

## Success Criteria

- [ ] All 6 pages implemented and navigable (Home, Worlds, Rules, Plugins, Connect, Request)
- [ ] Base layout with header and footer works across all pages
- [ ] Site is fully responsive on mobile (320px), tablet (768px), and desktop (1920px)
- [ ] Content from Epic 2 displays correctly in components
- [ ] Navigation works on all screen sizes (hamburger menu on mobile)
- [ ] Server Status widget displays real-time data from mcstatus.io API
- [ ] Design matches Minecraft theme with consistent colors and typography
- [ ] All pages pass basic accessibility checks (ARIA labels, keyboard navigation)

## Scope

### In Scope
- **Layout Components:**
  - `BaseLayout.astro` (wrapper for all pages)
  - `Header.astro` (logo, navigation, mobile hamburger menu)
  - `Footer.astro` (server IP, quick links, copyright)

- **UI Components:**
  - `WorldCard.astro` (world display with difficulty badge)
  - `FeatureCard.astro` (server feature display with icons)
  - `ServerStatus.astro` (real-time status widget with mcstatus.io)
  - `Button.astro` (reusable button component)
  - `Badge.astro` (difficulty badges: Easy/Normal/Hard)

- **Pages:**
  - `/` (index.astro) - Home page with hero, features, world preview, CTA
  - `/worlds` - All 6 worlds with detailed descriptions
  - `/rules` - Server rules with family-friendly policy
  - `/plugins` - Plugin descriptions and player commands
  - `/connect` - Connection instructions for Java and Bedrock
  - `/request` - Request access form (form component only, API in Epic 4)

- **Responsive Design:**
  - Mobile-first CSS approach
  - Breakpoints: 320px, 768px, 1024px, 1920px
  - Touch-friendly buttons (min 44px tap targets)
  - Hamburger menu for mobile navigation

- **Server Status Widget:**
  - Client-side fetch to mcstatus.io API
  - Display online/offline status, player count
  - Copy IP button
  - 30-second cache
  - Error handling for offline server

### Out of Scope
- Form submission logic (Epic 4 - API integration)
- Email delivery (Epic 4)
- Deployment configuration (Epic 5)
- Performance optimization (Epic 5)
- Analytics integration (Epic 5)

## Technical Notes

**Design Reference:**
- Base structure on Storyline site (https://storyline.apcode.dev)
- Adapt layout patterns to Minecraft theme
- Use Tailwind's responsive utilities

**Minecraft Theme (from Epic 1):**
- Primary: Grass Green (#7CBD2F), Emerald (#50C878)
- Secondary: Stone Gray (#7F7F7F), Dark Gray (#1A1A1A)
- Accent: Diamond Blue (#5DCCE3), Gold (#FCEE4B)

**Server Status API:**
```typescript
// Client-side fetch
const response = await fetch('https://api.mcstatus.io/v2/status/java/play.bhsmp.com');
const data = await response.json();
// Returns: { online, players { online, max }, version, ... }
```

**Responsive Breakpoints:**
```css
/* Tailwind defaults work well */
sm: 640px   /* Tablet portrait */
md: 768px   /* Tablet landscape */
lg: 1024px  /* Desktop */
xl: 1280px  /* Large desktop */
```

## Dependencies

**Depends On:**
- Epic 1: Site Foundation & Infrastructure (Tailwind, Astro project)
- Epic 2: Content System & Data Layer (world data, plugin data, rules)

**Blocks:**
- Epic 4: Request Form & API Integration (needs request page structure)
- Epic 5: Deployment & Production (needs pages to deploy)

## Risks & Mitigations

**Risk:** Mobile responsiveness issues on small screens
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Mobile-first development, test on real devices, use Tailwind responsive classes

**Risk:** mcstatus.io API rate limits or downtime
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Client-side caching, fallback to "Status Unknown", handle CORS properly

**Risk:** Design doesn't match Storyline reference site
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Review Storyline site structure, focus on clean layout over pixel-perfect match

## Acceptance Criteria

### Layout Components
- [ ] BaseLayout provides consistent wrapper with HTML structure
- [ ] Header includes logo/site name "BlockHaven"
- [ ] Header has navigation links: Home, Worlds, Rules, Plugins, Connect, Request Access
- [ ] Header has hamburger menu on mobile (< 768px)
- [ ] Footer displays server IP with copy button
- [ ] Footer has quick links to all pages
- [ ] Footer includes "Built with Astro" badge and copyright

### UI Components
- [ ] WorldCard displays world name, alias, difficulty badge, description, features
- [ ] FeatureCard displays icon, title, description
- [ ] ServerStatus fetches from mcstatus.io and displays status/player count
- [ ] ServerStatus copy IP button works
- [ ] Badge component supports Easy (green), Normal (yellow), Hard (red) variants
- [ ] Button component supports primary, secondary, accent variants

### Pages - Home (/)
- [ ] Hero section with server name, tagline, main CTA
- [ ] Features grid with 4-6 key features (from README)
- [ ] World preview showing 3 main worlds (Easy, Normal, Hard)
- [ ] "Request Access" CTA button linking to /request
- [ ] ServerStatus widget visible in hero or sidebar

### Pages - Worlds (/worlds)
- [ ] All 6 worlds displayed with WorldCard components
- [ ] Worlds grouped by type (Survival, Creative, Spawn)
- [ ] Each world shows: name, alias, difficulty, description, features, nether/end status
- [ ] Responsive grid layout (1 col mobile, 2 cols tablet, 3 cols desktop)

### Pages - Rules (/rules)
- [ ] Family-friendly policy statement at top
- [ ] All 10 rules displayed clearly
- [ ] Rules numbered and formatted consistently
- [ ] Brief explanation of land claims and economy rules

### Pages - Plugins (/plugins)
- [ ] Plugins grouped by category (from PLUGINS.md)
- [ ] Each plugin shows name, purpose, key features
- [ ] Player commands section (from PLUGINS-QUICK-REF.md)
- [ ] Commands formatted in code blocks with descriptions

### Pages - Connect (/connect)
- [ ] Java Edition connection instructions with server IP
- [ ] Bedrock Edition connection instructions with IP and port
- [ ] Troubleshooting section (common issues)
- [ ] Copy IP buttons for both Java and Bedrock
- [ ] Visual step-by-step guide

### Pages - Request (/request)
- [ ] Form fields: Name, Minecraft Username, Email, Age (optional), Relationship (optional), Message (optional)
- [ ] Form layout is clean and mobile-friendly
- [ ] Note: Form submission logic handled in Epic 4

### Responsive Design
- [ ] All pages work on iPhone SE (375px)
- [ ] All pages work on iPad (768px)
- [ ] All pages work on desktop (1920px)
- [ ] No horizontal scrolling on any screen size
- [ ] Touch targets minimum 44px on mobile
- [ ] Text readable on all screen sizes (min 16px base)
- [ ] Images scale properly without overflow

### Navigation
- [ ] Header navigation works on all pages
- [ ] Hamburger menu appears on mobile (< 768px)
- [ ] Mobile menu opens/closes correctly
- [ ] Footer links work on all pages
- [ ] Active page highlighted in navigation (optional)

### Accessibility
- [ ] All interactive elements keyboard-accessible
- [ ] Form inputs have proper labels
- [ ] Images have alt text
- [ ] Semantic HTML (header, nav, main, footer, article, section)
- [ ] Color contrast meets WCAG AA standards

### Server Status Widget
- [ ] Displays "Online" or "Offline" with colored indicator
- [ ] Shows player count when online ("X/100 players")
- [ ] Copy IP button copies to clipboard
- [ ] Handles offline server gracefully ("Status Unknown" fallback)
- [ ] Client-side cache prevents excessive API calls (30s)
- [ ] No CORS errors

## Related User Stories

From PRD:
- User Story 1: "As a visitor, I want to see what BlockHaven offers" → Home page
- User Story 2: "As a parent, I want to verify this is family-friendly" → Rules page
- User Story 5: "As a visitor, I want to see how to connect" → Connect page
- User Story 6: "As a visitor, I want to learn about the 6 different worlds" → Worlds page
- User Story 7: "As a visitor, I want to understand the server rules" → Rules page
- User Story 9: "As a visitor, I want to see the server status" → ServerStatus widget
- User Story 10: "As a visitor, I want to read about the plugins" → Plugins page
- User Story 11: "As a mobile user, I want the site to work perfectly on my phone" → Responsive design

## Component Specifications (from PRD)

### Header
- Logo/Site name: "BlockHaven"
- Navigation links: Home, Worlds, Rules, Plugins, Connect, Request Access
- Mobile: Hamburger menu
- Sticky header (optional)

### Footer
- Server IP with copy button
- Quick links (all pages)
- "Built with Astro" badge
- Copyright: © 2026 BlockHaven

### WorldCard
- World name
- Difficulty badge
- 2-3 sentence description
- Key features (bullet list)
- "Learn More" button → /worlds page

### FeatureCard
- Icon (Lucide icons or similar)
- Feature title
- 2-3 sentence description

## Notes

- Use Lucide icons for features and UI elements (https://lucide.dev)
- Tailwind's prose plugin may be useful for markdown content rendering
- Consider using Astro's View Transitions API for smooth page transitions (optional)
- Client-side JavaScript should be minimal (only for ServerStatus and mobile menu)

---

**Previous Epic:** Epic 2 - Content System & Data Layer
**Next Epic:** Epic 4 - Request Form & API Integration
