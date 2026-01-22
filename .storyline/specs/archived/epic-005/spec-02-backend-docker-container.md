---
spec_id: 02
story_id: 002
epic_id: 005
title: Backend API Docker Container
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 02: Backend API Docker Container

## Overview

**User story:** [.storyline/stories/epic-005/story-02-backend-docker-container.md](../../stories/epic-005/story-02-backend-docker-container.md)

**Goal:** Create a production-ready Docker image for the Hono backend API that runs on Node.js 20 Alpine, installs only production dependencies, runs as non-root user, and includes health check endpoint integration.

**Approach:** Single-stage Dockerfile using node:20-alpine base, install production dependencies with pnpm, copy source code, run as non-root user for security, expose port 3001, and integrate health check for container orchestration.

## Technical Design

### Architecture Decision

**Chosen approach:** Single-stage Dockerfile with node:20-alpine + non-root user

**Alternatives considered:**
- **Multi-stage build** - Unnecessary for Node.js backend (no compilation needed)
- **Full node:20 image** - 3x larger (~300MB vs ~100MB), slower pulls
- **Distroless image** - More secure but harder to debug, overkill for MVP
- **Bun runtime** - Faster but less mature ecosystem, compatibility risks

**Rationale:** Node.js backend doesn't require compilation, so single-stage is simpler. Alpine base minimizes image size. Non-root user follows security best practices. Hono works perfectly with Node.js 20 (no special runtime needed).

### System Components

**Backend:**
- `web-api/Dockerfile` - Single-stage Dockerfile (new file)
- `web-api/.dockerignore` - Build context exclusions (new file)
- `web-api/src/` - Hono API source code (existing)
- `web-api/src/index.ts` - Main entry point with health check (existing)

**Runtime:**
- node:20-alpine base image
- pnpm package manager
- Non-root user (node user, UID 1000)

**External integrations:**
- Discord webhook (via environment variable)
- Hypixel API (via environment variable)
- Minecraft server (TCP connection for status check)

## Implementation Details

### Files to Create

#### `web-api/Dockerfile`
**Purpose:** Production-ready Docker image for Hono API
**Location:** `/home/aaronprill/projects/blockhaven/web-api/Dockerfile`

**Implementation:**
```dockerfile
# ============================================
# Production Node.js API Container
# ============================================
FROM node:20-alpine

# Install pnpm globally
RUN npm install -g pnpm@latest

# Create app directory
WORKDIR /app

# Install wget for health checks (not included in alpine by default)
RUN apk add --no-cache wget

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Copy source code
COPY . .

# Create non-root user (node user already exists in node:alpine)
# Change ownership of app directory to node user
RUN chown -R node:node /app

# Switch to non-root user
USER node

# Expose port 3001
EXPOSE 3001

# Health check - uses /health endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

# Start the API server
CMD ["node", "src/index.js"]
```

**Note:** If using TypeScript without transpilation, replace `node src/index.js` with:
- `CMD ["node", "--loader", "tsx", "src/index.ts"]` (using tsx)
- Or transpile TypeScript during build and run compiled JS

#### `web-api/.dockerignore`
**Purpose:** Exclude unnecessary files from Docker build context
**Location:** `/home/aaronprill/projects/blockhaven/web-api/.dockerignore`

**Implementation:**
```
# Dependencies (will be installed in container)
node_modules
pnpm-lock.yaml

# Development files
.env.local
.env.development
.env.test
*.env

# IDE files
.vscode
.idea
*.swp
*.swo
*~

# Logs
logs
*.log
npm-debug.log*
pnpm-debug.log*

# Testing
coverage
.nyc_output
__tests__
*.test.ts
*.test.js
*.spec.ts
*.spec.js

# Build outputs (if using TypeScript compilation)
dist
build

# Documentation
README.md
*.md
docs

# CI/CD
.github
.gitlab-ci.yml

# Docker
Dockerfile
.dockerignore
docker-compose.yml

# OS files
.DS_Store
Thumbs.db

# Git
.git
.gitignore
.gitattributes
```

#### `web-api/src/index.ts` (Health Check Endpoint)
**Purpose:** Add health check endpoint for Docker health checks
**Location:** `/home/aaronprill/projects/blockhaven/web-api/src/index.ts`

**Implementation:** (Add to existing Hono app)
```typescript
import { Hono } from 'hono';
import { cors } from 'hono/cors';

const app = new Hono();

// CORS middleware
app.use('/*', cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true,
}));

// ============================================
// Health Check Endpoint
// ============================================
app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// ============================================
// API Routes
// ============================================
app.get('/api/server-status', async (c) => {
  // Existing server status logic
  // ...
});

app.post('/api/contact', async (c) => {
  // Existing contact form logic
  // ...
});

// Start server
const port = parseInt(process.env.PORT || '3001');
console.log(`Server starting on http://localhost:${port}`);

export default {
  port,
  fetch: app.fetch,
};
```

### Files to Modify

**Modify:** `web-api/package.json`
**Change:** Ensure start script is defined for production
```json
{
  "name": "blockhaven-api",
  "version": "1.0.0",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "start": "node src/index.js",
    "build": "tsc"
  },
  "dependencies": {
    "hono": "^4.0.0"
  },
  "devDependencies": {
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

### Build Commands

**Build the Docker image:**
```bash
cd /home/aaronprill/projects/blockhaven
docker build -f web-api/Dockerfile -t blockhaven-api:latest web-api/
```

**Run the container (standalone):**
```bash
docker run -d -p 3001:3001 \
  --name blockhaven-api \
  -e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK" \
  -e HYPIXEL_API_KEY="your-api-key" \
  -e MINECRAFT_SERVER_IP="5.161.69.191:25565" \
  -e PORT=3001 \
  blockhaven-api:latest
```

**Run with .env file:**
```bash
docker run -d -p 3001:3001 \
  --name blockhaven-api \
  --env-file .env \
  blockhaven-api:latest
```

**Verify image size:**
```bash
docker images blockhaven-api:latest
# Expected: < 100MB
```

**Test the container:**
```bash
# Check health
curl http://localhost:3001/health

# Test API endpoints
curl http://localhost:3001/api/server-status

# View logs
docker logs blockhaven-api
```

### API Contracts

**Health Check Endpoint:**
```
GET /health
Response: 200 OK
{
  "status": "ok",
  "timestamp": "2026-01-12T10:00:00.000Z",
  "uptime": 123.456
}
```

**Server Status Endpoint:**
```
GET /api/server-status
Response: 200 OK
{
  "online": true,
  "playerCount": 15,
  "maxPlayers": 100,
  "timestamp": "2026-01-12T10:00:00.000Z"
}
```

**Contact Form Endpoint:**
```
POST /api/contact
Content-Type: application/json
Body: {
  "name": "John Doe",
  "email": "john@example.com",
  "message": "Question about server"
}

Response: 200 OK
{
  "success": true,
  "message": "Message sent successfully"
}
```

### Database Changes

None - API is stateless, no database required.

### State Management

**Environment variables:**
- `PORT` - Server port (default: 3001)
- `DISCORD_WEBHOOK_URL` - Discord webhook for contact form
- `HYPIXEL_API_KEY` - Hypixel API key (if needed)
- `MINECRAFT_SERVER_IP` - Minecraft server address
- `FRONTEND_URL` - Frontend URL for CORS (default: *)

**Runtime state:** In-memory only (no persistent state)

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Docker build succeeds
**Verification:**
- Run `docker build -f web-api/Dockerfile -t blockhaven-api:latest web-api/`
- Verify build completes without errors
- Check image uses node:20-alpine: `docker inspect blockhaven-api:latest`
- Verify image size: `docker images blockhaven-api:latest` shows < 100MB
- Verify production dependencies only: `docker run --rm blockhaven-api ls node_modules` (no dev deps)

**Story criterion 2:** API starts and responds to health checks
**Verification:**
- Start container: `docker run -d -p 3001:3001 --name test-api blockhaven-api:latest`
- Wait 10 seconds for startup
- Test health check: `curl http://localhost:3001/health`
- Verify response: `{"status":"ok",...}`
- Check container health: `docker inspect --format='{{.State.Health.Status}}' test-api`
- Expected: "healthy"

**Story criterion 3:** API endpoints are accessible
**Verification:**
- Start container with environment variables
- Test server status: `curl http://localhost:3001/api/server-status`
- Test contact form: `curl -X POST -H "Content-Type: application/json" -d '{"name":"Test","email":"test@example.com","message":"Test"}' http://localhost:3001/api/contact`
- Verify rate limiting: Make 100 rapid requests, verify 429 responses
- Verify CORS headers: `curl -I http://localhost:3001/api/server-status`

**Story criterion 4:** Environment variables are injected
**Verification:**
- Start container with `-e DISCORD_WEBHOOK_URL=test`
- Make contact form request
- Check logs: `docker logs test-api` - verify webhook URL used
- Test missing env var: Start without DISCORD_WEBHOOK_URL
- Verify graceful failure or warning in logs

## Testing Requirements

### Build Tests

**Test 1: Clean build succeeds**
```bash
# Remove existing image
docker rmi blockhaven-api:latest 2>/dev/null || true

# Build fresh
docker build -f web-api/Dockerfile -t blockhaven-api:latest web-api/

# Verify success
docker images blockhaven-api:latest
```

**Expected:** Build completes, image exists, size < 100MB

**Test 2: Production dependencies only**
```bash
# Check node_modules
docker run --rm blockhaven-api:latest ls node_modules

# Verify no devDependencies (tsx, typescript, etc.)
docker run --rm blockhaven-api:latest sh -c "ls node_modules | grep -E '(tsx|typescript|vitest)'"

# Expected: No dev dependencies found
```

**Test 3: Non-root user**
```bash
# Check user
docker run --rm blockhaven-api:latest whoami

# Expected: "node"
```

### Runtime Tests

**Test 4: Container starts successfully**
```bash
# Start container
docker run -d -p 3001:3001 --name test-api blockhaven-api:latest

# Wait for startup
sleep 5

# Check running
docker ps | grep test-api

# Cleanup
docker stop test-api && docker rm test-api
```

**Test 5: Health check passes**
```bash
# Start with health check
docker run -d -p 3001:3001 --name test-api blockhaven-api:latest

# Wait for health check
sleep 35

# Verify healthy
docker inspect --format='{{.State.Health.Status}}' test-api

# Expected: "healthy"
docker stop test-api && docker rm test-api
```

**Test 6: API endpoints respond**
```bash
# Start container
docker run -d -p 3001:3001 --name test-api \
  -e DISCORD_WEBHOOK_URL="test" \
  -e MINECRAFT_SERVER_IP="5.161.69.191:25565" \
  blockhaven-api:latest

sleep 5

# Test health
curl -f http://localhost:3001/health

# Test server status
curl -f http://localhost:3001/api/server-status

# Cleanup
docker stop test-api && docker rm test-api
```

### Integration Tests

**Scenario 1:** Full stack with docker-compose
- Setup: docker-compose.yml with web and web-api
- Action: `docker-compose up -d`
- Assert: Both containers start
- Assert: Frontend can call backend APIs via proxy

**Scenario 2:** Environment variable injection
- Setup: .env file with all required variables
- Action: `docker run --env-file .env blockhaven-api`
- Assert: API uses correct values (check logs)

### Manual Testing Checklist

- [ ] Build image successfully
- [ ] Image size < 100MB
- [ ] Container starts without errors
- [ ] Health check endpoint returns 200 OK
- [ ] Health check shows container as "healthy"
- [ ] Server status endpoint works
- [ ] Contact form endpoint works
- [ ] Rate limiting enforced (100+ requests)
- [ ] CORS headers present
- [ ] Environment variables injected correctly
- [ ] Runs as non-root user (node)
- [ ] Container logs show no errors
- [ ] Container restarts after crash
- [ ] Works with docker-compose

## Dependencies

**Must complete first:**
- Epic 003: Backend API Services - complete API implementation
- Hono framework setup
- Environment variable configuration

**Enables:**
- Spec 03: Docker Compose orchestration
- Spec 04: VPS deployment
- Production deployment of API

## Risks & Mitigations

**Risk 1:** Image size exceeds 100MB
**Mitigation:** Use node:20-alpine (minimal ~40MB) + production deps only
**Fallback:** Remove unnecessary dependencies from package.json
**Verification:** `docker images` after build

**Risk 2:** TypeScript not transpiled, runtime error
**Mitigation:** Use tsx for runtime TypeScript execution OR transpile to JS
**Fallback:** Add build step in Dockerfile: `RUN pnpm build`
**Verification:** Test API endpoints after container starts

**Risk 3:** Missing environment variables cause crashes
**Mitigation:** Add env var validation at startup, fail fast with clear error
**Fallback:** Use default values for non-critical env vars
**Verification:** Start container without env vars, check logs

**Risk 4:** Health check fails due to slow startup
**Mitigation:** Use `--start-period=10s` to allow startup time
**Fallback:** Increase start-period to 15s or 20s
**Verification:** Monitor `docker inspect` health status

**Risk 5:** Non-root user lacks permissions
**Mitigation:** `chown -R node:node /app` before USER switch
**Fallback:** Use root user (less secure, avoid if possible)
**Verification:** Test file access in container

## Performance Considerations

**Image size:**
- node:20-alpine base: ~40MB
- Production dependencies: ~30-40MB (Hono is lightweight)
- Source code: ~1-5MB
- Total: ~75-85MB (well under 100MB target)

**Build time:**
- First build: ~1-2 minutes (pnpm install)
- Cached builds: ~10-20 seconds (Docker layer caching)

**Runtime performance:**
- Hono is extremely fast (edge-optimized)
- Expected response time: <50ms for most endpoints
- Server status check: ~100-200ms (depends on Minecraft server)

**Resource usage:**
- Memory: ~50-100MB idle
- CPU: Minimal (event-driven I/O)

**Optimization strategies:**
- Use --frozen-lockfile to ensure reproducible builds
- Leverage Docker layer caching (COPY package files first)
- Run as non-root reduces attack surface
- Health check prevents routing to unhealthy containers

## Security Considerations

**Container security:**
- Runs as non-root user (node, UID 1000)
- Minimal base image (Alpine Linux)
- No unnecessary packages installed
- No secrets in image (env vars injected at runtime)

**API security:**
- CORS configured to restrict origins
- Rate limiting on all endpoints
- Input validation on contact form
- No sensitive data logged

**Environment variables:**
- Never commit .env to git (add to .gitignore)
- Use .env.example as template
- Inject secrets via docker run -e or docker-compose env_file

**Future enhancements:**
- Add Helmet.js for security headers
- Implement API key authentication
- Add request logging with sanitization
- Consider using secrets management (Docker secrets, Vault)

## Success Verification

After implementation, verify:
- [ ] Dockerfile builds successfully
- [ ] Image size < 100MB
- [ ] All build tests pass
- [ ] All runtime tests pass
- [ ] Manual testing checklist complete
- [ ] Health check endpoint works
- [ ] All API endpoints accessible
- [ ] Environment variables injected
- [ ] Runs as non-root user
- [ ] No security vulnerabilities (scan with docker scan)
- [ ] Container restarts successfully
- [ ] Works with docker-compose (Spec 03)

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-02-backend-docker-container.md](../../stories/epic-005/story-02-backend-docker-container.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**TypeScript considerations:**
- Option 1: Use tsx for runtime execution: `CMD ["node", "--loader", "tsx", "src/index.ts"]`
- Option 2: Transpile during build: Add `RUN pnpm build` step, run compiled JS
- Option 3: Use ts-node: Less performant, adds dependency

**Health check best practices:**
- Use /health endpoint (not /)
- Keep health check logic simple (just return 200 OK)
- Don't include external dependencies in health check (DB, APIs)
- Set appropriate intervals (30s) and timeouts (3s)

**Non-root user:**
- node:alpine includes 'node' user by default (UID 1000)
- Always chown before switching user
- Test file writes if API needs to write files

**Environment variable validation:**
```typescript
// Add at startup
const requiredEnvVars = ['DISCORD_WEBHOOK_URL', 'MINECRAFT_SERVER_IP'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`Missing required environment variable: ${envVar}`);
    process.exit(1);
  }
}
```

**Future enhancements:**
- Add Prometheus metrics endpoint (/metrics)
- Implement structured logging (JSON logs)
- Add OpenTelemetry tracing
- Consider multi-stage build if adding build step

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-02-backend-docker-container.md`
