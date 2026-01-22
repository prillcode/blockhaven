---
story_id: 03
epic_id: 001
title: Theme Context & Dark Mode Implementation
status: ready_for_spec
created: 2026-01-10
---

# Story 03: Theme Context & Dark Mode Implementation

## User Story

**As a** BlockHaven website visitor,
**I want** to toggle between dark and light modes and have my preference remembered,
**so that** I can view the website in my preferred color scheme without having to change it every visit.

## Acceptance Criteria

### Scenario 1: ThemeContext provides theme state
**Given** the app is initialized
**When** a component accesses ThemeContext
**Then** the context provides `theme` ('light' | 'dark')
**And** the context provides `toggleTheme()` function
**And** the context is accessible to any component in the tree

### Scenario 2: System preference detected on first visit
**Given** a user visits the site for the first time (no localStorage)
**When** the app loads
**Then** the theme matches their system preference (prefers-color-scheme)
**And** if system prefers dark, theme is set to 'dark'
**And** if system prefers light, theme is set to 'light'

### Scenario 3: Theme persists to localStorage
**Given** a user toggles theme to 'dark'
**When** the theme changes
**Then** localStorage is updated with key 'blockhaven-theme' = 'dark'
**And** the HTML element gets class 'dark' added

### Scenario 4: Theme loads from localStorage on return visit
**Given** localStorage has 'blockhaven-theme' = 'dark'
**When** the user returns to the site
**Then** the theme loads as 'dark' from localStorage
**And** system preference is ignored (localStorage takes precedence)
**And** the HTML element has class 'dark' applied

### Scenario 5: ThemeToggle widget works
**Given** a ThemeToggle button exists in the header
**When** the user clicks the toggle button
**Then** the theme switches from light to dark (or vice versa)
**And** the icon changes from Sun to Moon (or vice versa)
**And** there is a smooth transition animation (no flash)

### Scenario 6: Dark mode styles apply correctly
**Given** theme is set to 'dark'
**When** components use dark: variants (e.g., `dark:bg-gray-900`)
**Then** dark mode styles are applied throughout the site
**And** background, text, and accent colors switch appropriately
**And** contrast remains accessible (WCAG AA compliant)

## Business Value

**Why this matters:** Dark mode is a standard expectation for modern websites. Users spend significant time on websites and prefer their chosen theme. Minecraft players often play in low-light environments where dark mode reduces eye strain.

**Impact:** Improved user experience leads to longer visit duration and better accessibility. Respecting user preferences shows attention to detail and professionalism.

**Success metric:** 30%+ of users will use dark mode. Theme preference persists across 100% of return visits.

## Technical Considerations

**Potential approaches:**
- Context API + localStorage + class-based dark mode (recommended, simple and effective)
- Third-party library like next-themes (overkill for this use case)
- CSS variables + media query only (loses persistence)

**Constraints:**
- Must use class-based dark mode (`<html class="dark">`) for Tailwind compatibility
- Must persist to localStorage with key 'blockhaven-theme'
- Must detect system preference on first visit
- Must apply theme synchronously to prevent flash of wrong theme (FOUC)

**Data requirements:**
- ThemeContext: createContext with theme state and toggleTheme function
- useTheme hook: custom hook to access theme context
- ThemeProvider: wrapper component that provides context
- localStorage: read/write theme preference

**Implementation pattern:**
```tsx
// src/contexts/ThemeContext.tsx
type Theme = 'light' | 'dark';
interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
}

// Apply theme to HTML on load (before React hydrates)
// Check localStorage first, then system preference
```

## Dependencies

**Depends on stories:**
- Story 01: Vite + React Project Initialization (needs React and project structure)
- Story 02: Tailwind CSS Configuration (needs dark mode config and dark: variants)

**Enables stories:**
- Story 04: Header Component (will include ThemeToggle widget)
- All future components (can use theme context and dark mode styles)

## Out of Scope

- Theme customization beyond dark/light (no color picker)
- Multiple theme variants (e.g., high contrast, sepia)
- Per-page theme overrides
- Animation preferences or motion reduction (future enhancement)

## Notes

- Avoid flash of unstyled content (FOUC) by applying theme class to HTML before React renders
- Use lucide-react icons: Sun (light mode), Moon (dark mode)
- Consider adding smooth transition with Tailwind's transition utilities
- Test system preference detection in Chrome DevTools (Rendering > prefers-color-scheme)

## Traceability

**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

**Related stories:** Story 02 (Tailwind dark mode), Story 04 (Header with toggle)

---

**Next step:** Run `/spec-story .storyline/stories/epic-001/story-003-theme-context-dark-mode.md`
