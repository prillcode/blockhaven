# Content Collections

This directory is for Astro Content Collections (Epic 2).

Content Collections provide type-safe access to markdown/MDX content with:
- Schema validation
- Type inference
- Query utilities

## Planned Collections

- `worlds/` - World descriptions and details
- `rules/` - Server rules and guidelines
- `features/` - Feature descriptions

## Usage

```typescript
import { getCollection } from 'astro:content';

const worlds = await getCollection('worlds');
```

See [Astro Content Collections docs](https://docs.astro.build/en/guides/content-collections/) for more.
