---
phase_id: stories-01-05-combined-03
spec_source: .storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md
story_sources:
  - .storyline/stories/epic-BH-WEB-001-01/story-04.md
  - .storyline/stories/epic-BH-WEB-001-01/story-05.md
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
depends_on: 02-PLAN.md
---

<objective>
Create standard Astro directory structure, configure environment variables template, and verify complete project setup
</objective>

<execution_context>
Essential reading before executing ANY tasks:

@.storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md - Technical spec (see Directory Structure and Environment sections)
@.storyline/stories/epic-BH-WEB-001-01/story-04.md - Story 04: Create Directory Structure
@.storyline/stories/epic-BH-WEB-001-01/story-05.md - Story 05: Configure Environment Variables

**Execution protocol:**
- Follow deviation rules (auto-fix bugs, ask for architectural decisions)
- Document all deviations in SUMMARY.md
- Link SUMMARY back to parent stories

**Depends on:**
- Plans 01 and 02 complete (Astro project fully configured)
- web/src/ directory exists
</execution_context>

<context>
Existing structure from previous plans:

@web/src/pages/ - Already exists (created by Astro init)
@web/public/ - Already exists (created by Astro init)
@web/src/styles/ - Created in Plan 02

Need to create:
- web/src/components/
- web/src/layouts/
- web/src/lib/
- web/src/content/
</context>

<tasks>

<task type="auto">
<id>1</id>
<description>
Create standard Astro directory structure with documentation placeholders
</description>
<files>
web/src/components/ (create)
web/src/layouts/ (create)
web/src/lib/ (create)
web/src/content/ (create)
web/src/components/README.md (create)
web/src/layouts/README.md (create)
web/src/lib/README.md (create)
web/src/content/README.md (create)
</files>
<action>
Create all required directories with README placeholders:

1. Create directories:
   ```bash
   cd /home/aaronprill/projects/blockhaven/web
   mkdir -p src/components src/layouts src/lib src/content
   ```

2. Create README.md for components directory:
   ```markdown
   # Components

   Reusable UI components for the BlockHaven website.

   ## Organization
   - Use descriptive component names (e.g., `Header.astro`, `NavigationMenu.astro`)
   - Group related components in subdirectories if needed
   - Prefer Astro components (.astro) over framework components when possible

   ## Usage
   Import components in pages or layouts:
   ```astro
   ---
   import Header from '../components/Header.astro';
   ---
   <Header />
   ```
   ```

3. Create README.md for layouts directory:
   ```markdown
   # Layouts

   Page layout templates for the BlockHaven website.

   ## Organization
   - BaseLayout.astro - Main layout with common elements (head, nav, footer)
   - Use slots for flexible content placement

   ## Usage
   ```astro
   ---
   import BaseLayout from '../layouts/BaseLayout.astro';
   ---
   <BaseLayout title="Page Title">
     <p>Page content here</p>
   </BaseLayout>
   ```
   ```

4. Create README.md for lib directory:
   ```markdown
   # Library

   Utility functions, TypeScript types, and constants.

   ## Organization
   - utils/ - Helper functions
   - types/ - TypeScript type definitions
   - constants/ - App-wide constants
   - api/ - API client functions

   ## Usage
   ```typescript
   import { formatDate } from './lib/utils/date';
   import type { User } from './lib/types/user';
   ```
   ```

5. Create README.md for content directory:
   ```markdown
   # Content Collections

   Astro Content Collections for type-safe content management.

   ## Overview
   Content Collections provide:
   - Type-safe frontmatter validation
   - Automatic TypeScript types
   - Optimized content queries

   ## Setup (Epic 2)
   This directory will be configured in Epic 2: Content System with:
   - config.ts - Content collection schemas
   - rules/ - Markdown files for server rules
   - faq/ - FAQ entries

   ## Documentation
   https://docs.astro.build/en/guides/content-collections/
   ```

6. Verify directory structure:
   ```bash
   ls -la web/src/
   ```
   Should show: pages/, components/, layouts/, lib/, content/, styles/
</action>
<verify>
- [ ] web/src/components/ directory exists
- [ ] web/src/layouts/ directory exists
- [ ] web/src/lib/ directory exists
- [ ] web/src/content/ directory exists
- [ ] Each directory has a README.md file
- [ ] All README files contain appropriate documentation
</verify>
<done>
Standard Astro directory structure created with components, layouts, lib, and content directories, each documented with README files
</done>
</task>

<task type="auto">
<id>2</id>
<description>
Create .env.example template and wrangler.toml configuration for Cloudflare deployment
</description>
<files>
web/.env.example (create)
web/wrangler.toml (create)
</files>
<action>
1. Create .env.example with all required environment variables:

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

2. Create wrangler.toml for Cloudflare Workers configuration:

```toml
name = "blockhaven-web"
compatibility_date = "2024-01-01"

# Cloudflare Pages configuration
pages_build_output_dir = "./dist"
```

3. Verify .env is in .gitignore (should be from Plan 02):
   ```bash
   grep -q "^\.env$" web/.gitignore && echo "✓ .env in gitignore" || echo "✗ Add .env to gitignore"
   ```

4. Create placeholder .env file for local development (optional):
   ```bash
   cp web/.env.example web/.env
   ```
   Note: This file should NOT be committed (gitignored)
</action>
<verify>
- [ ] web/.env.example exists
- [ ] .env.example contains all required variables: RESEND_API_KEY, ADMIN_EMAIL, MC_SERVER_IP, MC_SERVER_PORT
- [ ] .env.example contains optional variables: DISCORD_WEBHOOK_URL, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET
- [ ] .env.example has no actual secrets (placeholder values only)
- [ ] web/wrangler.toml exists
- [ ] wrangler.toml has name = "blockhaven-web"
- [ ] wrangler.toml has pages_build_output_dir = "./dist"
- [ ] web/.gitignore includes .env (verified)
</verify>
<done>
Environment variable template (.env.example) and Wrangler configuration (wrangler.toml) created and ready for local/production use
</done>
</task>

<task type="checkpoint:human-verify">
<id>3</id>
<description>
Verify complete project setup by running dev server and build process
</description>
<files>
All project files
</files>
<action>
Run comprehensive verification tests:

1. **Dev server test:**
   ```bash
   cd /home/aaronprill/projects/blockhaven/web
   npm run dev
   ```
   Expected:
   - Server starts without errors
   - Accessible at http://localhost:4321
   - Default Astro page loads
   - No console errors

   Stop server after verification (Ctrl+C)

2. **Build test:**
   ```bash
   cd /home/aaronprill/projects/blockhaven/web
   npm run build
   ```
   Expected:
   - `astro check` passes with 0 TypeScript errors
   - Build completes successfully
   - dist/ directory created
   - Static files + _worker.js present

3. **TypeScript verification:**
   ```bash
   cd /home/aaronprill/projects/blockhaven/web
   npx astro check
   ```
   Expected output: "0 errors, 0 warnings"

4. **File structure verification:**
   ```bash
   cd /home/aaronprill/projects/blockhaven/web
   tree -L 3 -I 'node_modules|dist'
   ```
   Or use ls to verify structure

5. **Tailwind test (optional):**
   Create a test component with Minecraft colors and verify they apply:
   ```bash
   echo '<div class="bg-primary-grass text-accent-diamond p-4">Minecraft colors work!</div>' > src/pages/color-test.astro
   ```
   Visit http://localhost:4321/color-test and check colors
</action>
<verify>
- [ ] npm run dev starts without errors
- [ ] http://localhost:4321 loads successfully
- [ ] npm run build completes with 0 TypeScript errors
- [ ] dist/ directory created with static files and _worker.js
- [ ] npx astro check shows 0 errors
- [ ] Directory structure matches spec (7 directories in src/)
- [ ] Minecraft Tailwind colors apply correctly (optional manual test)
</verify>
<done>
Complete project setup verified: dev server runs, build succeeds, TypeScript passes, all directories created, environment configured
</done>
</task>

</tasks>

<verification>
Final comprehensive checks:

1. **Complete directory structure:**
   ```bash
   ls -la web/src/
   ```
   Should show: pages/, components/, layouts/, lib/, content/, styles/, public/

2. **Configuration files present:**
   ```bash
   ls -la web/ | grep -E "(package.json|astro.config|tailwind.config|tsconfig|wrangler|\.env\.example|\.gitignore)"
   ```
   Should show all configuration files

3. **All acceptance criteria verification:**
   Run through the manual testing checklist from spec:
   - ✓ npm run dev works
   - ✓ npm run build succeeds
   - ✓ TypeScript check passes
   - ✓ Tailwind colors configured
   - ✓ All directories exist
   - ✓ Environment template created
   - ✓ Git ignores sensitive files

4. **Dependencies check:**
   ```bash
   cat web/package.json | grep -E "astro|cloudflare|tailwind|resend|wrangler"
   ```
   Should show all required dependencies installed
</verification>

<success_criteria>
From parent stories:

**Story 04 - Directory Structure:**
- [x] All directories created (pages, components, layouts, lib, content, styles, public)
- [x] Directories have documentation (README.md files)
- [x] src/content/README.md explains Content Collections

**Story 05 - Environment Variables:**
- [x] .env.example created with all required variables
- [x] .env.example has descriptive comments
- [x] No actual secrets in .env.example
- [x] .env in .gitignore
- [x] wrangler.toml configured
- [x] Environment variables accessible in Astro (tested in verification)

**Combined Spec - All Stories 01-05:**
- [x] Astro 4.x initialized with hybrid rendering
- [x] Cloudflare adapter configured
- [x] Tailwind CSS with Minecraft colors
- [x] TypeScript strict mode
- [x] Complete directory structure
- [x] Environment configuration ready
- [x] Dev server works
- [x] Build succeeds
</success_criteria>

<output>
Create 03-SUMMARY.md in same directory with:
- Tasks completed (1, 2, 3)
- Files created:
  * Directories: web/src/components, layouts, lib, content
  * Documentation: README.md in each directory
  * Configuration: web/.env.example, web/wrangler.toml
- Verification results:
  * Dev server: ✓ Starts successfully
  * Build: ✓ Completes with 0 errors
  * TypeScript: ✓ 0 errors
  * Tailwind: ✓ Minecraft colors configured
  * Structure: ✓ All 7 directories present
- Complete acceptance criteria mapping (all stories 01-05)
- Next steps: Implement Story 06 (Placeholder routes) with spec-06.md
- Link to parent stories:
  - .storyline/stories/epic-BH-WEB-001-01/story-01.md
  - .storyline/stories/epic-BH-WEB-001-01/story-02.md
  - .storyline/stories/epic-BH-WEB-001-01/story-03.md
  - .storyline/stories/epic-BH-WEB-001-01/story-04.md
  - .storyline/stories/epic-BH-WEB-001-01/story-05.md
- Commit hash (if code committed)
- Status: Stories 01-05 COMPLETE ✅
</output>
