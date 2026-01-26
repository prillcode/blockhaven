// @ts-check
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';
import react from '@astrojs/react';

import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
// Note: Astro 5.x uses 'server' mode for SSR
// Individual pages can be pre-rendered with: export const prerender = true
export default defineConfig({
  output: 'server',
  adapter: cloudflare(),
  integrations: [react()],

  vite: {
    plugins: [tailwindcss()],
  },
});