---
phase_id: stories-01-05-combined-01
spec_source: .storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md
story_sources:
  - .storyline/stories/epic-BH-WEB-001-01/story-01.md
  - .storyline/stories/epic-BH-WEB-001-01/story-02.md
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
---

<objective>
Initialize Astro 4.x project in /web directory with Cloudflare adapter and Tailwind CSS integration for hybrid rendering
</objective>

<execution_context>
Essential reading before executing ANY tasks:

@.storyline/specs/epic-BH-WEB-001-01/spec-stories-01-05-combined.md - Technical spec for foundation setup
@.storyline/stories/epic-BH-WEB-001-01/story-01.md - Story 01: Initialize Astro Project
@.storyline/stories/epic-BH-WEB-001-01/story-02.md - Story 02: Configure Tailwind CSS

**Execution protocol:**
- Follow deviation rules (auto-fix bugs, ask for architectural decisions)
- Document all deviations in SUMMARY.md
- Link SUMMARY back to parent stories
- Use interactive CLI commands carefully (provide appropriate answers)

**Project context:**
- Working directory: /home/aaronprill/projects/blockhaven
- Target directory: /home/aaronprill/projects/blockhaven/web (will be created)
- This is a greenfield Astro project initialization
- Hybrid rendering required: static by default, SSR on demand
</execution_context>

<context>
No existing files to read - this is project initialization.

Key configuration targets (will be created):
- web/package.json
- web/astro.config.mjs
- web/tailwind.config.mjs
</context>

<tasks>

<task type="auto">
<id>1</id>
<description>
Initialize Astro 4.x project in /web directory with empty template and TypeScript strict mode
</description>
<files>
web/ (new directory)
web/package.json (created by Astro CLI)
web/astro.config.mjs (created by Astro CLI)
web/tsconfig.json (created by Astro CLI)
</files>
<action>
Navigate to project root and initialize Astro project:

1. Ensure we're in the correct directory:
   cd /home/aaronprill/projects/blockhaven

2. Run Astro initialization command:
   npm create astro@latest web -- --template empty --typescript strict --install --git

This command will:
- Create /web directory
- Install Astro 4.x with empty template
- Configure TypeScript in strict mode
- Install dependencies automatically
- Initialize git (or integrate with existing repo)

3. Verify initialization:
   - Check web/package.json exists and contains "astro": "^4.x"
   - Check web/astro.config.mjs exists
   - Check web/src/pages/ directory created
   - Check node_modules populated
</action>
<verify>
- [ ] web/ directory exists
- [ ] web/package.json contains "astro" dependency at ^4.0.0 or higher
- [ ] web/astro.config.mjs exists
- [ ] web/tsconfig.json exists
- [ ] web/node_modules/ populated
- [ ] web/src/pages/ directory exists
</verify>
<done>
Astro 4.x project initialized with basic structure, TypeScript strict mode enabled, and dependencies installed
</done>
</task>

<task type="auto">
<id>2</id>
<description>
Install and configure @astrojs/cloudflare adapter for hybrid rendering deployment
</description>
<files>
web/astro.config.mjs (will be modified)
web/package.json (will be modified - dependency added)
</files>
<action>
Install Cloudflare adapter using Astro's integration command:

1. Navigate to web directory:
   cd /home/aaronprill/projects/blockhaven/web

2. Add Cloudflare adapter:
   npx astro add cloudflare --yes

This command will:
- Install @astrojs/cloudflare package
- Auto-update astro.config.mjs to include adapter
- Add adapter to package.json dependencies

3. Verify adapter configuration:
   - Check astro.config.mjs imports cloudflare
   - Check astro.config.mjs includes adapter: cloudflare()
   - Ensure output: 'hybrid' is set (or add it manually if needed)

4. If output: 'hybrid' is not set, manually add it to astro.config.mjs
</action>
<verify>
- [ ] web/package.json contains "@astrojs/cloudflare" dependency
- [ ] web/astro.config.mjs imports 'cloudflare' from '@astrojs/cloudflare'
- [ ] web/astro.config.mjs includes adapter: cloudflare()
- [ ] web/astro.config.mjs includes output: 'hybrid'
</verify>
<done>
Cloudflare adapter installed and configured in astro.config.mjs with hybrid rendering enabled
</done>
</task>

<task type="auto">
<id>3</id>
<description>
Install and configure @astrojs/tailwind integration for CSS styling
</description>
<files>
web/astro.config.mjs (will be modified)
web/package.json (will be modified - dependencies added)
web/tailwind.config.mjs (will be created)
</files>
<action>
Install Tailwind CSS integration using Astro's integration command:

1. Ensure in web directory:
   cd /home/aaronprill/projects/blockhaven/web

2. Add Tailwind integration:
   npx astro add tailwind --yes

This command will:
- Install @astrojs/tailwind and tailwindcss packages
- Auto-update astro.config.mjs to include tailwind integration
- Create tailwind.config.mjs with default configuration
- Add Tailwind dependencies to package.json

3. Verify Tailwind configuration:
   - Check astro.config.mjs imports tailwind
   - Check astro.config.mjs includes tailwind() in integrations array
   - Check tailwind.config.mjs exists
   - Check package.json has "tailwindcss" and "@astrojs/tailwind"
</action>
<verify>
- [ ] web/package.json contains "@astrojs/tailwind" dependency
- [ ] web/package.json contains "tailwindcss" dependency
- [ ] web/tailwind.config.mjs exists
- [ ] web/astro.config.mjs imports 'tailwind' from '@astrojs/tailwind'
- [ ] web/astro.config.mjs includes tailwind() in integrations array
</verify>
<done>
Tailwind CSS installed and integrated with Astro, tailwind.config.mjs created with default configuration
</done>
</task>

</tasks>

<verification>
After completing all tasks:

1. **Project structure check:**
   ```bash
   ls -la web/
   ```
   Should show: package.json, astro.config.mjs, tailwind.config.mjs, tsconfig.json, node_modules/, src/

2. **Configuration verification:**
   ```bash
   cat web/astro.config.mjs
   ```
   Should show:
   - import cloudflare from '@astrojs/cloudflare'
   - import tailwind from '@astrojs/tailwind'
   - output: 'hybrid'
   - adapter: cloudflare()
   - integrations: [tailwind()]

3. **Dependencies check:**
   ```bash
   cat web/package.json | grep -E "(astro|cloudflare|tailwind)"
   ```
   Should show all three dependencies installed

4. **Dev server test:**
   ```bash
   cd web && npm run dev
   ```
   Should start without errors (can stop after verification)
</verification>

<success_criteria>
From parent stories:

**Story 01 - Astro Initialization:**
- [x] Astro 4.x installed successfully
- [x] Cloudflare adapter configured
- [x] Hybrid rendering enabled
- [x] Basic project structure created

**Story 02 - Tailwind:**
- [x] Tailwind integration installed
- [x] tailwind.config.mjs created
- [x] Astro config includes tailwind() integration

**Partial completion** - Full Tailwind configuration (Minecraft colors) and directory structure will be in subsequent plans.
</success_criteria>

<output>
Create 01-SUMMARY.md in same directory with:
- Tasks completed (1, 2, 3)
- Files created: web/package.json, web/astro.config.mjs, web/tailwind.config.mjs, web/tsconfig.json, web/src/
- Configuration status: Astro + Cloudflare + Tailwind installed
- Dependencies installed: astro, @astrojs/cloudflare, @astrojs/tailwind, tailwindcss
- Verification results: Dev server starts successfully
- Next plan: 02-PLAN.md (Configure Tailwind colors, TypeScript, additional dependencies)
- Link to parent stories:
  - .storyline/stories/epic-BH-WEB-001-01/story-01.md
  - .storyline/stories/epic-BH-WEB-001-01/story-02.md
- Commit hash (if code committed)
</output>
