---
phase_id: stories-01-05-combined-02
spec_source: .storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md
story_sources:
  - .storyline/stories/epic-BH-WEB-001-01/story-02.md
  - .storyline/stories/epic-BH-WEB-001-01/story-03.md
  - .storyline/stories/epic-BH-WEB-001-01/story-05.md
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
depends_on: 01-PLAN.md
---

<objective>
Configure Tailwind with Minecraft color palette, TypeScript strict mode, install additional dependencies, and create global CSS file
</objective>

<execution_context>
Essential reading before executing ANY tasks:

@.storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md - Technical spec (see Configuration Specifics sections)
@.storyline/stories/epic-BH-WEB-001-01/story-02.md - Story 02: Configure Tailwind CSS
@.storyline/stories/epic-BH-WEB-001-01/story-03.md - Story 03: Configure TypeScript
@.storyline/stories/epic-BH-WEB-001-01/story-05.md - Story 05: Configure Environment Variables

**Execution protocol:**
- Follow deviation rules (auto-fix bugs, ask for architectural decisions)
- Document all deviations in SUMMARY.md
- Link SUMMARY back to parent stories

**Depends on:**
- Plan 01 must be complete (Astro + Cloudflare + Tailwind installed)
- web/ directory exists with basic configuration
</execution_context>

<context>
Read existing configuration files:

@web/tailwind.config.mjs - Will be updated with Minecraft color palette
@web/tsconfig.json - Will be verified/updated for strict mode
@web/.gitignore - Will be updated with additional entries
</context>

<tasks>

<task type="auto">
<id>1</id>
<description>
Install additional dependencies: resend (email), wrangler (Cloudflare CLI), @types/node (TypeScript definitions)
</description>
<files>
web/package.json (will be modified)
</files>
<action>
Install the remaining required dependencies:

1. Navigate to web directory:
   cd /home/aaronprill/projects/blockhaven/web

2. Install resend for email functionality:
   npm install resend

3. Install dev dependencies for Cloudflare Workers and Node types:
   npm install -D wrangler @types/node

4. Verify installations:
   - Check package.json dependencies includes "resend"
   - Check package.json devDependencies includes "wrangler" and "@types/node"
</action>
<verify>
- [ ] web/package.json dependencies section includes "resend": "^3.0.0" (or compatible)
- [ ] web/package.json devDependencies includes "wrangler": "^3.0.0" (or compatible)
- [ ] web/package.json devDependencies includes "@types/node": "^20.0.0" (or compatible)
- [ ] npm install completed without errors
</verify>
<done>
All additional dependencies installed: resend for email API, wrangler for Cloudflare deployment, @types/node for TypeScript
</done>
</task>

<task type="auto">
<id>2</id>
<description>
Configure Tailwind CSS with Minecraft-themed color palette and proper content paths
</description>
<files>
web/tailwind.config.mjs (modify)
</files>
<action>
Update tailwind.config.mjs with the custom Minecraft color palette from the spec:

1. Read current tailwind.config.mjs to understand existing structure

2. Replace/update the configuration with Minecraft theme:

```javascript
/** @type {import('tailwindcss').Config} */
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

3. Verify the configuration includes:
   - Correct content paths for Astro files
   - All 10 Minecraft colors in theme.extend.colors
   - Empty plugins array
</action>
<verify>
- [ ] web/tailwind.config.mjs includes content path './src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'
- [ ] theme.extend.colors.primary has 'grass' and 'emerald'
- [ ] theme.extend.colors.secondary has 'stone' and 'darkGray'
- [ ] theme.extend.colors.accent has 'diamond' and 'gold'
- [ ] theme.extend.colors.background has 'light' and 'dark'
- [ ] theme.extend.colors.text has 'dark' and 'light'
</verify>
<done>
Tailwind configured with Minecraft color palette - 10 custom colors available as utility classes (bg-primary-grass, text-accent-diamond, etc.)
</done>
</task>

<task type="auto">
<id>3</id>
<description>
Verify TypeScript strict configuration and create global CSS file with Tailwind directives
</description>
<files>
web/tsconfig.json (read and verify, modify if needed)
web/src/styles/global.css (create)
web/.gitignore (modify)
</files>
<action>
1. Verify TypeScript configuration:
   - Read web/tsconfig.json
   - Ensure it extends "astro/tsconfigs/strict"
   - Verify compilerOptions includes necessary settings
   - If @types/node not in types array, add it

Expected tsconfig.json:
```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "jsx": "react-jsx",
    "moduleResolution": "bundler",
    "types": ["@types/node"]
  }
}
```

2. Create src/styles directory and global.css:
   - mkdir -p web/src/styles
   - Create web/src/styles/global.css with Tailwind directives:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

3. Update .gitignore with comprehensive entries:
   - Read existing .gitignore
   - Ensure it includes:
     * node_modules/
     * .env, .env.local, .env.production
     * dist/
     * .wrangler/
     * .DS_Store
   - Add any missing entries
</action>
<verify>
- [ ] web/tsconfig.json extends "astro/tsconfigs/strict"
- [ ] web/tsconfig.json compilerOptions.types includes "@types/node"
- [ ] web/src/styles/global.css exists
- [ ] global.css contains @tailwind base, components, and utilities directives
- [ ] web/.gitignore includes all required entries (node_modules, .env*, dist, .wrangler, .DS_Store)
</verify>
<done>
TypeScript strict mode verified, global CSS with Tailwind directives created, .gitignore updated with all necessary entries
</done>
</task>

</tasks>

<verification>
After completing all tasks:

1. **Tailwind colors test:**
   Create a test .astro file to verify Minecraft colors work:
   ```bash
   echo '<div class="bg-primary-grass text-accent-diamond">Test</div>' > web/src/pages/test.astro
   ```
   Start dev server and check if colors apply (optional manual check)

2. **TypeScript check:**
   ```bash
   cd web && npx astro check
   ```
   Should complete with 0 errors

3. **Dependencies verification:**
   ```bash
   cat web/package.json
   ```
   Should show resend, wrangler, @types/node installed

4. **File structure:**
   ```bash
   ls -la web/src/styles/
   ```
   Should show global.css exists
</verification>

<success_criteria>
From parent stories:

**Story 02 - Tailwind:**
- [x] Tailwind integration installed (from Plan 01)
- [x] Minecraft color palette configured (10 colors)
- [x] Global CSS created with Tailwind directives
- [x] Tailwind classes work (verified via test)

**Story 03 - TypeScript:**
- [x] TypeScript compiles without errors
- [x] tsconfig.json configured for Astro with strict mode
- [x] @types/node included for Node.js types

**Story 05 - Environment (Partial):**
- [x] Wrangler installed
- [x] .gitignore includes .env entries

**Remaining:** Directory structure and environment files (.env.example, wrangler.toml) in Plan 03
</success_criteria>

<output>
Create 02-SUMMARY.md in same directory with:
- Tasks completed (1, 2, 3)
- Files modified: web/package.json, web/tailwind.config.mjs, web/tsconfig.json, web/.gitignore
- Files created: web/src/styles/global.css
- Configuration updates:
  * Tailwind: Minecraft color palette with 10 custom colors
  * TypeScript: Strict mode verified, @types/node added
  * Dependencies: resend, wrangler, @types/node installed
- Verification results: TypeScript check passes, Tailwind colors configured
- Next plan: 03-PLAN.md (Directory structure, environment files, final verification)
- Link to parent stories:
  - .storyline/stories/epic-BH-WEB-001-01/story-02.md
  - .storyline/stories/epic-BH-WEB-001-01/story-03.md
  - .storyline/stories/epic-BH-WEB-001-01/story-05.md
- Commit hash (if code committed)
</output>
