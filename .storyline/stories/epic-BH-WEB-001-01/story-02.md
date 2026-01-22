---
story_id: 02
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Configure Tailwind CSS with Minecraft Theme
status: ready_for_spec
parent_epic: ../../epics/epic-BH-WEB-001-01-site-foundation.md
created: 2026-01-22
---

# Story 02: Configure Tailwind CSS with Minecraft Theme

## User Story

**As a** developer,
**I want** Tailwind CSS configured with a custom Minecraft color palette and theme,
**so that** I can build components with consistent, on-brand styling that matches the BlockHaven Minecraft server aesthetic.

## Acceptance Criteria

### Scenario 1: Tailwind integration installed
**Given** the Astro project is initialized (Story 01 complete)
**When** I install Tailwind via Astro integration
**Then** `@astrojs/tailwind` and `tailwindcss` are in `package.json`
**And** Tailwind is added to `astro.config.mjs` integrations
**And** `tailwind.config.mjs` is created

### Scenario 2: Minecraft color palette configured
**Given** Tailwind is installed
**When** I configure the custom theme in `tailwind.config.mjs`
**Then** the config includes all Minecraft colors:
  - `primary.grass` (#7CBD2F)
  - `primary.emerald` (#50C878)
  - `secondary.stone` (#7F7F7F)
  - `secondary.darkGray` (#1A1A1A)
  - `accent.diamond` (#5DCCE3)
  - `accent.gold` (#FCEE4B)
  - `background.light` (#F5F5F5)
  - `background.dark` (#1A1A1A)
  - `text.dark` (#2D2D2D)
  - `text.light` (#E5E5E5)

### Scenario 3: Global CSS file created
**Given** Tailwind is configured
**When** I create `src/styles/global.css`
**Then** the file imports Tailwind directives:
  ```css
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
  ```
**And** I can add custom base styles if needed

### Scenario 4: Tailwind classes work in Astro components
**Given** Tailwind is fully configured
**When** I create a test Astro component with Minecraft theme classes
**Then** classes like `bg-primary-grass` and `text-accent-diamond` apply correctly
**And** dev server hot-reloads CSS changes
**And** Tailwind IntelliSense works in VSCode (if configured)

### Scenario 5: Responsive utilities available
**Given** Tailwind is configured
**When** I use responsive prefixes (`sm:`, `md:`, `lg:`, `xl:`)
**Then** responsive breakpoints work as expected
**And** mobile-first design is supported

## Business Value

**Why this matters:** A cohesive, Minecraft-themed design system ensures the website feels like an extension of the game server, reinforcing brand identity and creating a memorable user experience.

**Impact:** Developers can quickly build UI components with consistent styling. Players visiting the site will immediately recognize the Minecraft aesthetic, increasing trust and engagement.

**Success metric:** Developer can use Minecraft color classes in any component and see styled output in browser within 100ms of save (HMR).

## Technical Considerations

**Potential approaches:**
- Use Astro's official Tailwind integration (`@astrojs/tailwind`)
- Manual Tailwind setup with PostCSS
- Use Tailwind CDN (not recommended for production)

**Recommended approach:** Use `@astrojs/tailwind` integration for seamless Astro + Tailwind setup.

**Constraints:**
- Must extend default Tailwind theme (not replace it entirely)
- Must support responsive design (mobile, tablet, desktop)
- Color palette must match Minecraft's visual identity

**Data requirements:**
- Minecraft color hex codes (provided in epic)
- No external API calls needed

**Configuration specifics:**
```javascript
// tailwind.config.mjs
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        primary: {
          grass: '#7CBD2F',
          emerald: '#50C878',
        },
        secondary: {
          stone: '#7F7F7F',
          darkGray: '#1A1A1A',
        },
        accent: {
          diamond: '#5DCCE3',
          gold: '#FCEE4B',
        },
        background: {
          light: '#F5F5F5',
          dark: '#1A1A1A',
        },
        text: {
          dark: '#2D2D2D',
          light: '#E5E5E5',
        }
      }
    }
  },
  plugins: [],
}
```

## Dependencies

**Depends on stories:**
- Story 01: Initialize Astro Project - Must have working Astro project first

**Enables stories:**
- Story 04: Create directory structure - Styles directory setup
- Story 06: Create placeholder routes - Can use Tailwind classes
- Epic 3 stories: All page and component stories depend on Tailwind being configured

## Out of Scope

- Building actual components (Epic 3)
- Creating layout files (Epic 3)
- Adding Tailwind plugins (e.g., forms, typography) - can be added later if needed
- Custom Tailwind utilities beyond color palette
- Dark mode toggle implementation (Epic 3 or Phase 2)

## Notes

- Tailwind v3.4+ supports ESM config files (`tailwind.config.mjs`)
- The `content` array in Tailwind config must include all file types where Tailwind classes are used
- Consider adding `prettier-plugin-tailwindcss` for automatic class sorting (optional enhancement)
- Minecraft colors are carefully chosen to evoke the game's aesthetic without using exact textures (copyright)

## Traceability

**Parent epic:** [epic-BH-WEB-001-01-site-foundation.md](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Related stories:** Story 01 (Astro init), Story 04 (Directory structure), Epic 3 (All UI stories)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-02.md (this file)
      └─ specs/epic-BH-WEB-001-01/ (specs created here)
```

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BH-WEB-001-01/story-02.md`
