# Epic 1: Site Foundation & Infrastructure

**Epic ID:** BH-WEB-001-01
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-PRD.md

---

## Business Goal

Establish the technical foundation for the BlockHaven marketing website, setting up Astro with Cloudflare hybrid rendering, Minecraft-themed design system, and project structure that supports both static pages and future SSR requirements for the admin dashboard.

## User Value

**Who Benefits:** Development team, future site maintainers

**How They Benefit:**
- Fast, modern development experience with Astro + TypeScript
- Cloudflare adapter enables both static pages (marketing) and SSR (admin dashboard Phase 2)
- Tailwind + Minecraft theme provides consistent, maintainable styling
- Proper project structure reduces technical debt and supports future growth

## Success Criteria

- [ ] Astro 4.x project initialized in `/web` directory with Cloudflare adapter
- [ ] Tailwind CSS configured with complete Minecraft color palette
- [ ] TypeScript compilation working without errors
- [ ] Project structure follows PRD specification (pages, components, layouts, lib, content)
- [ ] Placeholder `/dashboard` route exists with "Coming Soon" message
- [ ] API route structure created (`/api/request-access.ts` placeholder)
- [ ] Local development server runs successfully (`npm run dev`)
- [ ] Wrangler configured for local Cloudflare Workers development

## Scope

### In Scope
- Astro project initialization with `@astrojs/cloudflare` adapter
- Tailwind CSS setup with custom Minecraft theme configuration
- TypeScript configuration for Astro
- Directory structure: pages, components, layouts, lib, content, public
- Environment variables setup (`.env.example` file)
- Package.json with all dependencies (Astro, Tailwind, Cloudflare adapter, Resend, Wrangler)
- Basic `astro.config.mjs` configuration (hybrid rendering, Cloudflare output)
- Placeholder dashboard route (`/dashboard.astro`)
- API route structure (`/api/request-access.ts` stub)
- README.md for web project

### Out of Scope
- Content extraction from markdown docs (Epic 2)
- Building actual pages and components (Epic 3)
- Implementing form logic and email integration (Epic 4)
- Deployment to Cloudflare Pages (Epic 5)
- Writing actual content or copy

## Technical Notes

**Key Technologies:**
- Astro 4.x with hybrid rendering mode
- @astrojs/cloudflare adapter (enables SSR + static)
- Tailwind CSS 3.x with custom theme
- TypeScript 5.x
- Wrangler 3.x (Cloudflare Workers CLI)

**Minecraft Color Palette:**
```javascript
// tailwind.config.mjs
{
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
```

**Astro Config (Hybrid Rendering):**
```javascript
// astro.config.mjs
export default defineConfig({
  output: 'hybrid', // Static by default, SSR on demand
  adapter: cloudflare(),
  integrations: [tailwind()],
})
```

## Dependencies

**Depends On:** None (first epic)

**Blocks:**
- Epic 2: Content System & Data Layer
- Epic 3: Core Pages & Components
- Epic 4: Request Form & API Integration
- Epic 5: Deployment & Production

## Risks & Mitigations

**Risk:** Cloudflare adapter configuration issues
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Follow Astro's official Cloudflare adapter docs, test with `wrangler dev` locally

**Risk:** Tailwind theme configuration complexity
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Start with basic color palette, refine as needed

## Acceptance Criteria

### Project Initialization
- [ ] `npm create astro@latest` executed successfully
- [ ] Git repository initialized (if not already)
- [ ] `.gitignore` includes `node_modules/`, `.env`, `dist/`, `.wrangler/`

### Dependencies Installed
- [ ] `astro` ^4.0.0
- [ ] `@astrojs/cloudflare` ^11.0.0
- [ ] `@astrojs/tailwind` ^5.0.0
- [ ] `tailwindcss` ^3.4.0
- [ ] `resend` ^3.0.0
- [ ] `typescript` ^5.0.0
- [ ] `@types/node` ^20.0.0
- [ ] `wrangler` ^3.0.0

### Configuration Files
- [ ] `astro.config.mjs` configured with Cloudflare adapter and hybrid output
- [ ] `tailwind.config.mjs` includes Minecraft color palette
- [ ] `tsconfig.json` configured for Astro
- [ ] `.env.example` includes all required variables (RESEND_API_KEY, ADMIN_EMAIL, MC_SERVER_IP, etc.)

### Directory Structure
```
/web/
├── src/
│   ├── pages/
│   │   ├── dashboard.astro      (placeholder)
│   │   └── api/
│   │       └── request-access.ts (stub)
│   ├── layouts/
│   ├── components/
│   ├── content/
│   ├── lib/
│   └── styles/
│       └── global.css
├── public/
├── package.json
├── astro.config.mjs
├── tailwind.config.mjs
├── tsconfig.json
├── .env.example
└── README.md
```

### Verification
- [ ] `npm run dev` starts local dev server successfully
- [ ] TypeScript compilation has no errors
- [ ] Tailwind CSS classes work (test with simple HTML)
- [ ] Placeholder dashboard route accessible at `/dashboard`
- [ ] README.md documents setup, dev commands, and project structure

## Related User Stories

From PRD:
- User Story 8: "As the admin, I want content to auto-generate from docs" (Foundation for this)
- User Story 11: "As a mobile user, I want the site to work perfectly on my phone" (Tailwind responsive utilities)

## Notes

- This epic establishes the architecture that supports Phase 2 (Admin Dashboard) with GitHub OAuth and AWS SDK
- Cloudflare hybrid rendering allows marketing pages to be static (fast, SEO-friendly) while enabling SSR for admin routes
- Wrangler enables local development of Cloudflare Workers before deploying

---

**Next Epic:** Epic 2 - Content System & Data Layer
