---
epic_id: 003
title: Backend API Services
status: ready_for_stories
source: web/WEB-COMPLETE-PLAN.md
created: 2026-01-10
---

# Epic 003: Backend API Services

## Business Goal

Provide secure, performant backend API services for live server status monitoring and contact form submissions, enabling real-time player count display and direct communication with server administrators via Discord.

**Target outcome:** A production-ready Hono API with two endpoints (server status and contact form) that handle CORS, caching, rate limiting, and secure Discord webhook integration.

## User Value

**Who benefits:** Website visitors and server administrators

**How they benefit:**
- **Players**: See real-time server status (online/offline, player count) before deciding to join, reducing friction in the connection process
- **Administrators**: Receive contact form submissions directly in Discord without exposing webhook URLs to potential abuse

**Current pain point:** Without backend services, the website cannot show live server status (just static info) and cannot securely handle contact form submissions.

## Success Criteria

When this epic is complete:

- [ ] Hono API server runs on port 3001 without errors
- [ ] GET `/api/server-status` endpoint returns Minecraft server status (online, players, latency, version)
- [ ] Server status responses are cached for 30 seconds to reduce load
- [ ] POST `/api/contact` endpoint accepts form submissions and sends to Discord webhook
- [ ] Contact form has server-side validation (required fields, email format, message length)
- [ ] Rate limiting prevents spam: max 3 contact submissions per 10 minutes per IP
- [ ] CORS configured to allow frontend domain only
- [ ] API handles offline servers gracefully (returns appropriate error)
- [ ] Environment variables used for sensitive data (Discord webhook URL, server host/port)
- [ ] Error logging implemented for debugging

**Definition of Done:**
- All user stories completed
- Both API endpoints tested with curl/Postman
- Rate limiting verified (exceeding limit returns 429 status)
- Discord webhook integration tested (messages appear in Discord channel)
- TypeScript compilation successful
- API can start/stop cleanly with proper error handling
- Environment variables documented in .env.example

## Scope

### In Scope
- Hono server setup with TypeScript
- Server status endpoint (`/api/server-status`) using mcstatus.io API
- Contact form endpoint (`/api/contact`) with Discord webhook integration
- 30-second caching for server status responses
- Rate limiting middleware (3 requests per 10 minutes per IP)
- Input validation for contact form fields
- CORS middleware configuration
- Error handling and logging
- Environment variable configuration
- API TypeScript types (server status response, contact form request)

### Out of Scope
- Frontend integration (useServerStatus hook, ContactForm component) - handled in Epic 004
- Docker containerization - handled in Epic 005
- Database/persistent storage (contact submissions are sent to Discord only)
- Authentication/authorization (no protected endpoints)
- WebSocket/real-time updates (using polling instead)

### Boundaries
This epic provides backend services only. Frontend components that consume these APIs are in Epic 004. Deployment and containerization are in Epic 005.

## Dependencies

**Depends on:**
- No dependencies (can be developed independently)

**Enables:**
- Epic 004: Interactive Features & Frontend Integration - provides APIs for widgets to consume

**Parallel with:**
- Epic 002: Content Pages & UI Component Library - can be developed simultaneously

## Estimated Stories

**Story count:** ~6 user stories

**Complexity:** Medium

**Estimated effort:** Small to Medium epic (2 days)

## Technical Considerations

- **Hono Framework**: Modern, lightweight framework with excellent TypeScript support. Use `@hono/node-server` adapter for Node.js runtime.
- **mcstatus.io API**: Using external API instead of deprecated `minecraft-server-util` package. Rate limits may apply - caching helps mitigate this.
- **Rate Limiting**: Implement custom middleware or use Hono rate limiter middleware with memory store (sufficient for single-instance deployment)
- **Caching Strategy**: In-memory cache with TTL of 30 seconds. More sophisticated caching (Redis) not needed for this scale.
- **Discord Webhook Security**: Webhook URL must NEVER be exposed in client-side code or version control
- **CORS Configuration**: Use Hono's built-in CORS middleware to allow frontend domain (bhsmp.com) and localhost for development
- **Error Handling**: Return appropriate HTTP status codes (400 for validation errors, 429 for rate limit, 500 for server errors, 503 for offline Minecraft server)
- **Body Parsing**: Hono has built-in JSON body parsing, no need for separate body-parser middleware

## Risks & Assumptions

**Risks:**
- mcstatus.io API downtime could break server status feature (mitigation: implement graceful degradation, show "Unable to fetch status")
- Discord webhook could be rate-limited if spammed (mitigation: implement aggressive rate limiting on contact endpoint)
- CORS misconfiguration could block legitimate requests (mitigation: test thoroughly with actual frontend domain)

**Assumptions:**
- mcstatus.io API is reliable and has sufficient free tier limits
- Discord webhook URL will be provided and has proper channel permissions
- Minecraft server is publicly accessible for status queries (5.161.69.191:25565)
- Single API instance is sufficient (no load balancing needed initially)

## Related Epics

- Epic 004: Interactive Features & Frontend Integration - consumes these APIs
- Epic 005: Docker Deployment & Production Release - containerizes this API

## Source Reference

**Original PRD/Spec:** web/WEB-COMPLETE-PLAN.md

**Relevant sections:**
- Phase 3: Backend API (lines 771-800)
- Key Technical Decisions - Server Status Implementation (lines 219-244)
- Key Technical Decisions - Contact Form Integration (lines 247-271)
- Project Structure - api/ directory (lines 138-150)
- Backend API (lines 937-947)

---

**Next step:** Run `/story-creator .storyline/epics/epic-003-backend-api-services.md`
