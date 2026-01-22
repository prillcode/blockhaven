---
story_id: 05
epic_id: 001
title: Footer Component with Server Info
status: ready_for_spec
created: 2026-01-10
---

# Story 05: Footer Component with Server Info

## User Story

**As a** BlockHaven website visitor,
**I want** a footer with server IP, quick links, and essential information,
**so that** I can easily find the server IP and access important links from any page.

## Acceptance Criteria

### Scenario 1: Footer renders on all pages
**Given** I am on any page of the website
**When** the page loads
**Then** the footer displays at the bottom of the page
**And** the footer has a dark background (darker than main content)
**And** the footer spans full width of viewport

### Scenario 2: Server IP prominently displayed
**Given** the footer is visible
**When** I look at the footer
**Then** I see the server IP "5.161.69.191:25565" prominently displayed
**And** the IP is styled larger than other footer text
**And** there is a "Copy IP" button next to the server IP

### Scenario 3: Quick links section works
**Given** the footer is displayed
**When** I view the quick links section
**Then** I see links to: Home, Worlds, Rules, Contact
**And** clicking any link navigates to the correct page
**And** links have hover effects

### Scenario 4: Copyright and credits displayed
**Given** the footer is visible
**When** I scroll to the bottom
**Then** I see "© 2026 BlockHaven" copyright notice
**And** I see "Built with Claude Code" badge or text
**And** copyright year updates automatically (uses current year)

### Scenario 5: Footer is responsive
**Given** I am viewing on mobile (< 768px width)
**When** the page loads
**Then** footer content stacks vertically
**And** server IP section is full-width and centered
**And** quick links stack or wrap appropriately
**And** all content remains readable and accessible

### Scenario 6: Dark mode styles apply
**Given** dark mode is enabled
**When** the footer renders
**Then** footer background darkens further (e.g., from gray-800 to gray-900)
**And** text color adjusts for proper contrast
**And** hover effects remain visible in dark mode

### Scenario 7: Footer has proper semantic HTML
**Given** the footer is rendered
**When** I inspect the HTML
**Then** footer uses `<footer>` semantic element
**And** navigation links use `<nav>` with proper ARIA label
**And** structure is logical and accessible

## Business Value

**Why this matters:** The footer provides persistent access to critical information (server IP) and helps with site navigation. It's a standard expectation for professional websites.

**Impact:** Users can always find the server IP without scrolling up. Footer links provide alternative navigation paths, improving discoverability.

**Success metric:** 15-20% of server IP copies happen from footer. Footer links account for 5-10% of navigation.

## Technical Considerations

**Potential approaches:**
- Semantic `<footer>` with CSS Grid layout (recommended, flexible and responsive)
- Flexbox with column wrapping (simpler, good for this use case)

**Constraints:**
- Must display server IP prominently: "5.161.69.191:25565"
- Must include copyright with dynamic year (not hardcoded)
- Must be responsive (mobile-first design)
- Should visually anchor the page (darker background)

**Data requirements:**
- Server IP: "5.161.69.191:25565" (constant or from config)
- Navigation links: same array as Header
- Current year: `new Date().getFullYear()`
- Social media links: Discord (if available), optional GitHub

**Component structure:**
```tsx
// src/components/layout/Footer.tsx
<footer className="bg-gray-800 dark:bg-gray-900 text-white py-12">
  <div className="container mx-auto grid md:grid-cols-3 gap-8">
    {/* Server IP Section */}
    <div>
      <h3>Join Our Server</h3>
      <p className="text-2xl font-bold">5.161.69.191:25565</p>
      <CopyIPButton />
    </div>

    {/* Quick Links */}
    <div>
      <h3>Quick Links</h3>
      <nav>
        <Link to="/">Home</Link>
        ...
      </nav>
    </div>

    {/* About/Credits */}
    <div>
      <p>© {new Date().getFullYear()} BlockHaven</p>
      <p>Built with Claude Code</p>
    </div>
  </div>
</footer>
```

## Dependencies

**Depends on stories:**
- Story 01: Vite + React Project Initialization (needs React)
- Story 02: Tailwind CSS Configuration (needs Tailwind classes)
- Story 03: Theme Context & Dark Mode (uses dark mode styles)

**Enables stories:**
- Epic 002 stories: Footer will appear on all pages
- Epic 004: CopyIPButton widget will be embedded in footer

**Parallel with:**
- Story 04: Header Component (both are layout components)

## Out of Scope

- CopyIPButton functionality (Epic 004 handles interactive widgets)
- Social media icons/links (add later if needed)
- Newsletter signup form (not in MVP)
- Sitemap or extensive link structure (simple flat navigation only)
- Language selector or region picker

## Notes

- CopyIPButton component placeholder is fine - full functionality in Epic 004
- Consider adding subtle top border to visually separate from content
- Footer should have min-height to prevent weird layouts on short pages
- Test on various screen sizes (320px mobile to 1920px desktop)
- "Built with Claude Code" link could point to https://claude.com/claude-code

## Traceability

**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

**Related stories:** Story 04 (Header), Epic 004 (CopyIPButton widget)

---

**Next step:** Run `/spec-story .storyline/stories/epic-001/story-005-footer-component.md`
