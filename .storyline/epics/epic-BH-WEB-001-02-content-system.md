# Epic 2: Content System & Data Layer

**Epic ID:** BH-WEB-001-02
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-PRD.md

---

## Business Goal

Build an automated content system that extracts structured data from existing markdown documentation (README, PLUGINS, CREATED-WORLDS), eliminating manual content duplication and ensuring the website stays synchronized with server documentation through simple git commits and rebuilds.

## User Value

**Who Benefits:** Server administrators, content maintainers

**How They Benefit:**
- Updates to server docs automatically flow to website (no manual copying)
- Single source of truth for all server information
- Content changes require only markdown edits + redeploy (no code changes)
- Type-safe content with TypeScript interfaces prevents errors

## Success Criteria

- [ ] Markdown parser utility successfully extracts data from all 4 source docs
- [ ] Astro Content Collections defined for worlds and plugins
- [ ] TypeScript interfaces match PRD specifications (World, Plugin types)
- [ ] World descriptions authored for all 6 worlds
- [ ] Server rules content created
- [ ] Content builds without errors and is queryable in Astro pages
- [ ] Changes to source markdown files reflect in rebuilt site

## Scope

### In Scope
- Markdown parser utility (`lib/markdown-parser.ts`)
- Content Collections configuration (`content/config.ts`)
- Extract and structure world data from `mc-server/docs/CREATED-WORLDS-FINAL.md`
- Extract and structure plugin data from `mc-server/docs/PLUGINS.md`
- Extract player commands from `mc-server/docs/PLUGINS-QUICK-REF.md`
- Extract server overview from `README.md`
- Author world descriptions (6 worlds as specified in PRD)
- Author server rules content (10 rules as specified in PRD)
- TypeScript types for content (`World`, `Plugin`, `Command`, `Feature`)
- Content validation schemas (Zod or Astro's built-in validation)

### Out of Scope
- Building UI components to display content (Epic 3)
- Creating actual pages (Epic 3)
- Styling or design implementation (Epic 3)
- Form handling or API routes (Epic 4)

## Technical Notes

**Content Sources:**
1. `/README.md` → Server name, tagline, features, connection info
2. `/mc-server/docs/CREATED-WORLDS-FINAL.md` → World configuration
3. `/mc-server/docs/PLUGINS.md` → Plugin descriptions
4. `/mc-server/docs/PLUGINS-QUICK-REF.md` → Player commands

**TypeScript Interfaces (from PRD):**
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

interface Plugin {
  name: string
  category: string
  purpose: string
  features: string[]
}

interface Command {
  command: string
  description: string
  usage?: string
}
```

**Astro Content Collections:**
```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const worldsCollection = defineCollection({
  type: 'data',
  schema: z.object({
    id: z.string(),
    displayName: z.string(),
    alias: z.string(),
    type: z.enum(['survival', 'creative', 'spawn']),
    difficulty: z.enum(['easy', 'normal', 'hard', 'peaceful']),
    seed: z.string().optional(),
    description: z.string(),
    features: z.array(z.string()),
    hasNether: z.boolean(),
    hasEnd: z.boolean(),
  }),
});

export const collections = {
  worlds: worldsCollection,
  plugins: pluginsCollection,
};
```

## Dependencies

**Depends On:**
- Epic 1: Site Foundation & Infrastructure (need project structure and TypeScript)

**Blocks:**
- Epic 3: Core Pages & Components (need content to display)

## Risks & Mitigations

**Risk:** Markdown files have inconsistent structure
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Start with manual data extraction if parsing is complex; simplify source docs if needed

**Risk:** Content schema changes require code updates
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Keep schemas flexible with optional fields; document schema changes

## Acceptance Criteria

### Markdown Parser
- [ ] `lib/markdown-parser.ts` can read markdown files from `../mc-server/docs/`
- [ ] Parser extracts frontmatter metadata
- [ ] Parser handles headers, lists, code blocks
- [ ] Parser converts markdown to structured JSON

### Content Collections
- [ ] `content/config.ts` defines schemas for worlds and plugins
- [ ] Content validates against schemas on build
- [ ] Collections queryable via `getCollection('worlds')` and `getCollection('plugins')`

### World Data
- [ ] All 6 worlds structured as JSON/frontmatter files:
  - spawn (Spawn_Hub - Void)
  - survival_easy (SMP_Plains - Easy)
  - survival_normal (SMP_Ravine - Normal)
  - survival_hard (SMP_Cliffs - Hard)
  - creative_flat (Creative_Plots - Flat)
  - creative_terrain (Creative_Hills - Terrain)
- [ ] Each world includes description, features, nether/end status
- [ ] World descriptions match PRD specifications (2-3 sentences each)

### Plugin Data
- [ ] Plugin data extracted from PLUGINS.md
- [ ] Plugins categorized (Cross-Platform, Grief Prevention, Economy, etc.)
- [ ] Player commands extracted from PLUGINS-QUICK-REF.md
- [ ] Commands linked to relevant plugins

### Server Info
- [ ] Server name, tagline, IP extracted from README
- [ ] Key features list structured
- [ ] Connection instructions extracted

### Rules Content
- [ ] 10 server rules authored as per PRD
- [ ] Rules stored in content collection or static data file
- [ ] Rules accessible to pages

### Verification
- [ ] `npm run build` completes without content errors
- [ ] Content queryable in dev mode
- [ ] Type checking passes for all content
- [ ] Updates to source docs (README, PLUGINS, WORLDS) flow through to parsed data

## Related User Stories

From PRD:
- User Story 1: "As a visitor, I want to see what BlockHaven offers" (needs feature content)
- User Story 6: "As a visitor, I want to learn about the 6 different worlds" (needs world data)
- User Story 7: "As a visitor, I want to understand the server rules" (needs rules content)
- User Story 8: "As the admin, I want content to auto-generate from docs" (core goal of this epic)
- User Story 10: "As a visitor, I want to read about the plugins" (needs plugin data)

## Content to Author

### World Descriptions (from PRD)

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

### Server Rules (from PRD)

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

## Notes

- Content Collections are Astro's recommended approach for type-safe content
- Parser should be flexible enough to handle future markdown structure changes
- Consider using Astro's built-in markdown processing rather than a custom parser
- Content validation happens at build time, catching errors early

---

**Previous Epic:** Epic 1 - Site Foundation & Infrastructure
**Next Epic:** Epic 3 - Core Pages & Components
