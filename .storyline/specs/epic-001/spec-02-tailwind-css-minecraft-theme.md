---
spec_id: 02
story_id: 02
epic_id: 001
title: Tailwind CSS v4 Configuration with Minecraft Theme
status: ready_for_implementation
created: 2026-01-10
---

# Technical Spec 02: Tailwind CSS v4 Configuration with Minecraft Theme

## Overview

**User story:** .storyline/stories/epic-001/story-02-tailwind-css-minecraft-theme.md

**Goal:** Configure Tailwind CSS v4 with the new Vite plugin and custom Minecraft-themed color palette, enabling utility-first CSS development with brand colors.

**Approach:** Install Tailwind v4 and @tailwindcss/vite plugin, create tailwind.config.js with custom Minecraft colors and dark mode configuration, create src/styles/index.css with v4 import syntax, and update vite.config.ts to include the plugin.

## Technical Design

### Architecture Decision

**Chosen approach:** Tailwind CSS v4 with @tailwindcss/vite plugin + class-based dark mode

**Alternatives considered:**
- **Tailwind v3 with PostCSS** - Outdated, missing v4 performance improvements and new features
- **Custom CSS with CSS modules** - Too time-consuming, no utility-first benefits
- **Styled-components or Emotion** - Runtime CSS-in-JS has performance costs, doesn't match team preference

**Rationale:** Tailwind v4 offers the best Vite integration via @tailwindcss/vite plugin, eliminating PostCSS configuration. Class-based dark mode (`<html class="dark">`) gives explicit control vs media query approach.

### System Components

**Frontend:**
- Tailwind CSS v4.0 core engine
- @tailwindcss/vite plugin for seamless Vite integration
- Custom Minecraft color palette extending default theme
- Class-based dark mode configuration

**Backend:**
- Not applicable

**Database:**
- Not applicable

**External integrations:**
- None

## Implementation Details

### Files to Create

```
/home/aaronprill/projects/blockhaven/web/tailwind.config.js
- Purpose: Tailwind CSS configuration with custom Minecraft theme
- Exports: Default export with theme extensions and dark mode config
- Note: MUST be .js not .ts for Tailwind v4
```

```
/home/aaronprill/projects/blockhaven/web/src/styles/index.css
- Purpose: Global stylesheet with Tailwind v4 imports
- Contents: @import "tailwindcss"; (v4 syntax)
- Replaces: Vite template's index.css
```

```
/home/aaronprill/projects/blockhaven/web/postcss.config.js
- Purpose: PostCSS configuration (may be needed for autoprefixer)
- Contents: Export with autoprefixer plugin
```

### Files to Modify

```
/home/aaronprill/projects/blockhaven/web/vite.config.ts
- Changes: Add tailwindcss() plugin from '@tailwindcss/vite'
- Location: plugins array in defineConfig
- Reason: Enable Tailwind v4 Vite plugin for fast processing
```

```
/home/aaronprill/projects/blockhaven/web/src/main.tsx
- Changes: Import './styles/index.css' instead of './index.css'
- Location: Top of file after React imports
- Reason: Load Tailwind styles globally
```

```
/home/aaronprill/projects/blockhaven/web/src/App.tsx (optional cleanup)
- Changes: Remove import of App.css, use Tailwind classes
- Location: Import statement and className attributes
- Reason: Demonstrate Tailwind usage, remove template CSS
```

### Detailed File Contents

#### tailwind.config.js
```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class', // Enable class-based dark mode
  theme: {
    extend: {
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
        primary: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',  // Main green CTA color
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
          950: '#052e16',
        },
        secondary: {
          50: '#fef2f2',
          100: '#fee2e2',
          200: '#fecaca',
          300: '#fca5a5',
          400: '#f87171',
          500: '#ef4444',  // Main red warning color
          600: '#dc2626',
          700: '#b91c1c',
          800: '#991b1b',
          900: '#7f1d1d',
          950: '#450a0a',
        },
      },
    },
  },
  plugins: [],
}
```

#### src/styles/index.css
```css
/* Tailwind CSS v4 import */
@import "tailwindcss";

/* Custom global styles (optional) */
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Smooth transitions for dark mode */
* {
  transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
}
```

#### vite.config.ts
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),  // Add Tailwind v4 Vite plugin
  ],
})
```

#### src/main.tsx (update import)
```typescript
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles/index.css'  // Changed from './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

#### src/App.tsx (demo with Tailwind classes)
```typescript
import { useState } from 'react'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-4xl font-bold text-minecraft-grass mb-4">
          BlockHaven
        </h1>
        <p className="text-lg mb-8">
          Vite + React 19 + Tailwind CSS v4
        </p>

        <div className="space-x-4">
          <button
            onClick={() => setCount((count) => count + 1)}
            className="bg-primary-500 hover:bg-primary-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors"
          >
            Count is {count}
          </button>

          <button className="bg-minecraft-diamond hover:bg-minecraft-emerald text-white font-semibold py-2 px-4 rounded-lg transition-colors">
            Minecraft Colors Work!
          </button>
        </div>
      </div>
    </div>
  )
}

export default App
```

### Commands to Execute

**Step 1: Verify dependencies (already installed in Spec 01)**
```bash
# These should already be installed, but verify:
pnpm list @tailwindcss/vite tailwindcss
```

**Step 2: Create Tailwind config**
```bash
cd /home/aaronprill/projects/blockhaven/web
# Create tailwind.config.js with content above
```

**Step 3: Create styles directory and index.css**
```bash
mkdir -p src/styles
# Create src/styles/index.css with content above
```

**Step 4: Update vite.config.ts**
```bash
# Modify vite.config.ts to add tailwindcss() plugin
```

**Step 5: Update main.tsx**
```bash
# Change import from './index.css' to './styles/index.css'
```

**Step 6: Update App.tsx (demo)**
```bash
# Replace with Tailwind classes to demonstrate functionality
```

**Step 7: Clean up old CSS files**
```bash
rm -f src/index.css src/App.css
```

**Step 8: Test development server**
```bash
pnpm dev
# Open http://localhost:5173 and verify Tailwind styles apply
```

**Step 9: Test production build**
```bash
pnpm build
# Verify CSS is optimized and minified in dist/
```

## Acceptance Criteria Mapping

### Story Criterion 1: Tailwind v4 installed and configured
**From story:** "Tailwind CSS v4 is added to dependencies and vite.config.ts includes tailwindcss() plugin"

**Verification:**
- Manual check: Run `pnpm list tailwindcss` and verify v4.x.x
- Manual check: Run `pnpm list @tailwindcss/vite` and verify latest
- Manual check: Open vite.config.ts and confirm `tailwindcss()` in plugins array

### Story Criterion 2: Tailwind CSS file created
**From story:** "src/styles/index.css contains @import 'tailwindcss' and is imported in main.tsx"

**Verification:**
- Manual check: Open src/styles/index.css and confirm `@import "tailwindcss";`
- Manual check: Open src/main.tsx and confirm import './styles/index.css'
- Manual check: Run `pnpm dev` and verify no import errors

### Story Criterion 3: Tailwind config with Minecraft colors
**From story:** "tailwind.config.js exports custom Minecraft colors"

**Verification:**
- Manual check: Open tailwind.config.js and verify all Minecraft colors defined
- Manual check: In browser DevTools, inspect element and verify custom colors available
- Test: Add `className="bg-minecraft-grass"` to component and verify green background (#7CBD2F)

### Story Criterion 4: Dark mode configured
**From story:** "darkMode is set to 'class'"

**Verification:**
- Manual check: Open tailwind.config.js and confirm `darkMode: 'class'`
- Test: Add class="dark" to <html> element and verify dark: variants apply
- Test: Use `className="bg-white dark:bg-gray-900"` and verify color changes with dark class

### Story Criterion 5: Tailwind utilities work in components
**From story:** "Tailwind classes apply correctly and IntelliSense works"

**Verification:**
- Manual check: Add Minecraft color classes to App.tsx and verify visual appearance
- Manual check: Type `className="bg-minecraft-` in VSCode and confirm autocomplete suggestions
- Manual check: Verify dark mode classes work (add dark class to html, see color changes)

### Story Criterion 6: Production build optimized
**From story:** "pnpm build generates minified CSS with only used utilities"

**Verification:**
- Manual check: Run `pnpm build` successfully
- Manual check: Check dist/assets/*.css file size (should be <50KB for minimal usage)
- Manual check: Open dist/assets/*.css and verify minified (no whitespace, single line)
- Manual check: Verify only used utilities included (search for unused color like minecraft-emerald if not used)

## Testing Requirements

### Unit Tests

Not applicable (CSS configuration, no logic to unit test)

### Integration Tests

Not applicable for this story

### Manual Testing Checklist

- [ ] Install dependencies verified (tailwindcss v4, @tailwindcss/vite)
- [ ] tailwind.config.js created with all Minecraft colors
- [ ] src/styles/index.css created with `@import "tailwindcss"`
- [ ] vite.config.ts updated with tailwindcss() plugin
- [ ] src/main.tsx imports './styles/index.css'
- [ ] Run `pnpm dev` without errors
- [ ] Open http://localhost:5173 and see styled page
- [ ] Inspect element in DevTools and verify Tailwind classes applied
- [ ] Test Minecraft colors: add `className="bg-minecraft-diamond text-white p-4"` and see blue background
- [ ] Test dark mode: manually add `class="dark"` to <html> and verify dark: classes apply
- [ ] Test IntelliSense: type className=" and verify autocomplete shows minecraft colors
- [ ] Run `pnpm build` successfully
- [ ] Check dist/assets/ CSS file is minified and < 50KB
- [ ] Run `pnpm preview` and verify production build looks correct

### Browser Testing

- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari (if on Mac)

## Dependencies

**Must complete first:**
- Spec 01: Vite + React Project Initialization (project must exist, dependencies installed)

**Enables:**
- Spec 03: Theme Context & Dark Mode (uses darkMode: 'class' configuration)
- Spec 004: Header Component (uses Tailwind classes)
- Spec 005: Footer Component (uses Tailwind classes)
- Spec 006: Mobile Navigation (uses Tailwind responsive utilities)
- All future components (styling system)

## Risks & Mitigations

**Risk 1:** Tailwind v4 syntax different from v3 could cause confusion
**Mitigation:** Document v4-specific requirements (@ import syntax, .js config, @tailwindcss/vite plugin)
**Fallback:** Downgrade to Tailwind v3 if v4 has critical bugs (unlikely)

**Risk 2:** IntelliSense may not recognize custom Minecraft colors
**Mitigation:** VSCode Tailwind IntelliSense extension should auto-detect config, but may need workspace restart
**Fallback:** Use inline documentation or refer to config file

**Risk 3:** Dark mode class strategy may conflict with third-party components
**Mitigation:** Most React libraries respect parent dark class, document any exceptions
**Fallback:** Use selector strategy instead of class if needed

**Risk 4:** Production build CSS may be larger than expected
**Mitigation:** Tailwind automatically purges unused CSS, but verify content paths in config are correct
**Fallback:** Manual CSS purging or optimization if needed

## Performance Considerations

**Expected load:** All pages (global stylesheet)
**Optimization strategy:**
- Tailwind JIT (Just-In-Time) mode automatically enabled in v4
- Unused utilities automatically removed in production build
- CSS minified and compressed

**Benchmarks:**
- Base CSS size (minimal usage): < 20KB gzipped
- Full site CSS (with all components): < 50KB gzipped
- Build time increase: < 2 seconds

## Security Considerations

**Authentication:** Not applicable
**Authorization:** Not applicable
**Data validation:** Not applicable
**Sensitive data:** None (CSS configuration only)

## Success Verification

After implementation, verify:
- [ ] `pnpm dev` starts without Tailwind-related errors
- [ ] Browser displays styled page with Tailwind classes applied
- [ ] Minecraft colors visible: test bg-minecraft-grass shows green #7CBD2F
- [ ] Dark mode configuration works: adding dark class to <html> changes colors
- [ ] IntelliSense autocomplete shows minecraft colors when typing className
- [ ] `pnpm build` succeeds and generates optimized CSS
- [ ] Production CSS file < 50KB for base usage
- [ ] No console warnings about Tailwind configuration
- [ ] All Tailwind utilities work (spacing, colors, typography, etc.)

## Traceability

**Parent story:** .storyline/stories/epic-001/story-02-tailwind-css-minecraft-theme.md
**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

## Implementation Notes

**Working directory:** `/home/aaronprill/projects/blockhaven/web/`

**Tailwind v4 breaking changes from v3:**
- CSS import: Use `@import "tailwindcss"` NOT `@tailwind base;` directives
- Config file: Must be `tailwind.config.js` (.js extension required, not .ts)
- Plugin: Use `@tailwindcss/vite` instead of PostCSS plugin
- No need for postcss.config.js (Vite plugin handles it)

**Color palette notes:**
- Minecraft colors sourced from official Minecraft textures
- Primary (green) for CTAs and success states
- Secondary (red) for errors and warnings
- Consider adding more Minecraft-inspired colors later (oak wood, cobblestone, etc.)

**Open questions:**
- Should we add custom fonts (Minecraft-style font)? (Decision: Defer to later story if needed)
- Do we need custom spacing or typography scales? (Decision: Use Tailwind defaults for now)

**Assumptions:**
- Developers have Tailwind CSS IntelliSense VSCode extension installed
- Modern browsers with CSS Grid and Flexbox support
- No IE11 support required

**Time estimate:** 1-2 hours

---

**Next step:** Run `/dev-story .storyline/specs/epic-001/spec-002-tailwind-css-minecraft-theme.md`
