---
spec_id: 01
story_id: 01
epic_id: 003
title: Hono API Server Setup & TypeScript Configuration
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 01: Hono API Server Setup

## Overview
Initialize Hono API server with TypeScript in `/web/api/` directory using pnpm and @hono/node-server adapter.

## Files to Create
```
/web/api/package.json
/web/api/tsconfig.json
/web/api/src/index.ts
/web/api/src/routes/health.ts
/web/api/.env.example
/web/api/.gitignore
/web/api/README.md
```

## Implementation

### package.json
```json
{
  "name": "blockhaven-api",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "hono": "^4.0.0",
    "@hono/node-server": "^1.8.0",
    "dotenv": "^16.4.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.7.0",
    "tsx": "^4.7.0"
  }
}
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "node",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### src/index.ts
```typescript
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import 'dotenv/config';

import health from './routes/health';

const app = new Hono();

// Middleware
app.use('*', logger());
app.use('*', cors({
  origin: ['http://localhost:5173', 'https://bhsmp.com'],
  credentials: true,
}));

// Routes
app.route('/api/health', health);

// 404 handler
app.notFound((c) => c.json({ error: 'Not found' }, 404));

// Error handler
app.onError((err, c) => {
  console.error('Server error:', err);
  return c.json({ error: 'Internal server error' }, 500);
});

const port = parseInt(process.env.PORT || '3001');
console.log(`🚀 API server running on http://localhost:${port}`);

serve({
  fetch: app.fetch,
  port,
});
```

### src/routes/health.ts
```typescript
import { Hono } from 'hono';

const health = new Hono();

health.get('/', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

export default health;
```

### .env.example
```bash
# Server
PORT=3001

# Minecraft Server
MC_SERVER_HOST=5.161.69.191
MC_SERVER_PORT=25565

# Discord Webhook (for contact form)
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN

# Environment
NODE_ENV=development
```

### .gitignore
```
node_modules/
dist/
.env
*.log
```

## Commands to Execute
```bash
cd /home/aaronprill/projects/blockhaven/web
mkdir -p api/src/routes
cd api
pnpm init
# Copy package.json content
pnpm install
pnpm dev
# Test: curl http://localhost:3001/api/health
```

## Testing Checklist
- [ ] pnpm dev starts server on port 3001
- [ ] GET /api/health returns {"status": "ok", ...}
- [ ] TypeScript compilation succeeds (pnpm build)
- [ ] Hot reload works when editing files
- [ ] CORS headers present in response
- [ ] No TypeScript errors

## Dependencies
**Depends on:** None
**Enables:** All other Epic 003 specs

---

**Next:** `/dev-story .storyline/specs/epic-003/spec-01-hono-server-setup.md`
