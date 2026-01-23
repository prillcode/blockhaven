/**
 * Astro Content Collections Configuration
 * Defines schemas for type-safe content management
 */

import { defineCollection, z } from 'astro:content';

// World collection schema
const worldsCollection = defineCollection({
  type: 'data',
  schema: z.object({
    id: z.string(),
    displayName: z.string(),
    alias: z.string(),
    type: z.enum(['survival', 'creative', 'spawn']),
    difficulty: z.enum(['peaceful', 'easy', 'normal', 'hard']),
    seed: z.string().optional(),
    description: z.string(),
    features: z.array(z.string()),
    hasNether: z.boolean(),
    hasEnd: z.boolean(),
    order: z.number().optional(), // For display ordering
  }),
});

// Plugin collection schema
const pluginsCollection = defineCollection({
  type: 'data',
  schema: z.object({
    name: z.string(),
    slug: z.string(),
    category: z.enum([
      'cross-platform',
      'grief-prevention',
      'permissions',
      'economy',
      'world-management',
      'utilities',
    ]),
    purpose: z.string(),
    features: z.array(z.string()),
    docsUrl: z.string().optional(),
    commands: z
      .array(
        z.object({
          command: z.string(),
          description: z.string(),
          usage: z.string().optional(),
          aliases: z.array(z.string()).optional(),
        })
      )
      .optional(),
  }),
});

// Rules collection schema
const rulesCollection = defineCollection({
  type: 'data',
  schema: z.object({
    rules: z.array(
      z.object({
        id: z.number(),
        title: z.string(),
        description: z.string(),
      })
    ),
  }),
});

// Server info collection schema
const serverInfoCollection = defineCollection({
  type: 'data',
  schema: z.object({
    name: z.string(),
    tagline: z.string(),
    javaAddress: z.string(),
    javaPort: z.number(),
    bedrockAddress: z.string(),
    bedrockPort: z.number(),
    features: z.array(
      z.object({
        id: z.string(),
        title: z.string(),
        description: z.string(),
        icon: z.string().optional(),
      })
    ),
  }),
});

export const collections = {
  worlds: worldsCollection,
  plugins: pluginsCollection,
  rules: rulesCollection,
  'server-info': serverInfoCollection,
};
