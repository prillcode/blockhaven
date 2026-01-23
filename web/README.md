# BlockHaven Marketing Website

Official marketing website for the BlockHaven Minecraft server (invite-only SMP at `play.bhsmp.com`).

Built with Astro 5.x, Cloudflare Pages, and Tailwind CSS 4.x with a custom Minecraft-themed color palette.

## Tech Stack

- **[Astro 5.x](https://astro.build/)** - Modern web framework with hybrid rendering
- **[Cloudflare Pages](https://pages.cloudflare.com/)** - Deployment platform with edge Workers
- **[Tailwind CSS 4.x](https://tailwindcss.com/)** - Utility-first CSS with custom Minecraft theme
- **[TypeScript 5.x](https://www.typescriptlang.org/)** - Type-safe JavaScript
- **[Resend](https://resend.com/)** - Transactional email service (Epic 4)
- **[Wrangler 3.x](https://developers.cloudflare.com/workers/wrangler/)** - Cloudflare Workers CLI

## Getting Started

### Prerequisites

- **Node.js 18+** (check with `node -v`)
- **npm** or **pnpm** package manager
- **Git** (project is version-controlled)

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/prillcode/blockhaven.git
   cd blockhaven/web
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and add your API keys (see [Environment Variables](#environment-variables) section below).

4. **Start the development server:**
   ```bash
   npm run dev
   ```

5. **Open your browser:**
   Navigate to [http://localhost:4321](http://localhost:4321)

You should see the BlockHaven homepage!

## Development Commands

All commands are run from the `/web` directory:

| Command                | Action                                           |
|:-----------------------|:-------------------------------------------------|
| `npm install`          | Install dependencies                             |
| `npm run dev`          | Start dev server at `localhost:4321`             |
| `npm run build`        | Build production site to `./dist/`               |
| `npm run preview`      | Preview production build locally                 |
| `npm run check`        | Type-check the project (TypeScript)              |
| `npm run astro`        | Run Astro CLI commands                           |

## Project Structure

```
/web/
├── src/
│   ├── pages/              # File-based routing (*.astro → routes)
│   │   ├── index.astro     # Homepage (/)
│   │   ├── dashboard.astro # Admin dashboard - Phase 2 (SSR)
│   │   └── api/            # API routes (TypeScript endpoints)
│   │       └── request-access.ts  # Form submission - Epic 4
│   ├── components/         # Reusable UI components
│   ├── layouts/            # Page layout templates
│   │   └── BaseLayout.astro # Base HTML layout with global styles
│   ├── lib/                # Utility functions, types, constants
│   ├── types/              # TypeScript type definitions
│   ├── content/            # Astro Content Collections (Epic 2)
│   └── styles/
│       └── global.css      # Tailwind imports + Minecraft theme
├── public/                 # Static assets (images, fonts, favicon)
├── .env.example            # Environment variable template
├── astro.config.mjs        # Astro configuration (server mode + Cloudflare)
├── tsconfig.json           # TypeScript configuration (strict mode)
├── wrangler.toml           # Cloudflare Workers configuration
└── package.json            # Dependencies and scripts
```

## Architecture

### Hybrid Rendering

The site uses Astro 5.x's **server rendering mode** (`output: 'server'`) with per-page prerender control:

- **Static pages:** Add `export const prerender = true` for pages that should be pre-rendered at build time (marketing pages like `/`, `/about`, `/rules`)
- **SSR pages:** Pages without prerender export run server-side on Cloudflare Workers (e.g., `/dashboard`, `/api/*`)

This architecture supports **Phase 1** (marketing site) and **Phase 2** (admin dashboard with GitHub OAuth + AWS SDK).

### Cloudflare Adapter

The `@astrojs/cloudflare` adapter enables:
- Deployment to Cloudflare Pages (global CDN)
- Server-side rendering via Cloudflare Workers (edge compute)
- Automatic static asset optimization

### Tailwind 4.x + Minecraft Theme

Tailwind 4.x uses CSS-based configuration. Custom colors are defined in `src/styles/global.css` using the `@theme` directive:

```css
@theme {
  --color-primary-grass: #7CBD2F;
  --color-primary-emerald: #50C878;
  --color-accent-diamond: #5DCCE3;
  --color-accent-gold: #FCEE4B;
  --color-secondary-stone: #7F7F7F;
  --color-bg-dark: #1A1A1A;
  /* ... more colors */
}
```

Use classes like `bg-primary-grass`, `text-accent-diamond`, `border-secondary-stone`, etc.

### Content Auto-Generation (Epic 2)

Content for pages (rules, features, etc.) will be auto-generated from markdown files in `/mc-server/docs/` using Astro Content Collections.

### Future: Admin Dashboard (Phase 2)

The `/dashboard` route is a placeholder for future admin features:
- GitHub OAuth authentication
- AWS SDK integration for EC2 server management
- Server start/stop controls
- Player whitelist management

## Environment Variables

This project uses environment variables for sensitive configuration. See [.env.example](.env.example) for the full list.

**Required variables:**

- `RESEND_API_KEY` - Resend API key for sending emails (Epic 4)
- `ADMIN_EMAIL` - Admin email address for form submissions
- `MC_SERVER_IP` - Minecraft server IP (e.g., `play.bhsmp.com`)
- `MC_SERVER_PORT` - Minecraft server port (default: `25565`)

**Optional variables (Phase 2):**

- `DISCORD_WEBHOOK_URL` - Discord webhook for notifications
- `GITHUB_CLIENT_ID` - GitHub OAuth client ID
- `GITHUB_CLIENT_SECRET` - GitHub OAuth client secret
- `AWS_ACCESS_KEY_ID` - AWS credentials for EC2 management
- `AWS_SECRET_ACCESS_KEY` - AWS credentials for EC2 management

**Setup:**

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Add your API keys and secrets (never commit `.env` to git!)

3. Restart the dev server to load new variables.

**Note:** Environment variables prefixed with `PUBLIC_` are exposed to the browser. Use sparingly for sensitive data.

## Deployment

### Cloudflare Pages

The site is deployed to **Cloudflare Pages** (configured in Epic 5).

**Build settings:**
- Build command: `npm run build`
- Build output directory: `dist`
- Node.js version: 18+

**Environment variables** are configured in the Cloudflare Pages dashboard (not in `.env`).

**Deployment:**

- **Automatic:** Pushes to `main` branch trigger automatic deployments
- **Manual:** Use Wrangler CLI:
  ```bash
  npx wrangler pages deploy dist
  ```

More details on deployment will be added in **Epic 5: Deployment & Production**.

## Contributing

### Development Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Follow existing code style (TypeScript, Tailwind)
   - Test locally with `npm run dev`
   - Run type check: `npm run check`

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat: description of your changes"
   ```

4. **Push and create a Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style Conventions

- **TypeScript:** Strict mode enabled; use type annotations for function params and returns
- **Tailwind:** Use utility classes; avoid custom CSS unless necessary
- **Astro Components:** Use `.astro` files for pages/components; use frontmatter for logic
- **File Naming:** Use `kebab-case` for files (e.g., `request-access.ts`, `BaseLayout.astro`)

### Project Phases

- **Epic 1: Site Foundation** (current) - Astro + Tailwind + TypeScript setup
- **Epic 2: Content System** - Auto-generate content from markdown docs
- **Epic 3: Pages & Components** - Build marketing pages (home, about, rules, etc.)
- **Epic 4: Form & API Integration** - Request access form with email submission
- **Epic 5: Deployment & Production** - Deploy to Cloudflare Pages
- **Phase 2:** Admin dashboard with GitHub OAuth + AWS SDK (future)

## Resources

- **PRD:** See [.docs/ASTRO-SITE-PRD.md](.docs/ASTRO-SITE-PRD.md) for full product requirements
- **Astro Docs:** https://docs.astro.build/
- **Cloudflare Pages:** https://developers.cloudflare.com/pages/
- **Tailwind CSS:** https://tailwindcss.com/

---

**Built for the BlockHaven Minecraft community**
