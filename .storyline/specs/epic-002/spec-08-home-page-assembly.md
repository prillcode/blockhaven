---
spec_id: 08
story_id: 08
epic_id: 002
title: Home Page Assembly
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 08: Home Page Assembly

## Overview
Assemble all homepage sections into complete Home page with SEO.

## Files to Create
- `src/pages/Home.tsx`

## Implementation
```typescript
import { Helmet } from 'react-helmet-async';
import { Hero, WorldsShowcase, FeaturesGrid, ServerRules, CallToAction } from '@/components/sections';

export function Home() {
  return (
    <>
      <Helmet>
        <title>BlockHaven - Family-Friendly Minecraft Server</title>
        <meta 
          name="description" 
          content="Join BlockHaven's family-friendly Minecraft server with anti-grief protection, 6 unique worlds, and cross-platform play. Free land claims, economy system, and welcoming community." 
        />
        <meta property="og:title" content="BlockHaven - Family-Friendly Minecraft Server" />
        <meta property="og:description" content="Join our family-friendly Minecraft community with 6 unique worlds" />
      </Helmet>
      
      <Hero />
      <WorldsShowcase />
      <FeaturesGrid />
      <ServerRules />
      <CallToAction />
    </>
  );
}
```

## Dependencies
**Depends on:** Spec 04-05-06-07 (all sections)
**Note:** Install `react-helmet-async` for SEO: `pnpm add react-helmet-async`

---

**Next:** `/dev-story .storyline/specs/epic-002/spec-08-home-page-assembly.md`
