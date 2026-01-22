# BlockHaven Marketing Website - Product Requirements Document

**Document Type:** Product Requirements Document (PRD)
**Project:** BlockHaven Astro Marketing Website
**Version:** 1.0
**Date:** January 22, 2026
**Status:** Draft - Ready for Epic Creation
**Owner:** Aaron Prill
**Stakeholders:** BlockHaven Server Administrators, Extended Family, Friends

---

## Executive Summary

BlockHaven is transitioning from a planned React-based marketing website to a simpler, content-driven Astro static site that will be deployed on Cloudflare Pages. The server is moving to an **invite-only model** with whitelist functionality, making the primary goal of the website to:

1. **Inform** invited players about the server's features, worlds, and gameplay
2. **Capture requests** from extended family and friends who want to join
3. **Provide documentation** on how to connect and play

This website will serve as the public-facing presence for an invite-only, family-friendly Minecraft server, replacing the need for extensive marketing features with streamlined information and a request-to-play form.

---

## Problem Statement

### Current Situation
- BlockHaven has extensive planning documentation for a React-based marketing site (WEB-COMPLETE-PLAN.md)
- The server is now invite-only, making extensive marketing features unnecessary
- Server information is scattered across multiple markdown documents (README, PLUGINS.md, CREATED-WORLDS-FINAL.md)
- No centralized place for invited players to learn about the server before joining
- No mechanism to handle play requests from extended family and children's friends

### Desired Outcome
A lightweight, auto-generated Astro website that:
- Consolidates server information from existing markdown documentation
- Provides a professional, Minecraft-themed presence
- Includes a "Request to Play" form for handling whitelist applications
- Deploys easily to Cloudflare Pages with minimal maintenance
- Can be updated by simply editing markdown files and redeploying

---

## Goals & Success Metrics

### Primary Goals
1. **Launch a functioning website** within 1-2 weeks that serves as the central information hub
2. **Enable whitelist requests** via email form submissions
3. **Auto-generate content** from existing markdown documentation
4. **Deploy to Cloudflare Pages** with custom domain (bhsmp.com)

### Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to Deploy | < 2 weeks | Deployment date |
| Form Submissions | Track all requests | Email notifications |
| Page Load Speed | < 2 seconds | Lighthouse Performance Score 90+ |
| Content Accuracy | 100% sync with docs | Manual verification |
| Mobile Responsiveness | Works on all devices | Responsive design testing |
| Uptime | 99.9% | Cloudflare analytics |

---

## User Personas

### Persona 1: Extended Family Member
**Name:** Sarah (Aunt)
**Age:** 38
**Tech Comfort:** Medium
**Goal:** Learn about the server to decide if it's appropriate for her 10-year-old son

**Needs:**
- Clear explanation of what the server offers
- Family-friendly assurances (safety, moderation)
- Easy way to request access for her child
- Instructions on how to connect once approved

**Pain Points:**
- Doesn't understand Minecraft jargon
- Wants assurance this is safe for kids
- Needs step-by-step connection instructions

---

### Persona 2: Teen Friend of Player
**Name:** Jake
**Age:** 14
**Tech Comfort:** High
**Goal:** Join his friend's Minecraft server to play together

**Needs:**
- Server features (worlds, plugins, economy)
- How to request access
- Server rules
- Cool factor - wants to know if the server has interesting features

**Pain Points:**
- Impatient - needs quick information
- Wants to know what makes this server special
- Mobile-first (uses phone for everything)

---

### Persona 3: Server Administrator (You)
**Name:** Aaron
**Goal:** Maintain accurate server information with minimal effort

**Needs:**
- Auto-generation of content from docs
- Easy to update (edit markdown, redeploy)
- Email notifications for play requests
- Professional appearance for family audience

**Pain Points:**
- Limited time for web maintenance
- Documentation lives in multiple files
- Needs to vet all whitelist requests manually

---

## User Stories

### Must Have (P0)
1. **As a visitor**, I want to see what BlockHaven offers so I can decide if I want to play
2. **As a parent**, I want to verify this is family-friendly so I feel safe letting my child play
3. **As a prospective player**, I want to request access to the server so I can join
4. **As the admin**, I want to receive email notifications of play requests so I can process whitelist applications
5. **As a visitor**, I want to see how to connect to the server so I can join after being whitelisted
6. **As a visitor**, I want to learn about the 6 different worlds so I know what gameplay options exist
7. **As a visitor**, I want to understand the server rules so I know what's expected
8. **As the admin**, I want content to auto-generate from docs so I don't manually duplicate information

### Should Have (P1)
9. **As a visitor**, I want to see the server status (online/offline) so I know if it's currently playable
10. **As a visitor**, I want to read about the plugins (land claims, economy, jobs) so I understand the features
11. **As a mobile user**, I want the site to work perfectly on my phone so I can browse on any device
12. **As a visitor**, I want a dark/light theme toggle so I can read comfortably

### Could Have (P2)
13. **As a visitor**, I want to see screenshots of the worlds so I can visualize the server
14. **As a visitor**, I want a FAQ section so I can find answers to common questions
15. **As the admin**, I want basic analytics so I can see how many people visit the site

---

## Features & Requirements

### Feature 1: Auto-Generated Content from Markdown
**Priority:** P0 (Must Have)
**Description:** The website should automatically generate pages from existing markdown files in the repository.

**Source Documents:**
- `/README.md` - Server overview, features, connection instructions
- `/mc-server/docs/PLUGINS.md` - Plugin stack and descriptions
- `/mc-server/docs/PLUGINS-QUICK-REF.md` - Player-facing commands
- `/mc-server/docs/CREATED-WORLDS-FINAL.md` - World configuration and details

**Requirements:**
- Parse markdown files during build process
- Transform content into Astro pages/components
- Maintain formatting (headers, lists, code blocks)
- Extract structured data (worlds list, features list, plugins list)
- Support frontmatter for metadata

**Acceptance Criteria:**
- [ ] Content from README.md appears on homepage
- [ ] Worlds from CREATED-WORLDS-FINAL.md render as individual cards/sections
- [ ] Plugins from PLUGINS.md display with descriptions
- [ ] Player commands from PLUGINS-QUICK-REF.md are formatted nicely
- [ ] Updates to markdown files reflect in rebuilt site

---

### Feature 2: Request to Play Form
**Priority:** P0 (Must Have)
**Description:** A contact form that allows prospective players to request whitelist access, sending notifications to the admin.

**Form Fields:**
- Name (required)
- Minecraft Username (required) - Both Java and Bedrock
- Email (required, validated)
- Age (optional, but helpful for family server context)
- Relationship to existing player (optional) - "I'm [player]'s friend/cousin/etc."
- Why do you want to play? (optional textarea)

**Backend:**
- Use Resend API for email delivery (free tier: 3,000 emails/month)
- Environment variable for Resend API key
- Environment variable for admin email recipient
- Rate limiting: 3 submissions per 15 minutes per IP (prevent spam)

**Email Format:**
```
Subject: New BlockHaven Whitelist Request

Name: [Name]
Minecraft Username: [Username]
Email: [Email]
Age: [Age]
Connection: [Relationship to existing player]

Message:
[Why do you want to play?]

---
Submitted: [Timestamp]
IP: [IP Address] (for spam prevention)
```

**Acceptance Criteria:**
- [ ] Form validates all required fields
- [ ] Form prevents submission with invalid email
- [ ] Form shows loading state during submission
- [ ] Success message displays after submission
- [ ] Error message displays if submission fails
- [ ] Admin receives email notification
- [ ] Rate limiting prevents spam
- [ ] Form is accessible (ARIA labels, keyboard navigation)
- [ ] Form works on mobile devices

---

### Feature 3: Server Information Pages
**Priority:** P0 (Must Have)
**Description:** Core pages that provide essential information about the server.

**Pages:**
1. **Home (`/`)** - Overview, features, CTA to request access
2. **Worlds (`/worlds`)** - Detailed information about all 6 worlds
3. **Rules (`/rules`)** - Server rules and expectations
4. **Plugins (`/plugins`)** - Plugin descriptions and player commands
5. **How to Connect (`/connect`)** - Step-by-step connection instructions
6. **Request Access (`/request`)** - Whitelist request form

**Content Requirements:**
- Home: Hero section, feature highlights, world preview, request access CTA
- Worlds:
  - Survival: SMP_Plains (Easy), SMP_Ravine (Normal), SMP_Cliffs (Hard)
  - Creative: Creative_Plots (Flat), Creative_Hills (Terrain)
  - Spawn: Spawn_Hub (Void)
  - Each world: description, seed, difficulty, features, screenshots
- Rules: Family-friendly policy, general rules, land claims, economy, consequences
- Plugins: UltimateLandClaim (golden shovel), Jobs Reborn, Geyser/Floodgate, etc.
- Connect: Java Edition instructions, Bedrock Edition instructions, troubleshooting
- Request: Form with clear expectations about whitelist process

**Acceptance Criteria:**
- [ ] All 6 pages are navigable
- [ ] Content is accurate and matches source docs
- [ ] Pages are responsive (mobile, tablet, desktop)
- [ ] Clear navigation between pages
- [ ] Consistent header/footer on all pages

---

### Feature 4: Minecraft-Themed Design
**Priority:** P1 (Should Have)
**Description:** Visual design inspired by the Storyline site (https://storyline.apcode.dev) but with Minecraft color palette.

**Design System:**
- **Color Palette:**
  - Primary: Grass Green (#7CBD2F) / Emerald Green (#50C878)
  - Secondary: Stone Gray (#7F7F7F) / Dark Gray (#1A1A1A)
  - Accent: Diamond Blue (#5DCCE3) / Gold Yellow (#FCEE4B)
  - Background: Light (#F5F5F5) / Dark (#1A1A1A)
  - Text: Dark Gray (#2D2D2D) / Light Gray (#E5E5E5)

- **Typography:**
  - Headings: Bold, clear hierarchy
  - Body: Readable, 16-18px base size
  - Code blocks: Monospace for commands/IPs

- **Components:**
  - Cards for worlds/features
  - Badges for difficulty levels (Easy/Normal/Hard)
  - Buttons with hover states
  - Responsive navigation (hamburger on mobile)
  - Footer with server IP and quick links

**Reference:**
- Storyline site structure: https://storyline.apcode.dev
- Use similar layout/component patterns
- Adapt color scheme to Minecraft theme

**Acceptance Criteria:**
- [ ] Color palette applied consistently
- [ ] Typography hierarchy is clear
- [ ] Components are reusable
- [ ] Design is cohesive across all pages
- [ ] Dark/light mode toggle (optional P2)

---

### Feature 5: Server Status Widget
**Priority:** P1 (Should Have)
**Description:** Display real-time server status (online/offline, player count).

**Implementation Options:**
1. **Client-side fetch** to mcstatus.io API: `https://api.mcstatus.io/v2/status/java/play.bhsmp.com`
2. **Static status** - Update during build (less accurate but simpler)

**Display:**
- Online/Offline indicator (green/red dot)
- Player count: "X/100 players online"
- Server IP with copy button: `play.bhsmp.com`

**Recommended Approach:**
- Use client-side fetch for real-time data
- Fallback to "Status Unknown" if API fails
- Cache result for 30 seconds

**Acceptance Criteria:**
- [ ] Status displays correctly
- [ ] Player count updates
- [ ] Copy IP button works
- [ ] Handles offline server gracefully
- [ ] No CORS issues

---

### Feature 6: Responsive Design
**Priority:** P0 (Must Have)
**Description:** Website must work flawlessly on all device sizes.

**Breakpoints:**
- Mobile: 320px - 768px
- Tablet: 769px - 1024px
- Desktop: 1025px+

**Requirements:**
- Mobile-first CSS approach
- Touch-friendly buttons (min 44px tap target)
- Readable text on small screens
- Hamburger menu on mobile
- Collapsible sections for mobile
- Images scale appropriately

**Acceptance Criteria:**
- [ ] Site works on iPhone SE (smallest common screen)
- [ ] Site works on iPad
- [ ] Site works on desktop (1920x1080)
- [ ] Navigation adapts to screen size
- [ ] Forms are usable on mobile
- [ ] No horizontal scrolling
- [ ] Images don't overflow

---

## Technical Requirements

### Tech Stack
**Framework:** Astro 4.x (latest stable)
- Static site generation
- Markdown support out-of-the-box
- React/Vue/Svelte support for interactive components (if needed)
- Fast builds, optimized output

**Styling:** Tailwind CSS
- Utility-first CSS
- Minecraft-themed color palette (custom config)
- Responsive design utilities
- Dark mode support (class-based)

**Form Handling:** Resend API
- Email delivery service
- Free tier: 3,000 emails/month
- Simple REST API

**Deployment:** Cloudflare Pages
- Automatic builds on git push
- Global CDN
- Free SSL
- Unlimited bandwidth (free tier)
- Environment variables for secrets

**Content Sources:**
- `/README.md`
- `/mc-server/docs/PLUGINS.md`
- `/mc-server/docs/PLUGINS-QUICK-REF.md`
- `/mc-server/docs/CREATED-WORLDS-FINAL.md`

---

### Project Structure
```
/web/
├── .docs/                      # Documentation (this PRD)
│   └── ASTRO-SITE-PRD.md
├── archives/                   # Archived React plans
│   ├── README.md               # Explanation of archived content
│   └── WEB-COMPLETE-PLAN.md    # Original React plan (archived)
├── src/
│   ├── pages/                  # Astro pages (routes)
│   │   ├── index.astro         # Home page
│   │   ├── worlds.astro        # Worlds page
│   │   ├── rules.astro         # Rules page
│   │   ├── plugins.astro       # Plugins page
│   │   ├── connect.astro       # Connection instructions
│   │   └── request.astro       # Request access form
│   ├── layouts/                # Layout components
│   │   └── BaseLayout.astro    # Base layout (header, footer)
│   ├── components/             # Reusable components
│   │   ├── Header.astro        # Site header
│   │   ├── Footer.astro        # Site footer
│   │   ├── WorldCard.astro     # World display card
│   │   ├── FeatureCard.astro   # Feature display card
│   │   ├── ServerStatus.astro  # Server status widget
│   │   └── RequestForm.astro   # Request access form
│   ├── content/                # Content collections (parsed from docs)
│   │   ├── config.ts           # Content schema
│   │   ├── worlds/             # World data (generated from CREATED-WORLDS-FINAL.md)
│   │   └── plugins/            # Plugin data (generated from PLUGINS.md)
│   ├── lib/                    # Utility functions
│   │   ├── markdown-parser.ts  # Parse external markdown files
│   │   └── resend.ts           # Resend API integration
│   └── styles/                 # Global styles
│       └── global.css          # Tailwind imports + custom styles
├── public/                     # Static assets
│   ├── favicon.ico
│   ├── og-image.png            # Open Graph preview
│   └── screenshots/            # World screenshots (if available)
├── astro.config.mjs            # Astro configuration
├── tailwind.config.mjs         # Tailwind configuration
├── tsconfig.json               # TypeScript configuration
├── package.json                # Dependencies
├── .env.example                # Environment variables template
└── README.md                   # Web project README
```

---

### Environment Variables
```bash
# Resend API (for email form)
RESEND_API_KEY=re_xxxxxxxxxxxxx

# Admin email for whitelist requests
ADMIN_EMAIL=your-email@example.com

# Minecraft server info
MC_SERVER_IP=play.bhsmp.com
MC_SERVER_PORT=25565

# Optional: Discord webhook for notifications
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxx/xxx
```

---

### Dependencies
```json
{
  "dependencies": {
    "astro": "^4.0.0",
    "@astrojs/tailwind": "^5.0.0",
    "tailwindcss": "^3.4.0",
    "resend": "^3.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  }
}
```

---

## Content Requirements

### Content Extraction Strategy

#### From README.md
**Extract:**
- Server name: "BlockHaven"
- Tagline: "Family-Friendly Anti-Griefer Survival & Creative!"
- Server IP: Will be `play.bhsmp.com` after AWS deployment
- Key features overview
- Connection instructions

**Use For:**
- Homepage hero section
- Features grid on homepage
- Connection instructions page

---

#### From mc-server/docs/CREATED-WORLDS-FINAL.md
**Extract:**
- World names and aliases (e.g., survival_easy = SMP_Plains)
- World types (survival, creative, spawn)
- Difficulty levels
- Nether/End configurations
- World descriptions (needs to be authored if not present)

**Data Structure:**
```typescript
interface World {
  id: string
  displayName: string
  alias: string
  type: 'survival' | 'creative' | 'spawn'
  difficulty: 'easy' | 'normal' | 'hard' | 'peaceful'
  seed?: string
  description: string
  features: string[]
  hasNether: boolean
  hasEnd: boolean
}
```

**Use For:**
- Worlds page (detailed view)
- Homepage world preview cards
- World navigation

---

#### From mc-server/docs/PLUGINS.md
**Extract:**
- Plugin names
- Plugin purposes
- Key features per plugin
- Categories (Cross-Platform, Grief Prevention, Economy, etc.)

**Use For:**
- Plugins page
- Features grid on homepage

---

#### From mc-server/docs/PLUGINS-QUICK-REF.md
**Extract:**
- Player commands
- Command descriptions
- Usage examples

**Use For:**
- Plugins page (command reference section)
- Getting started guide

---

### Content to Author (New Content)

#### World Descriptions
Each world needs a 2-3 sentence description:

**SMP_Plains (Easy):**
"Peaceful plains biome perfect for new players and relaxed building. Easy difficulty means fewer hostile mobs and more time to focus on building your dream base. Great for beginners or players who prefer a calmer survival experience."

**SMP_Ravine (Normal):**
"Challenging terrain with ravines, cliffs, and caves to explore. Standard difficulty provides a balanced survival experience with regular mob spawns. Perfect for players who want a traditional Minecraft survival challenge."

**SMP_Cliffs (Hard):**
"Extreme terrain with towering cliffs, deep valleys, and dangerous caves. Hard difficulty with increased mob spawns for experienced players. Shared inventory with other survival worlds lets you bring your best gear when you're ready for the challenge."

**Creative_Plots (Flat):**
"Superflat world for building without limits. Claim a plot and build whatever you can imagine in creative mode. Perfect for architectural projects, redstone contraptions, or just experimenting with builds."

**Creative_Hills (Terrain):**
"Creative mode with natural terrain generation. Build in a realistic landscape with hills, rivers, and biomes. Great for players who want creative freedom but prefer natural terrain over flat plots."

**Spawn_Hub (Void):**
"Central hub world connecting all other worlds. Safe zone with portals to survival and creative worlds. Start here when you first join the server."

---

#### Server Rules (Condensed from planned React site)
1. **Be respectful to all players** - Treat everyone with kindness
2. **No griefing or stealing** - Respect other players' builds and items
3. **No inappropriate language** - Family-friendly environment
4. **No advertising other servers** - This is our community
5. **No hacking or cheating** - Play fair
6. **Follow staff instructions** - Admins and moderators are here to help
7. **Use land claims** - Protect your builds with the golden shovel
8. **No exploiting bugs** - Report bugs, don't abuse them
9. **Keep chat friendly** - No spam, arguments, or drama
10. **Have fun!** - This is a game, enjoy yourself

---

## Design Requirements

### Reference Site
**Base design on:** https://storyline.apcode.dev

**What to replicate:**
- Clean, modern layout
- Clear typography hierarchy
- Card-based component design
- Responsive navigation
- Simple, effective animations
- Fast load times
- Accessibility features

**What to change:**
- Color palette: Minecraft theme (greens, grays, blues)
- Content: Minecraft server focus
- Forms: Request access form instead of contact form

---

### Component Specifications

#### Header
- Logo/Site name: "BlockHaven"
- Navigation links: Home, Worlds, Rules, Plugins, Connect, Request Access
- Mobile: Hamburger menu
- Sticky header (optional)

#### Footer
- Server IP with copy button
- Quick links (all pages)
- "Built with Astro" badge
- Copyright: © 2026 BlockHaven

#### World Card
- World name
- Difficulty badge
- 2-3 sentence description
- Key features (bullet list)
- "Learn More" button → /worlds page

#### Feature Card
- Icon (Lucide icons or similar)
- Feature title
- 2-3 sentence description

#### Request Form
- See Feature 2 for fields
- Validation states
- Loading state
- Success/error messages

---

## Implementation Phases

### Phase 1: Project Setup (1-2 days)
**Tasks:**
- Create new Astro project in `/web` directory
- Install dependencies (Astro, Tailwind, Resend)
- Configure Tailwind with Minecraft colors
- Set up TypeScript
- Create basic project structure
- Archive old React plan to `/web/archives/`
- Set up Cloudflare Pages project

**Deliverables:**
- [ ] Astro project initialized
- [ ] Tailwind configured
- [ ] Project structure created
- [ ] Old plans archived
- [ ] README.md updated

---

### Phase 2: Content Extraction & Structure (2-3 days)
**Tasks:**
- Write markdown parser utility
- Extract data from README.md
- Extract world data from CREATED-WORLDS-FINAL.md
- Extract plugin data from PLUGINS.md
- Create content collections in Astro
- Define TypeScript types for content
- Author missing world descriptions
- Author rules content

**Deliverables:**
- [ ] Content parser working
- [ ] World data structured
- [ ] Plugin data structured
- [ ] Content collections defined
- [ ] All content authored

---

### Phase 3: Core Pages (3-4 days)
**Tasks:**
- Create BaseLayout component
- Build Header and Footer
- Create Home page with hero + features
- Create Worlds page with world cards
- Create Rules page
- Create Plugins page
- Create Connect page
- Test responsive design on all pages

**Deliverables:**
- [ ] All 6 pages created
- [ ] Navigation working
- [ ] Content displaying correctly
- [ ] Responsive on mobile/tablet/desktop

---

### Phase 4: Request Form & Email (2 days)
**Tasks:**
- Create RequestForm component
- Implement form validation
- Set up Resend API integration
- Create API route for form submission
- Add rate limiting
- Test email delivery
- Handle success/error states

**Deliverables:**
- [ ] Form validates input
- [ ] Form submits to API
- [ ] Email sent to admin
- [ ] Rate limiting works
- [ ] Error handling complete

---

### Phase 5: Polish & Deploy (1-2 days)
**Tasks:**
- Add Server Status widget (optional)
- Optimize images
- Add favicon and OG image
- Test accessibility
- Run Lighthouse audit
- Deploy to Cloudflare Pages
- Configure custom domain (bhsmp.com)
- Test production site
- Update Cloudflare DNS

**Deliverables:**
- [ ] Site deployed to Cloudflare Pages
- [ ] Custom domain configured
- [ ] DNS updated
- [ ] All features working in production
- [ ] Performance score 90+

---

## Risks & Mitigations

### Risk 1: Content Parsing Complexity
**Risk:** Markdown files may have inconsistent structure, making parsing difficult
**Impact:** Medium
**Likelihood:** Medium
**Mitigation:**
- Start with manual content extraction if parsing is too complex
- Use Astro's built-in markdown support
- Simplify source docs if needed

---

### Risk 2: Email Delivery Issues
**Risk:** Resend API may have rate limits or deliverability issues
**Impact:** High
**Likelihood:** Low
**Mitigation:**
- Test email delivery thoroughly before launch
- Add email address to Resend verified senders
- Have backup plan (Discord webhook or form to Google Sheets)

---

### Risk 3: Mobile Responsiveness
**Risk:** Complex layouts may not work well on small screens
**Impact:** Medium
**Likelihood:** Low
**Mitigation:**
- Mobile-first design approach
- Test on real devices
- Use Tailwind's responsive utilities
- Keep layouts simple

---

### Risk 4: Content Staleness
**Risk:** Website content may become outdated as server evolves
**Impact:** Low
**Likelihood:** Medium
**Mitigation:**
- Auto-generate from docs as much as possible
- Keep docs updated in repo
- Simple redeploy process (git push → auto-deploy)

---

## Success Criteria

The project is considered successful when:

1. ✅ Website is deployed to bhsmp.com via Cloudflare Pages
2. ✅ All 6 pages are live and functional
3. ✅ Request form sends emails to admin
4. ✅ Content accurately reflects server documentation
5. ✅ Site is responsive on mobile, tablet, and desktop
6. ✅ Lighthouse performance score is 90+
7. ✅ Admin can update content by editing markdown and redeploying

---

## Appendix

### Reference Documents
- [README.md](/home/aaronprill/projects/blockhaven/README.md) - Server overview
- [PLUGINS.md](/home/aaronprill/projects/blockhaven/mc-server/docs/PLUGINS.md) - Plugin stack
- [PLUGINS-QUICK-REF.md](/home/aaronprill/projects/blockhaven/mc-server/docs/PLUGINS-QUICK-REF.md) - Player commands
- [CREATED-WORLDS-FINAL.md](/home/aaronprill/projects/blockhaven/mc-server/docs/CREATED-WORLDS-FINAL.md) - World configuration
- [Original React Plan](/home/aaronprill/projects/blockhaven/web/archives/WEB-COMPLETE-PLAN.md) - Archived React plan

### Reference Sites
- Storyline site: https://storyline.apcode.dev
- Storyline repo: https://github.com/prillcode/storyline-web

### Related Tasks
- **Task 1:** AWS EC2 Deployment (DEPLOYMENT-PLAN.md)
- **Task 2:** This Astro Site (This PRD)

---

**Document Status:** Ready for Epic Creation
**Next Steps:** Run `/storyline:sl-epic-creator` with this PRD to generate epics
