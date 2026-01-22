---
spec_id: stories-01-05-combined
story_ids: [01, 02, 03, 04, 05]
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Initialize Astro Project with Complete Foundation Setup
status: ready_for_implementation
complexity: combined
parent_stories:
  - ../../stories/epic-BH-WEB-001-01/story-01.md
  - ../../stories/epic-BH-WEB-001-01/story-02.md
  - ../../stories/epic-BH-WEB-001-01/story-03.md
  - ../../stories/epic-BH-WEB-001-01/story-04.md
  - ../../stories/epic-BH-WEB-001-01/story-05.md
created: 2026-01-22
---

# Technical Spec: Initialize Astro Project with Complete Foundation Setup

## Overview

**User stories:** Stories 01-05 (Project Foundation & Configuration)

**Goal:** Create a production-ready Astro project in `/web` with Cloudflare hybrid rendering, Tailwind CSS with Minecraft theme, TypeScript strict mode, standard directory structure, and environment variables configured for local and production development.

**Approach:** Execute a sequential setup workflow: initialize Astro with Cloudflare adapter → install and configure Tailwind with custom theme → configure TypeScript strict mode → create all required directories → set up environment variables and Wrangler config. This combined spec groups all foundation stories since they're interdependent and executed together in a single setup session.

## Technical Design

### Architecture Decision

**Chosen approach:** Astro 4.x with **hybrid rendering** using Cloudflare Pages adapter

**Why hybrid rendering:**
- **Static by default**: Marketing pages (/, /about, /rules) are pre-rendered at build time for maximum performance and SEO
- **SSR on-demand**: Admin dashboard (`/dashboard`) and API routes (`/api/*`) run server-side on Cloudflare Workers
- **Future-proof**: Supports Phase 2 admin features (GitHub OAuth, AWS SDK integration) without architectural changes

**Alternatives considered:**
- **Full static (`output: 'static'`)** - Would require separate API service for form submissions; doesn't support future admin dashboard
- **Full SSR (`output: 'server'`)** - Slower for marketing pages; unnecessary overhead for static content
- **Node adapter** - Locks us into Node.js runtime; Cloudflare Workers offer better global performance

**Rationale:** Hybrid rendering gives us the best of both worlds: blazing-fast static pages for marketing content, with dynamic capabilities ready for admin features and API endpoints.

### System Components

**Frontend:**
- Astro 4.x framework with file-based routing
- Tailwind CSS 3.x with custom Minecraft color palette
- TypeScript 5.x with strict type checking
- Responsive design (mobile, tablet, desktop)

**Backend:**
- Cloudflare Workers (via Astro's Cloudflare adapter)
- API routes at `/api/*` (TypeScript endpoints)
- Environment variable support (Astro + Wrangler)

**Build & Deployment:**
- Wrangler 3.x CLI for Cloudflare Pages deployment
- ESM module format (astro.config.mjs, tailwind.config.mjs)
- Hybrid output: dist/ contains static files + Workers edge functions

**Development Tools:**
- TypeScript language server for IDE autocomplete
- Tailwind IntelliSense for VSCode
- Hot module replacement (HMR) for instant feedback

## Implementation Details

### Files to Create

#### 1. Project Configuration Files

**`web/package.json`**
- **Purpose:** Define dependencies and npm scripts
- **Key dependencies:**
  - `astro@^4.0.0`
  - `@astrojs/cloudflare@^11.0.0`
  - `@astrojs/tailwind@^5.0.0`
  - `tailwindcss@^3.4.0`
  - `typescript@^5.0.0`
  - `@types/node@^20.0.0`
  - `resend@^3.0.0` (for email)
  - `wrangler@^3.0.0`
- **Scripts:**
  - `dev`: Start development server
  - `build`: Build for production
  - `preview`: Preview production build
  - `astro`: Astro CLI commands

**`web/astro.config.mjs`**
- **Purpose:** Configure Astro with Cloudflare adapter and Tailwind integration
- **Exports:**
  - `output: 'hybrid'` - Enable hybrid rendering
  - `adapter: cloudflare()` - Cloudflare Pages deployment
  - `integrations: [tailwind()]` - Tailwind CSS integration

**`web/tailwind.config.mjs`**
- **Purpose:** Tailwind configuration with Minecraft theme
- **Key config:**
  - `content`: Scan all Astro, JS, TS files for classes
  - `theme.extend.colors`: Minecraft color palette (grass, emerald, stone, diamond, gold)
  - `plugins`: Empty array (can add later)

**`web/tsconfig.json`**
- **Purpose:** TypeScript configuration for Astro
- **Key config:**
  - Extends `astro/tsconfigs/strict`
  - `jsx: "react-jsx"` for JSX support
  - `moduleResolution: "bundler"` for Astro's bundler
  - `types: ["@types/node"]` for Node.js types

**`web/.env.example`**
- **Purpose:** Template for environment variables (no secrets)
- **Variables:**
  - `RESEND_API_KEY` - Email service API key
  - `ADMIN_EMAIL` - Admin email for form submissions
  - `MC_SERVER_IP` - Minecraft server IP
  - `MC_SERVER_PORT` - Minecraft server port
  - `DISCORD_WEBHOOK_URL` (optional)
  - `GITHUB_CLIENT_ID/SECRET` (Phase 2)

**`web/wrangler.toml`**
- **Purpose:** Wrangler configuration for Cloudflare Workers
- **Key config:**
  - `name`: "blockhaven-web"
  - `compatibility_date`: "2024-01-01"
  - `pages_build_output_dir`: "./dist"

**`web/.gitignore`**
- **Purpose:** Prevent committing generated files and secrets
- **Entries:**
  - `node_modules/`
  - `.env`, `.env.local`, `.env.production`
  - `dist/`
  - `.wrangler/`
  - `.DS_Store`

#### 2. Directory Structure

**`web/src/pages/`**
- **Purpose:** File-based routing (created by Astro init)
- **Initial file:** `index.astro` (homepage placeholder)

**`web/src/components/`**
- **Purpose:** Reusable UI components
- **Initial file:** `.gitkeep` or `README.md`

**`web/src/layouts/`**
- **Purpose:** Page layout templates
- **Initial file:** `.gitkeep` or `README.md`

**`web/src/lib/`**
- **Purpose:** Utility functions, types, constants
- **Initial file:** `.gitkeep` or `README.md`

**`web/src/content/`**
- **Purpose:** Astro Content Collections (Epic 2)
- **Initial file:** `README.md` explaining Content Collections

**`web/src/styles/global.css`**
- **Purpose:** Global styles and Tailwind directives
- **Content:**
  ```css
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
  ```

**`web/public/`**
- **Purpose:** Static assets (images, fonts, favicon)
- **Created by:** Astro init

### Files to Modify

**None** - This is a greenfield project initialization. All files are created, not modified.

### Configuration Specifics

#### Astro Configuration (`astro.config.mjs`)

```javascript
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  output: 'hybrid', // Static by default, SSR on demand
  adapter: cloudflare(),
  integrations: [tailwind()],
});
```

#### Tailwind Configuration (`tailwind.config.mjs`)

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

#### TypeScript Configuration (`tsconfig.json`)

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2022",
    "lib": ["ES2022"],
    "skipLibCheck": true,
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "types": ["@types/node"]
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

#### Environment Variables (`.env.example`)

```bash
# Email service (Resend) - Get from https://resend.com/api-keys
RESEND_API_KEY=re_your_api_key_here

# Admin email for form submissions
ADMIN_EMAIL=admin@bhsmp.com

# Minecraft server connection details
MC_SERVER_IP=play.bhsmp.com
MC_SERVER_PORT=25565

# Optional: Discord webhook for notifications (Phase 2)
DISCORD_WEBHOOK_URL=

# Optional: GitHub OAuth (Phase 2 - Admin Dashboard)
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
```

#### Wrangler Configuration (`wrangler.toml`)

```toml
name = "blockhaven-web"
compatibility_date = "2024-01-01"

# Cloudflare Pages configuration
pages_build_output_dir = "./dist"
```

#### Package.json Scripts

```json
{
  "name": "blockhaven-web",
  "type": "module",
  "version": "0.0.1",
  "scripts": {
    "dev": "astro dev",
    "start": "astro dev",
    "build": "astro check && astro build",
    "preview": "astro preview",
    "astro": "astro"
  },
  "dependencies": {
    "astro": "^4.0.0",
    "@astrojs/cloudflare": "^11.0.0",
    "@astrojs/tailwind": "^5.0.0",
    "tailwindcss": "^3.4.0",
    "resend": "^3.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "wrangler": "^3.0.0"
  }
}
```

## Acceptance Criteria Mapping

### Story 01: Initialize Astro Project

**Criterion:** Astro 4.x installed successfully
**Verification:**
- Run `npm create astro@latest` in `/web` directory
- Check `package.json` includes `"astro": "^4.0.0"`
- Verify `node_modules/astro` exists

**Criterion:** Cloudflare adapter configured
**Verification:**
- Check `astro.config.mjs` includes `adapter: cloudflare()`
- Check `package.json` includes `"@astrojs/cloudflare": "^11.0.0"`

**Criterion:** Hybrid rendering enabled
**Verification:**
- Check `astro.config.mjs` has `output: 'hybrid'`
- Run `npm run dev` and verify server starts at `http://localhost:4321`

**Criterion:** Git configured
**Verification:**
- Check `.gitignore` includes `node_modules/`, `.env`, `dist/`, `.wrangler/`

### Story 02: Configure Tailwind CSS

**Criterion:** Tailwind integration installed
**Verification:**
- Check `astro.config.mjs` includes `tailwind()` in integrations
- Check `package.json` includes `"@astrojs/tailwind"` and `"tailwindcss"`

**Criterion:** Minecraft color palette configured
**Verification:**
- Check `tailwind.config.mjs` theme.extend.colors includes:
  - `primary.grass`, `primary.emerald`
  - `secondary.stone`, `secondary.darkGray`
  - `accent.diamond`, `accent.gold`
  - `background.light`, `background.dark`
  - `text.dark`, `text.light`

**Criterion:** Global CSS created
**Verification:**
- Check `src/styles/global.css` exists
- File includes `@tailwind base;`, `@tailwind components;`, `@tailwind utilities;`

**Criterion:** Tailwind classes work
**Verification:**
- Create test `.astro` file with `class="bg-primary-grass text-accent-diamond"`
- Run dev server and inspect element in browser
- Verify styles are applied correctly

### Story 03: Configure TypeScript

**Criterion:** TypeScript compiles without errors
**Verification:**
- Run `npm run build` successfully
- Run `tsc --noEmit` (if available) with zero errors
- Check `@types/node` in devDependencies

**Criterion:** tsconfig.json configured for Astro
**Verification:**
- File extends `"astro/tsconfigs/strict"`
- `compilerOptions.jsx` is `"react-jsx"`
- `compilerOptions.moduleResolution` is `"bundler"`
- `include` has `["src/**/*"]`

**Criterion:** Type checking works in IDE
**Verification:**
- Open VSCode in `/web` directory
- Create `.astro` file with intentional type error
- Verify VSCode shows red squiggly underline

### Story 04: Create Directory Structure

**Criterion:** All directories created
**Verification:**
- Check `src/pages/` exists (from Astro init)
- Check `src/components/` exists
- Check `src/layouts/` exists
- Check `src/lib/` exists
- Check `src/content/` exists
- Check `src/styles/` exists (contains `global.css`)
- Check `public/` exists (from Astro init)

**Criterion:** Directories have documentation
**Verification:**
- Each empty directory has `.gitkeep` or `README.md`
- `src/content/README.md` explains Content Collections purpose

### Story 05: Configure Environment Variables

**Criterion:** .env.example created
**Verification:**
- File exists with all required variables:
  - `RESEND_API_KEY`, `ADMIN_EMAIL`, `MC_SERVER_IP`, `MC_SERVER_PORT`
  - Optional: `DISCORD_WEBHOOK_URL`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`
- Each variable has descriptive comment
- No actual secrets in file (placeholder values only)

**Criterion:** .env in .gitignore
**Verification:**
- `.gitignore` includes `.env`, `.env.local`, `.env.production`

**Criterion:** Wrangler configured
**Verification:**
- `wrangler.toml` exists
- `name` is "blockhaven-web"
- `pages_build_output_dir` is "./dist"

**Criterion:** Environment variables accessible in Astro
**Verification:**
- Create `.env` locally (copy from `.env.example`)
- Add test value: `TEST_VAR=hello`
- In `.astro` file, log `import.meta.env.TEST_VAR`
- Verify value appears in console

## Testing Requirements

### Manual Testing Checklist

**After setup completion:**

- [ ] Run `npm run dev` - dev server starts without errors
- [ ] Open `http://localhost:4321` - default Astro page loads
- [ ] Inspect page in browser DevTools - Tailwind styles applied
- [ ] Check console - no errors
- [ ] Test Tailwind class - create element with `bg-primary-grass`, verify green background
- [ ] Run `npm run build` - builds successfully with no TypeScript errors
- [ ] Run `npm run preview` - production build serves correctly
- [ ] Check file structure - all directories exist
- [ ] Verify `.env` not committed - `git status` shows it ignored
- [ ] Test env var access - log `import.meta.env.MC_SERVER_IP` in `.astro` file

### Build Verification

**Build command:**
```bash
cd web && npm run build
```

**Expected output:**
```
astro check - TypeScript check passes ✓
astro build - Building for production
  ✓ Generated static routes
  ✓ Built Cloudflare Workers bundle
```

**Verify output directory:**
```bash
ls -la web/dist/
```

**Expected:**
- `dist/` directory created
- Static HTML files present
- `_worker.js` file (Cloudflare Workers bundle)

### TypeScript Verification

**Type check command:**
```bash
cd web && npx astro check
```

**Expected output:**
```
Result (N files):
- 0 errors
- 0 warnings
- 0 hints
```

## Dependencies

**Prerequisites:**
- Node.js 18+ installed
- npm or pnpm package manager
- Git initialized in project root
- `/web` directory (will be created if missing)

**Must complete before:**
- Story 06: Create placeholder routes (needs this foundation)
- Epic 2: Content System (needs Astro + directory structure)
- Epic 3: Pages & Components (needs Astro + Tailwind + directories)

**No dependencies:** This is the first epic - no prior work required.

## Risks & Mitigations

**Risk 1: Cloudflare adapter version incompatibility**
- **Likelihood:** Low
- **Impact:** Medium (dev server won't start)
- **Mitigation:** Pin to specific working version: `@astrojs/cloudflare@^11.0.0`
- **Fallback:** Check Astro docs for latest Cloudflare adapter compatibility

**Risk 2: Tailwind classes not applying**
- **Likelihood:** Low
- **Impact:** Low (visual only, doesn't block development)
- **Mitigation:** Ensure `tailwind.config.mjs` content array includes all file types
- **Fallback:** Manually import `global.css` in Astro layout if auto-import fails

**Risk 3: TypeScript strict mode too restrictive**
- **Likelihood:** Low
- **Impact:** Low (can adjust `tsconfig.json`)
- **Mitigation:** Start with `astro/tsconfigs/strict`, disable specific rules if needed
- **Fallback:** Use `// @ts-ignore` for edge cases (sparingly)

**Risk 4: Environment variables not loading**
- **Likelihood:** Low
- **Impact:** Medium (API routes won't work)
- **Mitigation:** Ensure `.env` file is in project root (`/web/.env`), restart dev server after changes
- **Fallback:** Use Wrangler secrets for production deployment (Epic 5)

## Performance Considerations

**Build time:**
- Expected: <30 seconds for initial build (no pages yet)
- Optimization: Hybrid rendering pre-renders static pages at build time

**Dev server startup:**
- Expected: <5 seconds
- HMR (Hot Module Replacement): <100ms for CSS/JS changes

**Bundle size (after build):**
- Initial (no pages): <50KB total
- Tailwind purged automatically (unused classes removed)
- Cloudflare Workers bundle: <1MB

**Benchmarks:**
- Dev server startup: 3-5 seconds
- `npm run build`: 20-30 seconds (with type checking)
- Tailwind class compilation: Instant (JIT mode)

## Security Considerations

**Environment variables:**
- Never commit `.env` to git (enforced by `.gitignore`)
- Use `.env.example` with placeholder values only
- Server-side variables (no `PUBLIC_` prefix) not exposed to browser

**Dependencies:**
- Pin major versions to prevent breaking changes
- Regularly update with `npm update` for security patches

**Cloudflare adapter:**
- API routes run in isolated Cloudflare Workers (secure by design)
- No CORS issues (same origin)

**TypeScript strict mode:**
- Catch type errors before deployment
- Prevent null/undefined runtime errors

## Success Verification

After implementation, verify all criteria:

**Build & Development:**
- [ ] `npm run dev` starts successfully (port 4321)
- [ ] `npm run build` completes with zero errors
- [ ] `npm run preview` serves production build

**Configuration:**
- [ ] `astro.config.mjs` has hybrid rendering + Cloudflare adapter
- [ ] `tailwind.config.mjs` has all 10 Minecraft colors
- [ ] `tsconfig.json` extends strict config
- [ ] `.env.example` has all required variables

**Directory Structure:**
- [ ] All 7 directories exist (pages, components, layouts, lib, content, styles, public)
- [ ] `src/styles/global.css` has Tailwind directives

**TypeScript:**
- [ ] IDE autocomplete works in `.astro` files
- [ ] Type errors show red squiggles in VSCode
- [ ] Build fails on type errors (strict mode)

**Tailwind:**
- [ ] Minecraft color classes work (e.g., `bg-primary-grass`)
- [ ] Responsive utilities work (e.g., `sm:`, `md:`)
- [ ] HMR updates styles instantly

**Environment Variables:**
- [ ] `.env` ignored by git
- [ ] `import.meta.env.*` accessible in server-side code
- [ ] No warnings about missing env vars on dev server start

## Traceability

**Parent stories:**
- [Story 01: Initialize Astro Project](../../stories/epic-BH-WEB-001-01/story-01.md)
- [Story 02: Configure Tailwind CSS](../../stories/epic-BH-WEB-001-01/story-02.md)
- [Story 03: Configure TypeScript](../../stories/epic-BH-WEB-001-01/story-03.md)
- [Story 04: Create Directory Structure](../../stories/epic-BH-WEB-001-01/story-04.md)
- [Story 05: Configure Environment Variables](../../stories/epic-BH-WEB-001-01/story-05.md)

**Parent epic:** [Epic BH-WEB-001-01: Site Foundation & Infrastructure](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   ├─ stories/epic-BH-WEB-001-01/story-01.md
   ├─ stories/epic-BH-WEB-001-01/story-02.md
   ├─ stories/epic-BH-WEB-001-01/story-03.md
   ├─ stories/epic-BH-WEB-001-01/story-04.md
   └─ stories/epic-BH-WEB-001-01/story-05.md
      └─ specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md (this file)
         └─ [Implementation via /sl-develop]
```

## Implementation Notes

**Recommended execution order:**

1. **Navigate to project root:**
   ```bash
   cd /home/aaronprill/projects/blockhaven
   ```

2. **Initialize Astro project:**
   ```bash
   npm create astro@latest web
   ```
   - Choose "Empty" template
   - Select "Yes" for TypeScript (strict)
   - Select "Yes" for install dependencies
   - Select "Yes" for git initialization (if not already initialized)

3. **Install Cloudflare adapter:**
   ```bash
   cd web
   npx astro add cloudflare
   ```

4. **Install Tailwind:**
   ```bash
   npx astro add tailwind
   ```

5. **Install remaining dependencies:**
   ```bash
   npm install resend
   npm install -D @types/node wrangler
   ```

6. **Configure files** (in order):
   - Update `astro.config.mjs` (ensure `output: 'hybrid'`)
   - Update `tailwind.config.mjs` (add Minecraft colors)
   - Update `tsconfig.json` (verify strict mode)
   - Create `src/styles/global.css`
   - Create directory structure (mkdir commands)
   - Create `.env.example`
   - Create `wrangler.toml`
   - Update `.gitignore` (ensure all entries present)

7. **Verify setup:**
   ```bash
   npm run dev
   ```
   Open `http://localhost:4321` and verify page loads.

**Open questions:**
- Should we add `prettier-plugin-tailwindcss` for class sorting? (Optional, can add later)
- Do we need path aliases (`@/components`)? (Not in MVP, can add in Epic 2+)

**Assumptions:**
- Node.js 18+ is installed on the system
- Developer has npm access (not behind corporate proxy)
- `/web` directory doesn't already exist (or is empty)
- Git is initialized in project root (`/home/aaronprill/projects/blockhaven/.git`)

**Notes for implementation:**
- Astro's `create` command is interactive - select "Empty" template, TypeScript strict, install deps
- `npx astro add` commands auto-update `astro.config.mjs` - verify changes afterward
- Tailwind config uses ESM (`.mjs`) - ensure `export default` syntax
- Environment variables prefixed with `PUBLIC_` are client-accessible (avoid for secrets)
- Wrangler config is minimal for now - Epic 5 will add production deployment details

---

**Next step:** Implement this spec with `/sl-develop .storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md`
