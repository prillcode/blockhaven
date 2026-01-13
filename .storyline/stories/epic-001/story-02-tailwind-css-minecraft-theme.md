---
story_id: 02
epic_id: 001
title: Tailwind CSS v4 Configuration with Minecraft Theme
status: ready_for_spec
created: 2026-01-10
---

# Story 02: Tailwind CSS v4 Configuration with Minecraft Theme

## User Story

**As a** BlockHaven website developer,
**I want** Tailwind CSS v4 configured with a custom Minecraft-themed color palette and the new Vite plugin,
**so that** I can style the website with utility classes that match BlockHaven's brand and Minecraft aesthetic.

## Acceptance Criteria

### Scenario 1: Tailwind v4 installed and configured
**Given** the Vite project is initialized
**When** I install `@tailwindcss/vite` and `tailwindcss@^4.0.0`
**Then** Tailwind CSS v4 is added to dependencies
**And** vite.config.ts includes `tailwindcss()` plugin from `@tailwindcss/vite`

### Scenario 2: Tailwind CSS file created
**Given** Tailwind is installed
**When** I create `src/styles/index.css`
**Then** the file contains `@import "tailwindcss";` (v4 syntax)
**And** the file is imported in main.tsx

### Scenario 3: Tailwind config with Minecraft colors
**Given** Tailwind is set up
**When** I create `tailwind.config.js` (must be .js not .ts for v4)
**Then** the config exports custom Minecraft-themed colors:
- minecraft.grass: #7CBD2F
- minecraft.dirt: #8C6239
- minecraft.stone: #7F7F7F
- minecraft.diamond: #5DCCE3
- minecraft.gold: #FCEE4B
- minecraft.redstone: #FF0000
- minecraft.emerald: #50C878
- minecraft.dark: #1A1A1A
**And** primary/secondary color scales are defined for green and red

### Scenario 4: Dark mode configured
**Given** Tailwind config exists
**When** I add dark mode configuration
**Then** darkMode is set to 'class' (class-based strategy)
**And** dark: variants work in CSS classes

### Scenario 5: Tailwind utilities work in components
**Given** Tailwind is fully configured
**When** I use Tailwind classes in a React component (e.g., `className="bg-minecraft-grass text-white p-4"`)
**Then** the styles are applied correctly
**And** IntelliSense shows autocomplete for Minecraft colors
**And** dark mode classes (e.g., `dark:bg-minecraft-stone`) work

### Scenario 6: Production build generates optimized CSS
**Given** Tailwind is configured
**When** I run `pnpm build`
**Then** only used Tailwind utilities are included in final CSS
**And** CSS is minified
**And** bundle size is reasonable (<50KB for base CSS)

## Business Value

**Why this matters:** Tailwind CSS enables rapid UI development with consistent design. The Minecraft theme creates immediate brand recognition and immersion for visitors.

**Impact:** Developers can build UI components 3-5x faster using utility classes instead of writing custom CSS. Minecraft colors ensure brand consistency across all pages.

**Success metric:** Any developer can apply Minecraft-themed styles using intuitive class names like `bg-minecraft-diamond` or `text-minecraft-gold`.

## Technical Considerations

**Potential approaches:**
- Tailwind v4 with new `@tailwindcss/vite` plugin (recommended, best Vite integration)
- Tailwind v3 with PostCSS (outdated approach for v4)

**Constraints:**
- MUST use Tailwind CSS v4 (not v3) per plan
- MUST use `@import "tailwindcss"` not `@tailwind base/components/utilities` (v4 breaking change)
- Config file MUST be `tailwind.config.js` (.js not .ts) for v4
- MUST configure class-based dark mode for `<html class="dark">` strategy

**Data requirements:**
- tailwind.config.js with theme.extend.colors for Minecraft palette
- src/styles/index.css with Tailwind imports
- vite.config.ts updated with tailwindcss() plugin

**Color palette reference:**
```javascript
colors: {
  minecraft: {
    grass: '#7CBD2F',
    dirt: '#8C6239',
    stone: '#7F7F7F',
    diamond: '#5DCCE3',
    gold: '#FCEE4B',
    redstone: '#FF0000',
    emerald: '#50C878',
    dark: '#1A1A1A',
  },
  primary: { /* green shades for CTAs */ },
  secondary: { /* red shades for warnings */ },
}
```

## Dependencies

**Depends on stories:**
- Story 01: Vite + React Project Initialization (needs base project)

**Enables stories:**
- Story 03: Theme Context & Dark Mode (uses dark mode configuration)
- Story 04-006: All layout components (use Tailwind classes for styling)

## Out of Scope

- Component styling (components don't exist yet)
- Theme toggle functionality (Story 03)
- Custom CSS beyond Tailwind utilities
- Typography or spacing customization (use Tailwind defaults)

## Notes

- Tailwind v4 has breaking changes from v3 - ensure correct syntax
- IntelliSense may need TypeScript types for custom colors - consider adding
- Consider adding custom fonts later (not in this story)
- Minecraft colors sourced from official Minecraft texture palette

## Traceability

**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

**Related stories:** Story 01 (project setup), Story 03 (dark mode implementation)

---

**Next step:** Run `/spec-story .storyline/stories/epic-001/story-002-tailwind-css-minecraft-theme.md`
