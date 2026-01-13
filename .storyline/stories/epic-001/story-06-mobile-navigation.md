---
story_id: 06
epic_id: 001
title: Mobile-Responsive Navigation with Hamburger Menu
status: ready_for_spec
created: 2026-01-10
---

# Story 06: Mobile-Responsive Navigation with Hamburger Menu

## User Story

**As a** BlockHaven website visitor on mobile,
**I want** a hamburger menu that reveals navigation links when tapped,
**so that** I can navigate the website easily on my phone without cluttered UI.

## Acceptance Criteria

### Scenario 1: Desktop navigation displays inline
**Given** I am viewing on desktop (≥768px width)
**When** the page loads
**Then** navigation links display horizontally in the header
**And** the hamburger menu icon is hidden
**And** links are visible without any menu interaction

### Scenario 2: Mobile shows hamburger icon
**Given** I am viewing on mobile (<768px width)
**When** the page loads
**Then** the hamburger menu icon (three lines) is displayed
**And** navigation links are hidden by default
**And** only logo, theme toggle, and hamburger are visible in header

### Scenario 3: Hamburger menu opens on mobile
**Given** I am on mobile and the menu is closed
**When** I tap the hamburger icon
**Then** the mobile menu slides in from the right (or expands from top)
**And** navigation links are displayed vertically
**And** the hamburger icon transforms to an "X" close icon
**And** a backdrop overlay appears behind the menu

### Scenario 4: Navigation links work in mobile menu
**Given** the mobile menu is open
**When** I tap "Worlds" link
**Then** I am navigated to /worlds page
**And** the mobile menu automatically closes
**And** the page transition is smooth

### Scenario 5: Close button closes menu
**Given** the mobile menu is open
**When** I tap the "X" close icon
**Then** the menu slides out/collapses
**And** the icon transforms back to hamburger
**And** the backdrop overlay fades out

### Scenario 6: Backdrop click closes menu
**Given** the mobile menu is open
**When** I tap the backdrop overlay (outside the menu)
**Then** the menu closes
**And** I return to the main page view

### Scenario 7: Menu has smooth animations
**Given** I open or close the mobile menu
**When** the menu animates
**Then** the animation is smooth (60fps)
**And** the animation duration is 200-300ms
**And** the backdrop fades in/out smoothly
**And** there is no janky or jumpy behavior

### Scenario 8: Body scroll locked when menu open
**Given** the mobile menu is open
**When** I try to scroll the page
**Then** the page content does not scroll (body scroll locked)
**And** only the menu itself scrolls if content overflows
**And** scroll is restored when menu closes

### Scenario 9: Active page highlighted in mobile menu
**Given** I am on the /rules page
**When** I open the mobile menu
**Then** the "Rules" link is highlighted/underlined
**And** other links are not highlighted
**And** the active state matches desktop navigation

## Business Value

**Why this matters:** Over 50% of website traffic comes from mobile devices. A clunky mobile navigation frustrates users and increases bounce rate.

**Impact:** Mobile users can easily navigate without pinch-zooming or tapping tiny links. Professional mobile UX builds trust and keeps users engaged.

**Success metric:** Mobile bounce rate <30%. Mobile users navigate 2+ pages per session. No usability complaints about navigation.

## Technical Considerations

**Potential approaches:**
- React state + CSS transitions (recommended, lightweight)
- Framer Motion for animations (overkill, adds bundle size)
- CSS-only with checkbox hack (no JS, but less control)

**Constraints:**
- Must be responsive: desktop (inline), mobile (hamburger)
- Must lock body scroll when menu is open
- Must close menu on navigation (route change)
- Must support keyboard navigation (Esc to close)
- Animations must be performant (transform, not position)

**Data requirements:**
- Navigation items: same array as Header
- Menu open state: boolean (useState)
- Current route: useLocation from React Router
- Breakpoint: 768px (Tailwind's md: breakpoint)

**Component structure:**
```tsx
// src/components/layout/Navigation.tsx
export function Navigation() {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();

  // Close menu on route change
  useEffect(() => {
    setIsOpen(false);
  }, [location]);

  return (
    <>
      {/* Desktop nav */}
      <nav className="hidden md:flex gap-6">
        <NavLink to="/">Home</NavLink>
        ...
      </nav>

      {/* Mobile hamburger */}
      <button
        className="md:hidden"
        onClick={() => setIsOpen(!isOpen)}
      >
        {isOpen ? <X /> : <Menu />}
      </button>

      {/* Mobile menu */}
      {isOpen && (
        <>
          <div className="backdrop" onClick={() => setIsOpen(false)} />
          <nav className="mobile-menu">
            <NavLink to="/" onClick={() => setIsOpen(false)}>Home</NavLink>
            ...
          </nav>
        </>
      )}
    </>
  );
}
```

**Icons:**
- Hamburger: `<Menu />` from lucide-react
- Close: `<X />` from lucide-react

## Dependencies

**Depends on stories:**
- Story 01: Vite + React Project Initialization (needs React state)
- Story 02: Tailwind CSS Configuration (needs responsive utilities)
- Story 04: Header Component (Navigation is used by Header)

**Enables stories:**
- All page navigation on mobile devices
- Complete Epic 001 (final story in foundation epic)

## Out of Scope

- Dropdown submenus or nested navigation (flat navigation only)
- Search bar in navigation (not in MVP)
- Multiple mobile navigation patterns (slide-in only, not bottom sheet)
- Gesture-based menu controls (swipe to close)

## Notes

- Use `lucide-react` icons: Menu (hamburger), X (close)
- Prevent body scroll with `overflow: hidden` on body when menu open
- Close menu on Escape key press (accessibility)
- Test on real mobile devices (not just browser DevTools)
- Menu should slide in from right with `transform: translateX()`
- Backdrop should have semi-transparent black overlay (e.g., `bg-black/50`)

## Traceability

**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

**Related stories:** Story 04 (Header component that uses Navigation)

---

**Next step:** Run `/spec-story .storyline/stories/epic-001/story-006-mobile-navigation.md`
