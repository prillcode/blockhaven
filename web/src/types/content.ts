/**
 * Content Types for BlockHaven Website
 * TypeScript interfaces for type-safe content management
 */

// World types
export type WorldType = 'survival' | 'creative' | 'spawn';
export type Difficulty = 'peaceful' | 'easy' | 'normal' | 'hard';

export interface World {
  id: string;
  displayName: string;
  alias: string;
  type: WorldType;
  difficulty: Difficulty;
  seed?: string;
  description: string;
  features: string[];
  hasNether: boolean;
  hasEnd: boolean;
}

// Plugin types
export type PluginCategory =
  | 'cross-platform'
  | 'grief-prevention'
  | 'permissions'
  | 'economy'
  | 'world-management'
  | 'utilities';

export interface Plugin {
  name: string;
  slug: string;
  category: PluginCategory;
  purpose: string;
  features: string[];
  docsUrl?: string;
}

// Command types
export interface Command {
  command: string;
  description: string;
  usage?: string;
  aliases?: string[];
}

export interface CommandGroup {
  plugin: string;
  category: string;
  commands: Command[];
}

// Server rule type
export interface Rule {
  id: number;
  title: string;
  description: string;
}

// Server feature type
export interface Feature {
  id: string;
  title: string;
  description: string;
  icon?: string;
}

// Server info type
export interface ServerInfo {
  name: string;
  tagline: string;
  javaAddress: string;
  javaPort: number;
  bedrockAddress: string;
  bedrockPort: number;
}
