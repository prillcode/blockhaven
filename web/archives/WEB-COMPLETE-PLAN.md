# BlockHaven Marketing Website - Complete Implementation Plan

**Date**: January 10, 2026
**Project**: BlockHaven Minecraft Server Marketing Website
**Version**: 1.0
**Status**: Ready for Implementation

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Project Structure](#project-structure)
3. [Technology Stack](#technology-stack)
4. [Key Technical Decisions](#key-technical-decisions)
5. [Component Architecture](#component-architecture)
6. [Pages & Routing](#pages--routing)
7. [Data Structure](#data-structure)
8. [Implementation Phases](#implementation-phases)
9. [Critical Files to Create](#critical-files-to-create)
10. [Docker & Deployment](#docker--deployment)
11. [Verification Checklist](#verification-checklist)
12. [Timeline & Milestones](#timeline--milestones)

---

## Executive Summary

Building a modern, performant marketing website for BlockHaven Minecraft server to showcase its unique features and attract players.

### Core Objectives
- **Showcase 6 Unique Worlds** - Primary focus on world variety and gameplay options
- **Highlight Anti-Grief Protection** - Feature UltimateLandClaim's golden shovel system
- **Live Server Status** - Real-time player count and online status
- **Easy Connection** - One-click IP copy for seamless joining
- **Professional Design** - Modern, responsive, Minecraft-themed aesthetic

### Technology Stack
- **Framework**: Vite + React 19 + TypeScript
- **Styling**: Tailwind CSS v4 (with new Vite plugin)
- **Icons**: lucide-react (300+ modern icons)
- **Animations**: Framer Motion (smooth transitions)
- **Backend API**: Express.js (Node.js)
- **Deployment**: Self-hosted Docker on Hetzner VPS (alongside Minecraft server)

### Key Features
1. **Dark/Light Mode Toggle** - Persistent theme with system preference detection
2. **Live Server Status Widget** - Auto-refreshing player count, ping, online status
3. **Discord Contact Form** - Secure webhook integration for support
4. **Responsive Design** - Mobile-first, works on all devices
5. **SEO Optimized** - Meta tags, sitemap, Open Graph support

---

## Project Structure

```
/home/aaronprill/projects/blockhaven/web/
├── public/                         # Static assets (served as-is)
│   ├── favicon.ico                 # Site favicon
│   ├── server-icon.png             # BlockHaven logo
│   ├── og-image.png                # Social media preview image
│   ├── robots.txt                  # SEO robots file
│   ├── sitemap.xml                 # SEO sitemap
│   ├── manifest.json               # PWA manifest (optional)
│   └── worlds/                     # World screenshots
│       ├── smp_plains.png          # SMP_Plains (easy)
│       ├── smp_ravine.png          # SMP_Ravine (normal)
│       ├── smp_cliffs.png          # SMP_Cliffs (hard)
│       ├── creative_plots.png      # Creative_Plots (flat)
│       ├── creative_hills.png      # Creative_Hills (terrain)
│       └── spawn_hub.png           # Spawn_Hub (void)
│
├── src/                            # Application source code
│   ├── components/                 # React components
│   │   ├── layout/                 # Layout components
│   │   │   ├── Header.tsx          # Site header with nav + theme toggle
│   │   │   ├── Footer.tsx          # Site footer with links
│   │   │   └── Navigation.tsx      # Mobile-responsive navigation
│   │   ├── sections/               # Page section components
│   │   │   ├── Hero.tsx            # Landing hero with CTA
│   │   │   ├── WorldsShowcase.tsx  # 6 worlds grid
│   │   │   ├── FeaturesGrid.tsx    # Key features showcase
│   │   │   ├── ServerRules.tsx     # Family-friendly rules
│   │   │   └── CallToAction.tsx    # CTA section
│   │   ├── widgets/                # Interactive widgets
│   │   │   ├── ServerStatus.tsx    # Live server status
│   │   │   ├── ContactForm.tsx     # Discord webhook form
│   │   │   ├── ThemeToggle.tsx     # Dark/light mode switch
│   │   │   └── CopyIPButton.tsx    # Copy server IP button
│   │   ├── ui/                     # Reusable UI components
│   │   │   ├── Button.tsx          # Button component
│   │   │   ├── Card.tsx            # Card wrapper
│   │   │   ├── Badge.tsx           # Status badge
│   │   │   ├── Input.tsx           # Form input
│   │   │   ├── Textarea.tsx        # Form textarea
│   │   │   ├── Toast.tsx           # Toast notification
│   │   │   └── LoadingSpinner.tsx  # Loading state
│   │   └── WorldCard.tsx           # Individual world card
│   │
│   ├── pages/                      # Route pages
│   │   ├── Home.tsx                # Homepage
│   │   ├── Worlds.tsx              # Worlds detail page
│   │   ├── Rules.tsx               # Server rules page
│   │   └── Contact.tsx             # Contact/support page
│   │
│   ├── hooks/                      # Custom React hooks
│   │   ├── useServerStatus.ts      # Server status polling
│   │   ├── useTheme.ts             # Theme management
│   │   ├── useLocalStorage.ts      # localStorage wrapper
│   │   └── useToast.ts             # Toast notifications
│   │
│   ├── contexts/                   # React contexts
│   │   └── ThemeContext.tsx        # Theme provider
│   │
│   ├── data/                       # Static data
│   │   ├── worlds.ts               # World information
│   │   ├── features.ts             # Server features
│   │   └── rules.ts                # Server rules
│   │
│   ├── lib/                        # Utility libraries
│   │   ├── minecraft-api.ts        # Minecraft server queries
│   │   ├── discord-webhook.ts      # Discord integration
│   │   └── utils.ts                # Helper functions
│   │
│   ├── types/                      # TypeScript types
│   │   ├── server.ts               # Server status types
│   │   ├── world.ts                # World data types
│   │   └── rank.ts                 # Rank types (future)
│   │
│   ├── styles/                     # Global styles
│   │   └── index.css               # Tailwind imports + global CSS
│   │
│   ├── App.tsx                     # Root component + routing
│   ├── main.tsx                    # Entry point
│   └── vite-env.d.ts               # Vite type definitions
│
├── api/                            # Backend Express.js API
│   ├── src/
│   │   ├── index.ts                # API server entry point
│   │   ├── routes/
│   │   │   ├── status.ts           # Server status endpoint
│   │   │   └── contact.ts          # Contact form endpoint
│   │   ├── middleware/
│   │   │   └── rate-limit.ts       # Rate limiting
│   │   └── utils/
│   │       └── cache.ts            # Caching utility
│   ├── package.json                # API dependencies
│   ├── tsconfig.json               # API TypeScript config
│   └── Dockerfile                  # API container
│
├── nginx/                          # Nginx configuration
│   └── nginx.conf                  # Production nginx config
│
├── index.html                      # HTML entry point
├── package.json                    # Dependencies & scripts
├── package-lock.json               # Lock file
├── tsconfig.json                   # TypeScript configuration
├── tsconfig.node.json              # TypeScript for Vite config
├── vite.config.ts                  # Vite configuration
├── tailwind.config.js              # Tailwind CSS configuration
├── postcss.config.js               # PostCSS configuration
├── .eslintrc.json                  # ESLint rules
├── .env.example                    # Environment variables template
├── .env                            # Local environment (gitignored)
├── .gitignore                      # Git ignore rules
├── .dockerignore                   # Docker ignore rules
├── Dockerfile                      # Frontend container
├── docker-compose.yml              # Docker services
└── README.md                       # Project documentation
```

---

## Technology Stack

### Frontend
- **React 19** - Latest React with concurrent rendering and improved performance
- **TypeScript 5.7** - Type safety and modern ECMAScript features
- **Vite 6.0** - Fast build tool with HMR (Hot Module Replacement)
- **Tailwind CSS v4** - Utility-first CSS framework with new Vite plugin
- **React Router v7** - Client-side routing for SPA
- **lucide-react** - Modern icon library (replaces react-icons)
- **Framer Motion 12** - Smooth animations and transitions
- **clsx + tailwind-merge** - Conditional className utilities

### Backend
- **Node.js 20** - JavaScript runtime
- **Express.js** - Minimal web framework
- **TypeScript** - Type-safe backend code
- **mcstatus.io API** - Minecraft server status queries (minecraft-server-util is deprecated)

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Nginx** - Production web server and reverse proxy
- **Certbot** - SSL certificate management (Let's Encrypt)

---

## Key Technical Decisions

### 1. Separate Docker Compose Architecture

**Decision**: Create separate `docker-compose.yml` in `/web/` directory (independent from Minecraft server)

**Rationale**:
- **Separation of Concerns** - Web and Minecraft server are independent services
- **Independent Scaling** - Can restart web without affecting Minecraft server
- **Simpler Management** - Easier to debug and maintain separately
- **DokPloy Compatibility** - Each service can have its own DokPloy project

**Services**:
- `web` - Nginx serving React SPA (port 80)
- `web-api` - Express.js backend for server status + contact form (port 3001)

---

### 2. Server Status Implementation

**Decision**: Backend API route using mcstatus.io API with 30-second caching

**Rationale**:
- **CORS Avoidance** - Direct browser queries fail due to CORS restrictions
- **Security** - Don't expose server IP directly in client-side code
- **Performance** - Backend caching reduces server load (30s cache TTL)
- **Reliability** - Better error handling and retry logic
- **Deprecated Package** - `minecraft-server-util` is deprecated as of 2026

**Implementation**:
```
Client → Frontend (React) → Backend API (/api/server-status) → mcstatus.io API → Minecraft Server (5.161.69.191:25565)
```

**Endpoint**: `GET /api/server-status`
```json
{
  "online": true,
  "players": { "online": 12, "max": 100 },
  "version": "1.21.11",
  "latency": 45
}
```

---

### 3. Contact Form Integration

**Decision**: Backend proxy to Discord webhook (never expose webhook URL to client)

**Rationale**:
- **Security** - Webhook URL is sensitive; must not be in client-side code
- **Rate Limiting** - Prevent spam at server level
- **Validation** - Server-side input validation
- **Logging** - Track submissions for debugging

**Implementation**:
```
Client → ContactForm → Backend API (/api/contact) → Discord Webhook → Discord Channel
```

**Endpoint**: `POST /api/contact`
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "subject": "Question about server",
  "message": "How do I claim land?"
}
```

---

### 4. Dark Mode Strategy

**Decision**: Context API + localStorage + Tailwind's class-based dark mode

**Rationale**:
- **No Prop Drilling** - Context API provides theme to any component
- **Persistent Theme** - localStorage saves user preference
- **System Preference** - Respects `prefers-color-scheme` on first visit
- **Standard Approach** - Tailwind v4's class-based dark mode is industry standard

**Implementation**:
```tsx
<html class="dark"> // or class="" for light mode
  <ThemeProvider>
    <App />
  </ThemeProvider>
</html>
```

---

### 5. Tailwind CSS v4 Setup

**Decision**: Use Tailwind v4 with new `@tailwindcss/vite` plugin

**Breaking Changes from v3**:
- Use `@import "tailwindcss"` instead of `@tailwind base/components/utilities`
- New Vite plugin: `@tailwindcss/vite` (replaces PostCSS plugin)
- Config file must be `.js` (not `.ts`)

**Minecraft-Themed Color Palette**:
```js
colors: {
  minecraft: {
    grass: '#7CBD2F',      // Minecraft grass green
    dirt: '#8C6239',       // Dirt brown
    stone: '#7F7F7F',      // Stone gray
    diamond: '#5DCCE3',    // Diamond blue
    gold: '#FCEE4B',       // Gold yellow
    redstone: '#FF0000',   // Redstone red
    emerald: '#50C878',    // Emerald green
    dark: '#1A1A1A',       // Dark background
  },
  primary: { /* green shades */ },
  secondary: { /* red shades */ },
}
```

---

## Component Architecture

### Layout Components

#### Header (`src/components/layout/Header.tsx`)
- **BlockHaven logo** (left) - links to homepage
- **Navigation links** (center) - Home, Worlds, Rules, Contact
- **Theme toggle** (right) - Sun/moon icon
- **Mobile menu** - Hamburger icon for mobile devices
- **Sticky positioning** - Stays at top on scroll

#### Footer (`src/components/layout/Footer.tsx`)
- **Server IP** - Prominently displayed with copy button
- **Quick Links** - Navigation to all pages
- **Social Media** - Discord, Twitter, GitHub (if applicable)
- **Copyright** - © 2026 BlockHaven
- **Built with** - "Built with Claude Code" badge

#### Navigation (`src/components/layout/Navigation.tsx`)
- **Desktop** - Horizontal menu with hover effects
- **Mobile** - Slide-in menu with backdrop
- **Active state** - Highlight current page
- **Accessible** - ARIA labels and keyboard navigation

---

### Section Components (Homepage)

#### Hero (`src/components/sections/Hero.tsx`)
**Purpose**: Eye-catching landing section

**Content**:
- **Tagline**: "Family-Friendly Anti-Griefer Survival & Creative!"
- **Server IP**: `5.161.69.191:25565` with copy button
- **Live Status Badge**: Green dot + "12/100 players online"
- **Primary CTA**: "Explore Worlds" button → /worlds page
- **Background**: Minecraft texture overlay with gradient

**Animations**:
- Text fade-in on load
- Status badge pulse animation
- CTA button hover effect

---

#### WorldsShowcase (`src/components/sections/WorldsShowcase.tsx`)
**Purpose**: Grid of 6 worlds (primary focus)

**Layout**: 3x2 grid (desktop), 1 column (mobile)

**Each WorldCard shows**:
- World screenshot
- Display name (e.g., "SMP_Plains")
- Difficulty badge (Easy, Normal, Hard, Peaceful)
- Short description (1-2 sentences)
- Key features (3-4 bullet points)
- "Learn More" link → /worlds page with anchor

---

#### FeaturesGrid (`src/components/sections/FeaturesGrid.tsx`)
**Purpose**: Highlight key server features

**Features to Showcase** (4-6 cards):

1. **Golden Shovel Land Claims** 🛡️
   - Title: "Golden Shovel Land Claims"
   - Description: "Protect your builds with our FREE golden shovel claiming system. No pay-to-claim, no premium barriers - everyone starts with 100 claim blocks and earns more just by playing. Use a golden shovel to claim land, trust friends to build together, and never worry about griefers destroying your creations."
   - Icon: Shield (lucide-react)

2. **Cross-Platform Play** 🌐
   - Description: "Play from anywhere! Java Edition (PC/Mac/Linux) and Bedrock Edition (Mobile, Console, Windows 10) players can join together."
   - Icon: Users

3. **Economy System** 💰
   - Description: "Earn money by mining, farming, building, hunting, and more with Jobs Reborn. Use your earnings to trade with other players."
   - Icon: Coins

4. **Family-Friendly** ❤️
   - Description: "Strict chat moderation and welcoming community for players of all ages. Zero tolerance for griefing, bullying, or toxic behavior."
   - Icon: Heart

5. **6 Unique Worlds** 🗺️
   - Description: "Explore 3 survival worlds (Easy, Normal, Hard), 2 creative worlds (Flat, Terrain), and a central spawn hub."
   - Icon: Globe

6. **World Variety** 🎮
   - Description: "Different difficulties for different playstyles. Shared inventory between survival worlds lets you choose your challenge."
   - Icon: Gamepad2

---

#### ServerRules (`src/components/sections/ServerRules.tsx`)
**Purpose**: Display family-friendly policies

**Rules** (brief version, link to /rules for full):
1. Be respectful to all players
2. No griefing or stealing
3. No inappropriate language
4. No advertising other servers
5. Follow staff instructions

---

#### CallToAction (`src/components/sections/CallToAction.tsx`)
**Purpose**: Final CTA to explore worlds or join

**Content**:
- **Heading**: "Ready to Start Your Adventure?"
- **Description**: "Join thousands of players in BlockHaven's family-friendly community"
- **Primary Button**: "Explore Worlds" → /worlds
- **Secondary Button**: "Copy Server IP" → Toast notification

---

### Widget Components

#### ServerStatus (`src/components/widgets/ServerStatus.tsx`)
**Purpose**: Live server status display

**Features**:
- **Online/Offline Indicator** - Green/red dot with animation
- **Player Count** - "12/100 players online"
- **Server Ping** - "45ms" (if available)
- **Auto-Refresh** - Polls every 30 seconds using `useServerStatus` hook
- **Loading State** - Skeleton loader while fetching
- **Error State** - "Unable to connect" if server is down

**Design**: Compact card suitable for header or sidebar

---

#### ContactForm (`src/components/widgets/ContactForm.tsx`)
**Purpose**: Support form sending to Discord webhook

**Fields**:
- Name (required)
- Email (required, validated)
- Subject (required)
- Message (required, min 10 chars)

**Features**:
- Client-side validation
- Server-side validation (backend)
- Loading state during submission
- Success toast: "Message sent successfully!"
- Error toast: "Failed to send message. Please try again."
- Rate limiting: Max 3 submissions per 10 minutes per IP

---

#### ThemeToggle (`src/components/widgets/ThemeToggle.tsx`)
**Purpose**: Dark/light mode switcher

**Features**:
- Sun icon (light mode) / Moon icon (dark mode)
- Smooth transition animation
- Persists to localStorage
- Respects system preference on first visit
- Accessible (ARIA labels)

---

#### CopyIPButton (`src/components/widgets/CopyIPButton.tsx`)
**Purpose**: Copy server IP with toast

**Features**:
- Click to copy `5.161.69.191:25565`
- Toast notification: "Server IP copied!"
- Icon: Copy (changes to Check after copy)
- Fallback for older browsers

---

### UI Components (Reusable)

#### Button (`src/components/ui/Button.tsx`)
**Variants**: primary, secondary, outline, ghost
**Sizes**: sm, md, lg
**Props**: loading, disabled, icon, fullWidth

#### Card (`src/components/ui/Card.tsx`)
**Wrapper component for content sections**

#### Badge (`src/components/ui/Badge.tsx`)
**Variants**: default, success, warning, error
**Use cases**: Difficulty badges, status indicators

#### Input (`src/components/ui/Input.tsx`)
**Form input with validation states**

#### Textarea (`src/components/ui/Textarea.tsx`)
**Form textarea with character count (optional)**

#### Toast (`src/components/ui/Toast.tsx`)
**Notification system**: success, error, info, warning

#### LoadingSpinner (`src/components/ui/LoadingSpinner.tsx`)
**Loading indicator**: small, medium, large

---

## Pages & Routing

### Page Structure

```tsx
// src/App.tsx
<BrowserRouter>
  <Routes>
    <Route path="/" element={<Layout />}>
      <Route index element={<Home />} />
      <Route path="worlds" element={<Worlds />} />
      <Route path="rules" element={<Rules />} />
      <Route path="contact" element={<Contact />} />
    </Route>
  </Routes>
</BrowserRouter>
```

---

### 1. Home (`/`)

**Sections** (in order):
1. Hero - Landing section with CTA
2. WorldsShowcase - Grid of 6 worlds
3. FeaturesGrid - Key features (anti-grief, cross-platform, etc.)
4. ServerRules - Brief rules overview
5. CallToAction - Final CTA

**Meta Tags**:
```html
<title>BlockHaven - Family-Friendly Minecraft Server</title>
<meta name="description" content="Join BlockHaven's family-friendly Minecraft server with anti-grief protection, 6 unique worlds, and cross-platform play. Free land claims, economy system, and welcoming community." />
```

---

### 2. Worlds (`/worlds`)

**Content**:
- **Introduction** - Overview of world variety
- **Survival Worlds Section**:
  - SMP_Plains (Easy) - Detailed description, seed, features, screenshot
  - SMP_Ravine (Normal) - Detailed description, seed, features, screenshot
  - SMP_Cliffs (Hard) - Detailed description, seed, features, screenshot
- **Creative Worlds Section**:
  - Creative_Plots (Flat) - Detailed description, features, screenshot
  - Creative_Hills (Terrain) - Detailed description, features, screenshot
- **Spawn Hub Section**:
  - Spawn_Hub (Void) - Central hub with portals
- **World Features**: Shared inventory, per-world XP, teleportation

**Interactive Elements**:
- Image galleries for each world
- Copy seed button for each world
- "Join Now" CTA at bottom

---

### 3. Rules (`/rules`)

**Content**:
1. **Family-Friendly Policy** - Zero tolerance for toxicity
2. **General Rules** (10-15 rules):
   - Be respectful
   - No griefing/stealing
   - No inappropriate language
   - No advertising
   - No hacking/cheating
   - Follow staff instructions
   - etc.
3. **Land Claims Rules** - How to claim, trust levels
4. **Economy Rules** - Fair play, no exploits
5. **Consequences** - Warning system, bans

**Design**: Numbered list with expandable sections

---

### 4. Contact (`/contact`)

**Content**:
- **Introduction** - How to reach us
- **ContactForm Widget** - Main contact form
- **Alternative Contact** - Discord invite link
- **FAQ Section** - Common questions
  - How do I join? (Copy IP instructions)
  - What version is the server? (1.21.11)
  - Can I play on mobile? (Yes, Bedrock support)
  - How do I claim land? (Golden shovel)

---

## Data Structure

### Worlds Data (`src/data/worlds.ts`)

```typescript
export interface World {
  id: string
  displayName: string
  type: 'survival' | 'creative' | 'spawn'
  difficulty: 'Easy' | 'Normal' | 'Hard' | 'Peaceful'
  seed?: string
  description: string
  longDescription: string
  image: string
  features: string[]
}

export const worlds: World[] = [
  {
    id: 'survival_easy',
    displayName: 'SMP_Plains',
    type: 'survival',
    difficulty: 'Easy',
    seed: '8377987092687320925',
    description: 'Peaceful plains biome perfect for new players and relaxed building.',
    longDescription: 'SMP_Plains is our easiest survival world, featuring gentle terrain with rolling plains, scattered villages, and abundant resources. Perfect for new players or those who want a more relaxed survival experience. The easy difficulty means fewer hostile mobs and more time to focus on building your dream base.',
    image: '/worlds/smp_plains.png',
    features: [
      'Easy difficulty with fewer hostile mobs',
      'Flat terrain ideal for building',
      'Villages nearby for trading',
      'Shared inventory with other survival worlds',
      'Perfect for beginners',
    ],
  },
  // ... more worlds
]
```

---

### Features Data (`src/data/features.ts`)

```typescript
export interface Feature {
  icon: string // lucide-react icon name
  title: string
  description: string
}

export const features: Feature[] = [
  {
    icon: 'Shield',
    title: 'Golden Shovel Land Claims',
    description: 'Protect your builds with our FREE golden shovel claiming system. No pay-to-claim, no premium barriers - everyone starts with 100 claim blocks and earns more just by playing.',
  },
  // ... more features
]
```

---

### Rules Data (`src/data/rules.ts`)

```typescript
export interface Rule {
  id: number
  title: string
  description: string
  examples?: string[]
}

export const rules: Rule[] = [
  {
    id: 1,
    title: 'Be Respectful to All Players',
    description: 'Treat everyone with kindness and respect, regardless of age, skill level, or background.',
    examples: [
      'Use friendly language in chat',
      'Help new players learn the ropes',
      'Avoid arguments and drama',
    ],
  },
  // ... more rules
]
```

---

## Implementation Phases

### Phase 1: Foundation (1-2 days)

**Tasks**:
1. Initialize Vite + React 19 + TypeScript project
   ```bash
   npm create vite@latest . -- --template react-ts
   ```
2. Install dependencies
   ```bash
   npm install react-router-dom clsx tailwind-merge lucide-react framer-motion
   npm install -D @tailwindcss/vite tailwindcss autoprefixer postcss
   ```
3. Configure Tailwind CSS v4 with Vite plugin
   - Create `tailwind.config.js` with Minecraft colors
   - Update `vite.config.ts` to include `@tailwindcss/vite`
   - Create `src/styles/index.css` with `@import "tailwindcss"`
4. Set up project structure (create directories)
5. Create base layout components (Header, Footer, Navigation)
6. Implement ThemeContext and dark mode toggle
7. Test theme persistence and system preference detection

**Deliverables**:
- ✅ Vite project initialized
- ✅ Tailwind CSS configured with custom theme
- ✅ Dark/light mode working
- ✅ Basic layout structure

---

### Phase 2: Content & UI (3-4 days)

**Tasks**:
1. Create data files:
   - `src/data/worlds.ts` - 6 worlds with descriptions
   - `src/data/features.ts` - Server features
   - `src/data/rules.ts` - Server rules
2. Build UI components library:
   - Button, Card, Badge, Input, Textarea, Toast, LoadingSpinner
3. Build WorldCard component
4. Implement section components:
   - Hero with "Explore Worlds" CTA
   - WorldsShowcase (grid of worlds)
   - FeaturesGrid (highlight UltimateLandClaim)
   - ServerRules
   - CallToAction
5. Create pages:
   - Home (assemble all sections)
   - Worlds (detailed world information)
   - Rules (full rules list)
   - Contact (contact form + FAQ)
6. Add React Router with 4 routes
7. Test responsive design (mobile, tablet, desktop)

**Deliverables**:
- ✅ All UI components built
- ✅ All pages created
- ✅ Routing working
- ✅ Responsive design verified

---

### Phase 3: Backend API (2 days)

**Tasks**:
1. Set up Express.js API server in `/web/api/`
   ```bash
   cd api
   npm init -y
   npm install express cors dotenv
   npm install -D typescript @types/node @types/express @types/cors ts-node nodemon
   ```
2. Implement server status endpoint:
   - Query mcstatus.io API
   - Cache results for 30 seconds
   - Error handling for offline servers
3. Implement contact form endpoint:
   - Validate input (name, email, subject, message)
   - Send to Discord webhook
   - Rate limiting (max 3 per 10 min per IP)
4. Test API endpoints locally
   ```bash
   curl http://localhost:3001/api/server-status
   curl -X POST http://localhost:3001/api/contact -d '{"name":"Test","email":"test@example.com","subject":"Test","message":"Hello"}'
   ```

**Deliverables**:
- ✅ Express.js API running
- ✅ Server status endpoint working
- ✅ Contact form endpoint working
- ✅ Rate limiting implemented

---

### Phase 4: Frontend Integration (2 days)

**Tasks**:
1. Create custom hooks:
   - `useServerStatus` - Polls `/api/server-status` every 30s
   - `useTheme` - Theme management (already done in Phase 1)
   - `useLocalStorage` - localStorage wrapper
   - `useToast` - Toast notifications
2. Build ServerStatus widget:
   - Display online/offline status
   - Show player count
   - Auto-refresh every 30s
3. Build ContactForm widget:
   - Form validation
   - Submit to `/api/contact`
   - Success/error toasts
4. Build CopyIPButton widget:
   - Copy server IP to clipboard
   - Show "Copied!" toast
5. Test all interactive features
6. Performance optimization:
   - Lazy load pages with React.lazy()
   - Optimize images (compress world screenshots)
   - Code splitting for vendor chunks

**Deliverables**:
- ✅ All hooks implemented
- ✅ ServerStatus widget working
- ✅ ContactForm widget working
- ✅ All features tested and working

---

### Phase 5: Docker & Deployment (2-3 days)

**Tasks**:
1. Create Dockerfile for frontend (multi-stage build)
   - Stage 1: Build React app
   - Stage 2: Serve with nginx
2. Create Dockerfile for backend API
3. Write nginx configuration:
   - Serve static files
   - Proxy `/api/*` to backend
   - Gzip compression
   - Cache headers for static assets
4. Create docker-compose.yml:
   - `web` service (nginx + React)
   - `web-api` service (Express.js)
   - Environment variables
   - Restart policies
5. Test Docker build locally:
   ```bash
   docker-compose build
   docker-compose up -d
   ```
6. Deploy to Hetzner VPS:
   - SCP files to VPS or git pull
   - Run docker-compose up -d
7. Set up VPS nginx reverse proxy:
   - bhsmp.com → web container (port 80)
   - Configure SSL with Certbot
   - HTTPS redirects
8. Configure DNS:
   - Add A records for bhsmp.com, www.bhsmp.com
9. Final testing:
   - Test all pages load
   - Test server status widget
   - Test contact form
   - Test dark mode persistence
   - Run Lighthouse audit

**Deliverables**:
- ✅ Docker images built
- ✅ docker-compose.yml configured
- ✅ Deployed to production VPS
- ✅ SSL certificates installed
- ✅ DNS configured
- ✅ All features working in production

---

## Critical Files to Create

### Configuration Files (9 files)

1. **package.json** - Dependencies and scripts
2. **tsconfig.json** - TypeScript configuration
3. **tsconfig.node.json** - TypeScript for Vite config
4. **vite.config.ts** - Vite + React + Tailwind v4 plugin
5. **tailwind.config.js** - Tailwind theme (Minecraft colors)
6. **postcss.config.js** - PostCSS configuration
7. **.eslintrc.json** - ESLint rules
8. **.env.example** - Environment variables template
9. **.gitignore** - Git ignore rules

---

### Source Code (35+ files)

**Entry**:
- index.html
- src/main.tsx
- src/App.tsx

**Styles**:
- src/styles/index.css

**Components** (21 files):
- Layout (3): Header, Footer, Navigation
- Sections (5): Hero, WorldsShowcase, FeaturesGrid, ServerRules, CallToAction
- Widgets (4): ServerStatus, ContactForm, ThemeToggle, CopyIPButton
- UI (8): Button, Card, Badge, Input, Textarea, Toast, LoadingSpinner
- WorldCard (1)

**Pages** (4 files):
- Home, Worlds, Rules, Contact

**Hooks** (4 files):
- useServerStatus, useTheme, useLocalStorage, useToast

**Contexts** (1 file):
- ThemeContext

**Data** (3 files):
- worlds, features, rules

**Types** (3 files):
- server, world, rank

**Lib** (3 files):
- minecraft-api, discord-webhook, utils

---

### Backend API (8 files)

1. **api/package.json** - API dependencies
2. **api/tsconfig.json** - API TypeScript config
3. **api/src/index.ts** - API entry point
4. **api/src/routes/status.ts** - Server status endpoint
5. **api/src/routes/contact.ts** - Contact form endpoint
6. **api/src/middleware/rate-limit.ts** - Rate limiting
7. **api/src/utils/cache.ts** - Caching utility
8. **api/Dockerfile** - API container

---

### Docker & Nginx (4 files)

1. **Dockerfile** - Frontend container (multi-stage)
2. **docker-compose.yml** - Services definition
3. **nginx/nginx.conf** - Production nginx config
4. **.dockerignore** - Docker ignore rules

---

### Public Assets (12 files)

1. **favicon.ico** - Site favicon
2. **server-icon.png** - BlockHaven logo
3. **og-image.png** - Social media preview
4. **worlds/smp_plains.png** - SMP_Plains screenshot
5. **worlds/smp_ravine.png** - SMP_Ravine screenshot
6. **worlds/smp_cliffs.png** - SMP_Cliffs screenshot
7. **worlds/creative_plots.png** - Creative_Plots screenshot
8. **worlds/creative_hills.png** - Creative_Hills screenshot
9. **worlds/spawn_hub.png** - Spawn_Hub screenshot
10. **robots.txt** - SEO robots file
11. **sitemap.xml** - SEO sitemap
12. **manifest.json** - PWA manifest (optional)

---

### VPS Configuration (1 file)

1. **/etc/nginx/sites-available/blockhaven** - Main nginx reverse proxy (on VPS)

---

**Total: ~75 files**

---

## Docker & Deployment

### Frontend Dockerfile (Multi-Stage Build)

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build for production
RUN npm run build

# Stage 2: Production
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

---

### Backend API Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 3001

CMD ["node", "dist/index.js"]
```

---

### docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: blockhaven-web
    restart: unless-stopped
    ports:
      - "80:80"
    networks:
      - blockhaven-network
    depends_on:
      - web-api
    labels:
      - "com.centurylinklabs.watchtower.enable=true"

  web-api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: blockhaven-web-api
    restart: unless-stopped
    environment:
      NODE_ENV: production
      DISCORD_WEBHOOK_URL: ${DISCORD_WEBHOOK_URL}
      MC_SERVER_HOST: ${MC_SERVER_HOST:-5.161.69.191}
      MC_SERVER_PORT: ${MC_SERVER_PORT:-25565}
    ports:
      - "3001:3001"
    networks:
      - blockhaven-network
    labels:
      - "com.centurylinklabs.watchtower.enable=true"

networks:
  blockhaven-network:
    driver: bridge
```

---

### nginx/nginx.conf (Container)

```nginx
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # SPA routing - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to backend service
    location /api/ {
        proxy_pass http://web-api:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

---

### VPS Nginx Reverse Proxy

**/etc/nginx/sites-available/blockhaven**:

```nginx
# Redirect www to non-www
server {
    listen 80;
    listen [::]:80;
    server_name www.bhsmp.com;
    return 301 https://bhsmp.com$request_uri;
}

# HTTP to HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name bhsmp.com;
    return 301 https://bhsmp.com$request_uri;
}

# Main website (bhsmp.com) - HTTPS
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name bhsmp.com;

    # SSL certificates (use Certbot for Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/bhsmp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bhsmp.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Proxy to web container
    location / {
        proxy_pass http://localhost:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

### Environment Variables

**.env.example**:

```bash
# Discord Webhook URL for contact form
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN

# Minecraft Server (for status queries)
MC_SERVER_HOST=5.161.69.191
MC_SERVER_PORT=25565

# Node environment
NODE_ENV=production
```

---

## Verification Checklist

### Local Development

- [ ] `npm run dev` starts successfully
- [ ] All pages render without errors
- [ ] Navigation works (clicking links)
- [ ] Dark/light mode toggle works
- [ ] Theme persists on page reload
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] All images load correctly

---

### Server Status Widget

- [ ] Displays "Loading..." initially
- [ ] Fetches and displays real server status
- [ ] Online/offline indicator is correct
- [ ] Player count displays correctly
- [ ] Updates every 30 seconds
- [ ] Handles offline server gracefully (error state)
- [ ] Ping displays in milliseconds

---

### Contact Form

- [ ] Form validation works (required fields)
- [ ] Email validation works (format check)
- [ ] Form submits successfully
- [ ] Discord webhook receives message with correct formatting
- [ ] Success toast displays: "Message sent successfully!"
- [ ] Form clears after submission
- [ ] Error handling works (network errors, webhook failures)
- [ ] Rate limiting prevents spam (max 3 per 10 min)

---

### Production Build

- [ ] `npm run build` completes without errors
- [ ] Build output is optimized (check bundle size < 500KB)
- [ ] `npm run preview` serves production build
- [ ] All assets load correctly in preview
- [ ] Environment variables are injected correctly

---

### Docker Deployment

- [ ] Docker images build successfully (`docker-compose build`)
- [ ] Containers start without errors (`docker-compose up -d`)
- [ ] Website accessible at `http://localhost:80`
- [ ] API accessible at `http://localhost:3001`
- [ ] Nginx serves static files correctly
- [ ] API proxy routes work (`/api/*` → web-api:3001)
- [ ] Containers restart on crash (`restart: unless-stopped`)

---

### Production VPS

- [ ] DNS A records resolve correctly
  - `nslookup bhsmp.com` → 5.161.69.191
  - `nslookup www.bhsmp.com` → 5.161.69.191
- [ ] SSL certificates installed (Let's Encrypt)
  - `https://bhsmp.com` loads with valid cert
- [ ] HTTPS redirects work
  - `http://bhsmp.com` → `https://bhsmp.com`
  - `https://www.bhsmp.com` → `https://bhsmp.com`
- [ ] Website loads at `https://bhsmp.com`
- [ ] Server status widget queries production Minecraft server
- [ ] Contact form sends to Discord
- [ ] Dark mode persists across sessions
- [ ] Performance (Lighthouse score 90+)
- [ ] Mobile responsiveness verified on real devices

---

### Monitoring & Analytics

- [ ] Set up UptimeRobot for uptime monitoring
- [ ] Configure Discord webhooks for error alerts (optional)
- [ ] Monitor nginx logs for traffic patterns
- [ ] Set up Google Analytics (optional)

---

## Timeline & Milestones

### Estimated Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Foundation | 1-2 days | Day 2 |
| Phase 2: Content & UI | 3-4 days | Day 6 |
| Phase 3: Backend API | 2 days | Day 8 |
| Phase 4: Integration | 2 days | Day 10 |
| Phase 5: Deployment | 2-3 days | Day 13 |

**Total: 10-14 days** for full implementation and production deployment

---

### Milestones

**Week 1**:
- ✅ Project initialized with Vite + React 19 + TypeScript
- ✅ Tailwind CSS v4 configured with Minecraft theme
- ✅ Dark/light mode working
- ✅ All UI components built
- ✅ All pages created

**Week 2**:
- ✅ Backend API running
- ✅ Server status endpoint working
- ✅ Contact form endpoint working
- ✅ All frontend integration complete
- ✅ Docker images built

**Week 3**:
- ✅ Deployed to production VPS
- ✅ SSL certificates installed
- ✅ DNS configured
- ✅ All features working in production
- ✅ Performance optimized (Lighthouse 90+)

---

## Final Implementation Summary

### Key Points

1. **No Monetization** - Remove all ranks/donation content from initial launch
2. **World Focus** - "Explore Worlds" is primary CTA - showcase 6 worlds as main attraction
3. **UltimateLandClaim** - Highlight golden shovel claiming system prominently in features
4. **Simplified Navigation** - 4 pages only (Home, Worlds, Rules, Contact)
5. **Modern Stack** - Vite + React 19 + Tailwind v4 + TypeScript

---

### Primary User Journey

1. User lands on homepage → sees "Explore Worlds" CTA
2. User clicks to Worlds page → learns about 6 different worlds
3. User is convinced → copies server IP and joins

---

### UltimateLandClaim Feature Copy

**Title**: "Golden Shovel Land Claims"

**Description**: "Protect your builds with our FREE golden shovel claiming system. No pay-to-claim, no premium barriers - everyone starts with 100 claim blocks and earns more just by playing. Use a golden shovel to claim land, trust friends to build together, and never worry about griefers destroying your creations."

**Icon**: Shield (from lucide-react)

---

### Server Information

- **Server IP**: `5.161.69.191:25565`
- **Version**: Paper 1.21.11
- **Platform**: Java + Bedrock (via Geyser)
- **Location**: Hetzner VPS (Germany)
- **Website**: https://bhsmp.com
- **Discord**: (To be added)

---

### Contact

For questions about this implementation plan, refer to the main project planning document:
- [/home/aaronprill/projects/blockhaven/blockhaven-planning-doc.md](../blockhaven-planning-doc.md)

---

**Plan Status**: ✅ Ready for Implementation
**Last Updated**: January 10, 2026
**Plan Version**: 1.0
