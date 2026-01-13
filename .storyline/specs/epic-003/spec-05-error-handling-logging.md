---
spec_id: 05
story_id: 05
epic_id: 003
title: Error Handling, Logging & Documentation
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 05: Error Handling, Logging & Documentation

## Overview
Enhance error handling, add structured logging, and document API.

## Files to Create/Modify
```
src/middleware/error-handler.ts (create)
src/index.ts (update)
api/README.md (create)
api/.env.example (update)
```

## Implementation

### src/middleware/error-handler.ts
```typescript
import { Context } from 'hono';

export function errorHandler(err: Error, c: Context) {
  console.error('❌ Error:', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    path: c.req.path,
    method: c.req.method,
  });

  // Don't expose internal errors in production
  const message = process.env.NODE_ENV === 'development' 
    ? err.message 
    : 'Internal server error';

  return c.json({ error: message }, 500);
}
```

### Update src/index.ts
```typescript
import { errorHandler } from './middleware/error-handler';

// Enhanced logging
app.use('*', async (c, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  console.log(`${c.req.method} ${c.req.path} - ${c.res.status} (${ms}ms)`);
});

// ... routes ...

// Error handler
app.onError(errorHandler);
```

### api/README.md
```markdown
# BlockHaven API

Backend API for BlockHaven Minecraft server website.

## Tech Stack
- Hono (web framework)
- TypeScript
- @hono/node-server (Node.js adapter)

## Setup

### Prerequisites
- Node.js 20+
- pnpm

### Installation
\`\`\`bash
cd api
pnpm install
cp .env.example .env
# Edit .env with your values
\`\`\`

### Development
\`\`\`bash
pnpm dev  # Starts on port 3001
\`\`\`

### Production
\`\`\`bash
pnpm build
pnpm start
\`\`\`

## API Endpoints

### GET /api/health
Health check endpoint.

**Response:**
\`\`\`json
{
  "status": "ok",
  "timestamp": "2026-01-12T10:00:00.000Z",
  "uptime": 12345.67
}
\`\`\`

### GET /api/server-status
Get Minecraft server status (cached 30s).

**Response (online):**
\`\`\`json
{
  "online": true,
  "players": { "online": 12, "max": 100 },
  "version": "1.21.11",
  "latency": 45,
  "cached": false
}
\`\`\`

**Response (offline):**
\`\`\`json
{
  "online": false,
  "error": "Server is offline"
}
\`\`\`

### POST /api/contact
Submit contact form (rate limited: 3/10min per IP).

**Request:**
\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com",
  "subject": "Question",
  "message": "How do I claim land?"
}
\`\`\`

**Response (success):**
\`\`\`json
{
  "success": true,
  "message": "Message sent successfully"
}
\`\`\`

**Response (validation error):**
\`\`\`json
{
  "error": "Validation failed",
  "errors": [
    { "field": "email", "message": "Valid email is required" }
  ]
}
\`\`\`

**Response (rate limited):**
\`\`\`json
{
  "error": "Too many contact form submissions",
  "retryAfter": 456
}
\`\`\`

## Environment Variables

See `.env.example` for required variables:
- PORT - API server port (default: 3001)
- MC_SERVER_HOST - Minecraft server IP
- MC_SERVER_PORT - Minecraft server port
- DISCORD_WEBHOOK_URL - Discord webhook for contact form
- NODE_ENV - development | production

## Testing

\`\`\`bash
# Health check
curl http://localhost:3001/api/health

# Server status
curl http://localhost:3001/api/server-status

# Contact form
curl -X POST http://localhost:3001/api/contact \\
  -H "Content-Type: application/json" \\
  -d '{"name":"Test","email":"test@example.com","subject":"Test","message":"Test message"}'
\`\`\`

## Security
- CORS limited to bhsmp.com and localhost
- Rate limiting on contact form (3 req/10min per IP)
- Input validation on all POST endpoints
- Discord webhook URL never exposed to client
\`\`\`

### Update api/.env.example
```bash
# Server
PORT=3001
NODE_ENV=development

# Minecraft Server
MC_SERVER_HOST=5.161.69.191
MC_SERVER_PORT=25565

# Discord Webhook (for contact form)
# Get this from Discord: Server Settings > Integrations > Webhooks
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN

# CORS Origins (comma-separated)
ALLOWED_ORIGINS=http://localhost:5173,https://bhsmp.com
```

## Testing Checklist
- [ ] All error responses include error field
- [ ] 500 errors don't expose stack traces in production
- [ ] Request logging shows method, path, status, duration
- [ ] README.md documents all endpoints with examples
- [ ] .env.example lists all required variables
- [ ] curl examples work for all endpoints

## Dependencies
**Depends on:** Specs 01-04

---

**Next:** `/dev-story .storyline/specs/epic-003/spec-05-error-handling-logging.md`
