---
spec_id: 04
story_id: 04
epic_id: 003
title: Rate Limiting & CORS Middleware
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 04: Rate Limiting & CORS

## Overview
Implement rate limiting middleware (3 req/10min per IP) and configure CORS.

## Files to Create
```
src/middleware/rate-limit.ts
```

## Implementation

### src/middleware/rate-limit.ts
```typescript
import { Context, Next } from 'hono';

interface RateLimitEntry {
  count: number;
  resetAt: number;
}

const store = new Map<string, RateLimitEntry>();

export function rateLimiter(options: {
  windowMs: number;
  max: number;
  message?: string;
}) {
  return async (c: Context, next: Next) => {
    const ip = c.req.header('x-forwarded-for') || c.req.header('x-real-ip') || 'unknown';
    const key = `${ip}:${c.req.path}`;
    const now = Date.now();

    let entry = store.get(key);

    // Clean expired entries periodically
    if (store.size > 1000) {
      for (const [k, v] of store.entries()) {
        if (now > v.resetAt) store.delete(k);
      }
    }

    if (!entry || now > entry.resetAt) {
      entry = { count: 0, resetAt: now + options.windowMs };
      store.set(key, entry);
    }

    entry.count++;

    if (entry.count > options.max) {
      const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
      c.header('Retry-After', retryAfter.toString());
      return c.json(
        { error: options.message || 'Too many requests', retryAfter },
        429
      );
    }

    return next();
  };
}
```

### Update src/routes/contact.ts
```typescript
import { rateLimiter } from '../middleware/rate-limit';

// Apply rate limiting to contact route
contact.use('/*', rateLimiter({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 3, // 3 requests per window
  message: 'Too many contact form submissions. Please try again later.',
}));

// ... rest of contact route
```

### Update CORS in src/index.ts
```typescript
import { cors } from 'hono/cors';

// Update CORS middleware
app.use('*', cors({
  origin: (origin) => {
    const allowed = [
      'http://localhost:5173',
      'http://localhost:3000',
      'https://bhsmp.com',
      'https://www.bhsmp.com',
    ];
    return allowed.includes(origin) ? origin : allowed[0];
  },
  credentials: true,
  allowMethods: ['GET', 'POST', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  exposeHeaders: ['Content-Length', 'X-Request-Id'],
  maxAge: 600,
}));
```

## Testing Checklist
- [ ] 4th contact submission within 10min returns 429
- [ ] After 10min window, requests allowed again
- [ ] Retry-After header present on 429 responses
- [ ] CORS allows localhost:5173
- [ ] CORS allows bhsmp.com
- [ ] CORS blocks unknown origins
- [ ] Rate limit per IP (not global)

## Dependencies
**Depends on:** Specs 01, 02, 03

---

**Next:** `/dev-story .storyline/specs/epic-003/spec-04-rate-limiting-cors.md`
