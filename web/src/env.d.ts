/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />

// Cloudflare KV namespace bindings
interface KVNamespace {
  get(key: string): Promise<string | null>;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void>;
  delete(key: string): Promise<void>;
}

declare namespace App {
  interface Locals {
    session?: {
      user: {
        name?: string | null;
        email?: string | null;
        image?: string | null;
        githubUsername?: string;
      };
      expires: string;
    };
    runtime: {
      env: {
        BLOCKHAVEN_RATE_LIMITS?: KVNamespace;
      };
    };
  }
}
