---
spec_id: 04-05-06-07
story_id: 04, 05, 06, 07
epic_id: 002
title: Homepage Section Components (Hero, WorldsShowcase, FeaturesGrid, ServerRules, CallToAction)
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 04-05-06-07: Homepage Section Components

## Overview
Create 5 homepage section components that will be assembled in Home page.

## Files to Create
```
src/components/sections/Hero.tsx
src/components/sections/WorldsShowcase.tsx
src/components/sections/FeaturesGrid.tsx
src/components/sections/ServerRules.tsx
src/components/sections/CallToAction.tsx
```

## Implementation Summary

### Hero.tsx
```typescript
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui';

export function Hero() {
  return (
    <section className="py-20 bg-gradient-to-b from-minecraft-grass/20 to-transparent">
      <div className="container mx-auto px-4 text-center">
        <h1 className="text-5xl font-bold mb-4">Family-Friendly Anti-Griefer Survival & Creative!</h1>
        <p className="text-xl mb-6">Join BlockHaven's welcoming Minecraft community</p>
        <div className="flex justify-center items-center gap-4 mb-8">
          <code className="text-2xl font-mono bg-gray-100 dark:bg-gray-800 px-4 py-2 rounded">
            5.161.69.191:25565
          </code>
          <Button variant="outline">Copy IP</Button>
        </div>
        <Link to="/worlds">
          <Button size="lg">Explore Worlds</Button>
        </Link>
      </div>
    </section>
  );
}
```

### WorldsShowcase.tsx
```typescript
import { worlds } from '@/data/worlds';
import { WorldCard } from '@/components/WorldCard';

export function WorldsShowcase() {
  return (
    <section className="py-16 bg-gray-50 dark:bg-gray-900">
      <div className="container mx-auto px-4">
        <h2 className="text-4xl font-bold text-center mb-12">Explore Our 6 Unique Worlds</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {worlds.map((world) => (
            <WorldCard key={world.id} world={world} />
          ))}
        </div>
      </div>
    </section>
  );
}
```

### FeaturesGrid.tsx
```typescript
import { features } from '@/data/features';
import * as Icons from 'lucide-react';
import { Card } from '@/components/ui';

export function FeaturesGrid() {
  return (
    <section className="py-16">
      <div className="container mx-auto px-4">
        <h2 className="text-4xl font-bold text-center mb-12">Why Choose BlockHaven?</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, idx) => {
            const Icon = (Icons as any)[feature.icon];
            return (
              <Card key={idx}>
                <Icon className="w-12 h-12 text-primary-500 mb-4" />
                <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                <p className="text-gray-600 dark:text-gray-300">{feature.description}</p>
              </Card>
            );
          })}
        </div>
      </div>
    </section>
  );
}
```

### ServerRules.tsx
```typescript
import { Link } from 'react-router-dom';
import { rules } from '@/data/rules';
import { Button } from '@/components/ui';

export function ServerRules() {
  return (
    <section className="py-16 bg-gray-50 dark:bg-gray-900">
      <div className="container mx-auto px-4">
        <h2 className="text-4xl font-bold text-center mb-12">Server Rules</h2>
        <div className="max-w-2xl mx-auto space-y-4 mb-8">
          {rules.slice(0, 5).map((rule) => (
            <div key={rule.id} className="flex gap-3">
              <span className="font-bold text-primary-500">{rule.id}.</span>
              <div>
                <h3 className="font-semibold">{rule.title}</h3>
                <p className="text-sm text-gray-600 dark:text-gray-300">{rule.description}</p>
              </div>
            </div>
          ))}
        </div>
        <div className="text-center">
          <Link to="/rules">
            <Button variant="outline">View Full Rules</Button>
          </Link>
        </div>
      </div>
    </section>
  );
}
```

### CallToAction.tsx
```typescript
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui';

export function CallToAction() {
  return (
    <section className="py-20 bg-gradient-to-t from-minecraft-grass/20 to-transparent">
      <div className="container mx-auto px-4 text-center">
        <h2 className="text-4xl font-bold mb-4">Ready to Start Your Adventure?</h2>
        <p className="text-xl mb-8 text-gray-600 dark:text-gray-300">
          Join thousands of players in BlockHaven's family-friendly community
        </p>
        <div className="flex justify-center gap-4">
          <Link to="/worlds">
            <Button size="lg">Explore Worlds</Button>
          </Link>
          <Button size="lg" variant="outline">Copy Server IP</Button>
        </div>
      </div>
    </section>
  );
}
```

## Dependencies
**Depends on:** Specs 01, 02, 03

---

**Next:** `/dev-story .storyline/specs/epic-002/spec-04-05-06-07-homepage-sections.md`
