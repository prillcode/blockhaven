---
spec_id: 09
story_id: 09
epic_id: 002
title: Worlds Detail Page
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 09: Worlds Detail Page

## Overview
Create detailed worlds page showing all 6 worlds organized by category.

## Files to Create
- `src/pages/Worlds.tsx`

## Implementation
```typescript
import { Helmet } from 'react-helmet-async';
import { worlds } from '@/data/worlds';
import { Card, Badge, Button } from '@/components/ui';

export function Worlds() {
  const survivalWorlds = worlds.filter(w => w.type === 'survival');
  const creativeWorlds = worlds.filter(w => w.type === 'creative');
  const spawnWorld = worlds.find(w => w.type === 'spawn');

  const copySeed = (seed: string) => {
    navigator.clipboard.writeText(seed);
    // TODO: Show toast (Epic 004)
  };

  return (
    <>
      <Helmet>
        <title>Worlds - BlockHaven</title>
        <meta name="description" content="Explore BlockHaven's 6 unique Minecraft worlds" />
      </Helmet>

      <div className="container mx-auto px-4 py-16">
        <h1 className="text-5xl font-bold text-center mb-12">Our Worlds</h1>

        {/* Survival Worlds */}
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-8">Survival Worlds</h2>
          <div className="space-y-8">
            {survivalWorlds.map((world) => (
              <Card key={world.id} className="grid md:grid-cols-2 gap-6">
                <img src={world.image} alt={world.displayName} className="rounded-lg" />
                <div>
                  <div className="flex items-center gap-3 mb-4">
                    <h3 className="text-2xl font-bold">{world.displayName}</h3>
                    <Badge variant={world.difficulty === 'Easy' ? 'success' : world.difficulty === 'Normal' ? 'warning' : 'error'}>
                      {world.difficulty}
                    </Badge>
                  </div>
                  <p className="mb-4">{world.longDescription}</p>
                  {world.seed && (
                    <div className="mb-4">
                      <p className="text-sm text-gray-500 mb-1">Seed:</p>
                      <code className="text-sm bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded">{world.seed}</code>
                      <Button size="sm" variant="ghost" onClick={() => copySeed(world.seed!)}>Copy</Button>
                    </div>
                  )}
                  <ul className="space-y-1">
                    {world.features.map((f, i) => (
                      <li key={i} className="text-sm">• {f}</li>
                    ))}
                  </ul>
                </div>
              </Card>
            ))}
          </div>
        </section>

        {/* Creative & Spawn sections similar structure */}
      </div>
    </>
  );
}
```

## Dependencies
**Depends on:** Specs 01, 02

---

**Next:** `/dev-story .storyline/specs/epic-002/spec-09-worlds-detail-page.md`
