---
spec_id: 03
story_id: 03
epic_id: 002
title: WorldCard Component
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 03: WorldCard Component

## Overview
Create WorldCard component displaying world info with screenshot, difficulty badge, description, and features.

## Files to Create
- `src/components/WorldCard.tsx`

## Implementation
```typescript
import { Link } from 'react-router-dom';
import { World } from '@/types/world';
import { Button, Card, Badge } from '@/components/ui';

interface WorldCardProps {
  world: World;
}

const difficultyColors: Record<string, 'success' | 'warning' | 'error' | 'default'> = {
  Easy: 'success',
  Normal: 'warning',
  Hard: 'error',
  Peaceful: 'default',
};

export function WorldCard({ world }: WorldCardProps) {
  return (
    <Card className="hover:scale-105 transition-transform duration-200">
      <img
        src={world.image}
        alt={world.displayName}
        className="w-full h-48 object-cover rounded-t-lg -m-6 mb-4"
      />
      <div className="flex items-center justify-between mb-2">
        <h3 className="text-xl font-bold">{world.displayName}</h3>
        <Badge variant={difficultyColors[world.difficulty]}>
          {world.difficulty}
        </Badge>
      </div>
      <p className="text-gray-600 dark:text-gray-300 mb-4">{world.description}</p>
      <ul className="space-y-1 mb-4">
        {world.features.slice(0, 3).map((feature, idx) => (
          <li key={idx} className="text-sm text-gray-500 dark:text-gray-400">
            • {feature}
          </li>
        ))}
      </ul>
      <Link to="/worlds">
        <Button variant="outline" className="w-full">
          Learn More
        </Button>
      </Link>
    </Card>
  );
}
```

## Dependencies
**Depends on:** Spec 01 (UI components), Spec 02 (World type)

---

**Next:** `/dev-story .storyline/specs/epic-002/spec-03-worldcard-component.md`
