---
story_id: 04
epic_id: 001
title: Responsive Header Component with Navigation
status: ready_for_spec
created: 2026-01-10
---

# Story 04: Responsive Header Component with Navigation

## User Story

**As a** BlockHaven website visitor,
**I want** a sticky header with logo, navigation links, and theme toggle,
**so that** I can easily navigate the website and access key actions from any page.

## Acceptance Criteria

### Scenario 1: Header renders with all elements
**Given** I am on any page of the website
**When** the page loads
**Then** the header displays at the top of the page
**And** the header contains BlockHaven logo on the left
**And** the header contains navigation links in the center (Home, Worlds, Rules, Contact)
**And** the header contains theme toggle button on the right

### Scenario 2: Header is sticky on scroll
**Given** I am viewing a page with scrollable content
**When** I scroll down the page
**Then** the header remains fixed at the top of viewport
**And** the header has a subtle shadow or backdrop blur when scrolled
**And** content scrolls underneath the header

### Scenario 3: Logo links to homepage
**Given** the header is displayed
**When** I click the BlockHaven logo
**Then** I am navigated to the homepage (/)
**And** the page transition is smooth

### Scenario 4: Navigation links work
**Given** the header navigation is displayed
**When** I click "Worlds"
**Then** I am navigated to /worlds page
**And** the "Worlds" link is highlighted as active
**And** other navigation links remain unhighlighted

### Scenario 5: Active page indicator works
**Given** I am on the /rules page
**When** the header renders
**Then** the "Rules" navigation link is highlighted/underlined
**And** other navigation links are not highlighted
**And** the active state is visually distinct

### Scenario 6: Theme toggle button works
**Given** the current theme is 'light'
**When** I click the theme toggle button in header
**Then** the theme switches to 'dark'
**And** the toggle icon changes from Sun to Moon
**And** the transition is smooth without page flash

### Scenario 7: Header is responsive on mobile
**Given** I am viewing on mobile (< 768px width)
**When** the page loads
**Then** logo and hamburger menu icon are displayed
**And** desktop navigation links are hidden
**And** theme toggle remains visible next to hamburger icon

### Scenario 8: Header has proper accessibility
**Given** I am using keyboard navigation
**When** I tab through the header
**Then** logo, each nav link, and theme toggle are focusable in logical order
**And** active element has visible focus indicator
**And** all interactive elements have appropriate ARIA labels

## Business Value

**Why this matters:** The header is the primary navigation mechanism. A well-designed header enables users to explore the site effectively and builds trust through professional design.

**Impact:** Users can navigate to any page in 1-2 clicks. Sticky header keeps navigation accessible during reading, improving engagement and reducing bounce rate.

**Success metric:** 90%+ of multi-page sessions use header navigation. <2% of users get lost or use back button excessively.

## Technical Considerations

**Potential approaches:**
- Semantic HTML `<header>` with flexbox layout (recommended)
- Sticky positioning with `position: sticky` CSS
- React Router `NavLink` for active state detection

**Constraints:**
- Must be responsive (mobile, tablet, desktop)
- Must use semantic HTML (`<header>`, `<nav>`, `<a>`)
- Logo must be SVG or high-resolution PNG
- Must work with theme toggle from Story 03
- Hamburger menu logic deferred to Story 06 (Navigation component)

**Data requirements:**
- Logo image: public/server-icon.png or SVG
- Navigation items: array of {label, path} objects
- Current route from React Router useLocation hook

**Component structure:**
```tsx
// src/components/layout/Header.tsx
<header className="sticky top-0 z-50 bg-white dark:bg-gray-900">
  <div className="container mx-auto flex items-center justify-between">
    <Link to="/">
      <img src="/server-icon.png" alt="BlockHaven" />
    </Link>

    <Navigation /> {/* Desktop nav */}

    <div className="flex items-center gap-4">
      <ThemeToggle />
      <MobileMenuButton /> {/* Mobile only */}
    </div>
  </div>
</header>
```

## Dependencies

**Depends on stories:**
- Story 01: Vite + React Project Initialization (needs React and routing)
- Story 02: Tailwind CSS Configuration (needs Tailwind classes)
- Story 03: Theme Context & Dark Mode (uses ThemeToggle widget)

**Enables stories:**
- Story 05: Footer Component (completes base layout)
- Epic 002 stories: Header will appear on all pages

**Parallel with:**
- Story 06: Mobile Navigation (provides MobileMenu component used by Header)

## Out of Scope

- Mobile hamburger menu functionality (Story 06 handles this)
- Search functionality (not in MVP)
- User account dropdown (no authentication in MVP)
- Mega menu or dropdown submenus (simple flat navigation)
- Notification badge or indicators

## Notes

- Use React Router's NavLink for automatic active state styling
- Logo should be clickable with hover effect
- Consider adding subtle animation on scroll (backdrop blur or shadow)
- Test sticky behavior on iOS Safari (can have quirks)
- Ensure z-index is high enough to appear above content (z-50)
- Logo size: ~40px height on desktop, ~32px on mobile

## Traceability

**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

**Related stories:** Story 03 (ThemeToggle), Story 06 (Mobile navigation)

---

**Next step:** Run `/spec-story .storyline/stories/epic-001/story-004-header-component.md`
