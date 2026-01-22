---
spec_id: 02
story_id: 02
epic_id: 002
title: Content Data Structures & TypeScript Types
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 02: Content Data Structures & TypeScript Types

## Overview

**User story:** .storyline/stories/epic-002/story-02-data-structures-typescript-types.md

**Goal:** Create TypeScript interfaces and data files for worlds, features, and rules with complete BlockHaven content.

**Approach:** Define strong TypeScript types, create data files with all 6 worlds, 6+ features, and 10-15 rules populated from WEB-COMPLETE-PLAN.md.

## Files to Create

```
src/types/world.ts
src/types/rank.ts (placeholder for future)
src/data/worlds.ts
src/data/features.ts
src/data/rules.ts
```

## Implementation Details

### types/world.ts
```typescript
export type WorldType = 'survival' | 'creative' | 'spawn';
export type Difficulty = 'Easy' | 'Normal' | 'Hard' | 'Peaceful';

export interface World {
  id: string;
  displayName: string;
  type: WorldType;
  difficulty: Difficulty;
  seed?: string;
  description: string;
  longDescription: string;
  image: string;
  features: string[];
}

export interface Feature {
  icon: string; // lucide-react icon name
  title: string;
  description: string;
}

export interface Rule {
  id: number;
  title: string;
  description: string;
  examples?: string[];
}
```

### types/rank.ts (placeholder)
```typescript
// Placeholder for future rank system (Epic 003+)
export interface Rank {
  id: string;
  name: string;
  color: string;
  permissions: string[];
}
```

### data/worlds.ts
```typescript
import { World } from '@/types/world';

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
  {
    id: 'survival_normal',
    displayName: 'SMP_Ravine',
    type: 'survival',
    difficulty: 'Normal',
    seed: '3637875498346583129',
    description: 'Challenging ravines and caves for the balanced survival experience.',
    longDescription: 'SMP_Ravine offers a balanced Minecraft experience with dramatic ravines, extensive cave systems, and varied terrain. Normal difficulty provides standard mob spawning and damage, creating an authentic survival challenge. Great for players who want traditional Minecraft gameplay.',
    image: '/worlds/smp_ravine.png',
    features: [
      'Normal difficulty with standard gameplay',
      'Massive ravines and cave systems',
      'Rich ore deposits for mining',
      'Shared inventory with other survival worlds',
      'Balanced challenge for all players',
    ],
  },
  {
    id: 'survival_hard',
    displayName: 'SMP_Cliffs',
    type: 'survival',
    difficulty: 'Hard',
    seed: '7472843923982741890',
    description: 'Extreme mountains and cliffs for the ultimate survival challenge.',
    longDescription: 'SMP_Cliffs is for experienced players seeking the ultimate challenge. Towering mountain ranges, deep valleys, and hard difficulty create a true test of survival skills. Hostile mobs deal more damage and spawn more frequently. Only the most skilled players thrive here.',
    image: '/worlds/smp_cliffs.png',
    features: [
      'Hard difficulty for expert players',
      'Extreme mountain terrain',
      'Increased mob spawning and damage',
      'Shared inventory with other survival worlds',
      'Ultimate survival challenge',
    ],
  },
  {
    id: 'creative_plots',
    displayName: 'Creative_Plots',
    type: 'creative',
    difficulty: 'Peaceful',
    description: 'Flat creative plots for focused building projects.',
    longDescription: 'Creative_Plots provides flat 100x100 plots perfect for building projects without terrain interference. Each player gets their own plot with full creative mode access. Ideal for redstone contraptions, architectural projects, or practicing builds before constructing in survival.',
    image: '/worlds/creative_plots.png',
    features: [
      'Peaceful difficulty - no mobs',
      'Flat 100x100 plots per player',
      'Full creative mode access',
      'Perfect for redstone builds',
      'Practice builds risk-free',
    ],
  },
  {
    id: 'creative_hills',
    displayName: 'Creative_Hills',
    type: 'creative',
    difficulty: 'Peaceful',
    description: 'Natural terrain creative world for organic building.',
    longDescription: 'Creative_Hills offers natural terrain generation for players who want to build with the landscape. Full creative mode access with realistic hills, valleys, and rivers. Perfect for landscaping projects, terraforming, or builds that integrate with natural terrain.',
    image: '/worlds/creative_hills.png',
    features: [
      'Peaceful difficulty - no mobs',
      'Natural terrain generation',
      'Full creative mode access',
      'Great for landscaping',
      'Build with the terrain',
    ],
  },
  {
    id: 'spawn_hub',
    displayName: 'Spawn_Hub',
    type: 'spawn',
    difficulty: 'Peaceful',
    description: 'Central hub connecting all worlds with portals.',
    longDescription: 'Spawn_Hub is the central nexus of BlockHaven, built in a void world with custom structures. Here you'll find portals to all other worlds, server information, rules, and community areas. This is where all players start their journey.',
    image: '/worlds/spawn_hub.png',
    features: [
      'Peaceful difficulty - no mobs',
      'Custom-built hub in void',
      'Portals to all worlds',
      'Server information displays',
      'Community gathering spaces',
    ],
  },
];
```

### data/features.ts
```typescript
import { Feature } from '@/types/world';

export const features: Feature[] = [
  {
    icon: 'Shield',
    title: 'Golden Shovel Land Claims',
    description: 'Protect your builds with our FREE golden shovel claiming system. No pay-to-claim, no premium barriers - everyone starts with 100 claim blocks and earns more just by playing. Use a golden shovel to claim land, trust friends to build together, and never worry about griefers destroying your creations.',
  },
  {
    icon: 'Users',
    title: 'Cross-Platform Play',
    description: 'Play from anywhere! Java Edition (PC/Mac/Linux) and Bedrock Edition (Mobile, Console, Windows 10) players can join together seamlessly.',
  },
  {
    icon: 'Coins',
    title: 'Economy System',
    description: 'Earn money by mining, farming, building, hunting, and more with Jobs Reborn. Use your earnings to trade with other players in our thriving economy.',
  },
  {
    icon: 'Heart',
    title: 'Family-Friendly',
    description: 'Strict chat moderation and welcoming community for players of all ages. Zero tolerance for griefing, bullying, or toxic behavior.',
  },
  {
    icon: 'Globe',
    title: '6 Unique Worlds',
    description: 'Explore 3 survival worlds (Easy, Normal, Hard), 2 creative worlds (Flat, Terrain), and a central spawn hub.',
  },
  {
    icon: 'Gamepad2',
    title: 'World Variety',
    description: 'Different difficulties for different playstyles. Shared inventory between survival worlds lets you choose your challenge.',
  },
];
```

### data/rules.ts
```typescript
import { Rule } from '@/types/world';

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
  {
    id: 2,
    title: 'No Griefing or Stealing',
    description: 'Do not destroy, modify, or take items from other players\' builds without permission. Use land claims to protect your property.',
    examples: [
      'Don\'t break blocks in claimed areas',
      'Don\'t steal from chests',
      'Don\'t kill other players\' animals',
    ],
  },
  {
    id: 3,
    title: 'No Inappropriate Language',
    description: 'Keep chat family-friendly. No swearing, sexual content, or offensive language.',
    examples: [
      'No profanity or bypassing filters',
      'No sexual or suggestive content',
      'No hate speech or slurs',
    ],
  },
  {
    id: 4,
    title: 'No Advertising Other Servers',
    description: 'Don\'t promote other Minecraft servers in chat or signs.',
  },
  {
    id: 5,
    title: 'Follow Staff Instructions',
    description: 'Listen to and respect server staff decisions. If you disagree with a decision, appeal privately.',
  },
  {
    id: 6,
    title: 'No Hacking or Cheating',
    description: 'Don\'t use hacked clients, x-ray texture packs, or exploit glitches.',
    examples: [
      'No fly hacks or speed hacks',
      'No x-ray or chest finder',
      'Report bugs instead of exploiting them',
    ],
  },
  {
    id: 7,
    title: 'Build Responsibly',
    description: 'Don\'t create offensive builds, lag machines, or structures that harm server performance.',
  },
  {
    id: 8,
    title: 'Respect Land Claims',
    description: 'Only build in your own claimed areas or with explicit permission from others.',
  },
  {
    id: 9,
    title: 'Keep Spawn Areas Clean',
    description: 'Don\'t leave random blocks, trees, or structures near spawn. Keep community areas tidy.',
  },
  {
    id: 10,
    title: 'Report Issues to Staff',
    description: 'If you see rule violations, report them to staff rather than taking action yourself.',
  },
];
```

## Testing Checklist

- [ ] All types compile without errors
- [ ] worlds array has 6 worlds (3 survival, 2 creative, 1 spawn)
- [ ] features array has 6+ features with Golden Shovel first
- [ ] rules array has 10+ rules
- [ ] All world seeds match WEB-COMPLETE-PLAN.md
- [ ] lucide-react icon names are valid (Shield, Users, Coins, Heart, Globe, Gamepad2)
- [ ] TypeScript autocompletion works in IDE

## Dependencies

**Must complete first:** Epic 001

**Enables:** Stories 03, 05, 06, 07, 09, 10

---

**Next step:** Run `/dev-story .storyline/specs/epic-002/spec-02-data-structures-types.md`
