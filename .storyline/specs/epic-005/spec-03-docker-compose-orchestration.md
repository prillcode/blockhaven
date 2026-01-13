---
spec_id: 03
story_id: 003
epic_id: 005
title: Docker Compose Orchestration
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 03: Docker Compose Orchestration

## Overview

**User story:** [.storyline/stories/epic-005/story-03-docker-compose-orchestration.md](../../stories/epic-005/story-03-docker-compose-orchestration.md)

**Goal:** Create a docker-compose.yml file that orchestrates both frontend (web) and backend (web-api) services with proper networking, environment variable injection, health checks, and restart policies for local development and production deployment.

**Approach:** Define two services in docker-compose.yml (web and web-api), configure Docker bridge network for inter-service communication, inject environment variables via .env file, set restart policies to ensure reliability, and configure service dependencies with health checks.

## Technical Design

### Architecture Decision

**Chosen approach:** Standard docker-compose.yml with bridge networking

**Alternatives considered:**
- **Kubernetes** - Too complex for single-server deployment, overkill for MVP
- **Docker Swarm** - Multi-node orchestration not needed for single VPS
- **Separate docker run commands** - Manual, error-prone, no automatic networking
- **Traefik reverse proxy** - Additional complexity, not needed with nginx in web container

**Rationale:** Docker Compose is the standard for orchestrating multi-container applications on a single host. It automatically creates a network for service-to-service communication, handles dependencies, and provides declarative configuration. Perfect fit for VPS deployment.

### System Components

**Docker services:**
- `web` - Frontend React application (nginx container from Spec 01)
- `web-api` - Backend Hono API (Node.js container from Spec 02)

**Networking:**
- Docker bridge network (default, automatically created)
- Service discovery via service names (web-api, web)

**Configuration:**
- `docker-compose.yml` - Service orchestration (new file)
- `.env` - Environment variables (new file, not committed)
- `.env.example` - Environment variable template (new file, committed)

**External integrations:**
- Host port 80 → web service
- Host port 3001 → web-api service (for debugging, optional)

## Implementation Details

### Files to Create

#### `docker-compose.yml`
**Purpose:** Orchestrate web and web-api services
**Location:** `/home/aaronprill/projects/blockhaven/docker-compose.yml`

**Implementation:**
```yaml
version: '3.8'

services:
  # ============================================
  # Backend API Service
  # ============================================
  web-api:
    build:
      context: ./web-api
      dockerfile: Dockerfile
    image: blockhaven-api:latest
    container_name: blockhaven-api
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
      - DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
      - HYPIXEL_API_KEY=${HYPIXEL_API_KEY}
      - MINECRAFT_SERVER_IP=${MINECRAFT_SERVER_IP}
      - FRONTEND_URL=${FRONTEND_URL}
      - NODE_ENV=production
    env_file:
      - .env
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3001/health"]
      interval: 30s
      timeout: 3s
      start_period: 10s
      retries: 3
    networks:
      - blockhaven-network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # Frontend Web Service
  # ============================================
  web:
    build:
      context: ./web
      dockerfile: Dockerfile
    image: blockhaven-web:latest
    container_name: blockhaven-web
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      web-api:
        condition: service_healthy
    networks:
      - blockhaven-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 3s
      start_period: 5s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

# ============================================
# Networks
# ============================================
networks:
  blockhaven-network:
    driver: bridge
    name: blockhaven-network
```

#### `.env.example`
**Purpose:** Template for environment variables
**Location:** `/home/aaronprill/projects/blockhaven/.env.example`

**Implementation:**
```bash
# ============================================
# BlockHaven Environment Variables
# ============================================
# Copy this file to .env and fill in your values
# NEVER commit .env to version control!

# Backend API Configuration
PORT=3001
NODE_ENV=production

# Discord Webhook for Contact Form
# Get this from Discord: Server Settings > Integrations > Webhooks
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN

# Hypixel API Key (if needed for server status)
# Get this from https://developer.hypixel.net/
HYPIXEL_API_KEY=your-hypixel-api-key-here

# Minecraft Server Configuration
MINECRAFT_SERVER_IP=5.161.69.191:25565

# Frontend URL (for CORS)
# In production: https://bhsmp.com
# In development: http://localhost:5173
FRONTEND_URL=https://bhsmp.com

# Optional: Additional configuration
# RATE_LIMIT_MAX=100
# RATE_LIMIT_WINDOW=900000
```

#### `.env` (Production)
**Purpose:** Actual environment variables (NOT committed to git)
**Location:** `/home/aaronprill/projects/blockhaven/.env`

**Implementation:** User creates this file based on .env.example
```bash
# Add to .gitignore
echo ".env" >> .gitignore
```

### Files to Modify

**Modify:** `.gitignore`
**Add:**
```
# Environment variables
.env
.env.local
.env.production
```

**Modify:** `web/nginx.conf` (already done in Spec 01)
**Verify:** API proxy configuration uses service name `web-api:3001`

### Docker Compose Commands

**Start services:**
```bash
cd /home/aaronprill/projects/blockhaven
docker-compose up -d
```

**View logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
docker-compose logs -f web-api
```

**Check status:**
```bash
docker-compose ps
```

**Stop services:**
```bash
docker-compose down
```

**Rebuild and restart:**
```bash
docker-compose up -d --build
```

**Remove everything (including volumes):**
```bash
docker-compose down -v
```

### API Contracts

**Service-to-service communication:**
- Frontend nginx proxies `/api/*` to `http://web-api:3001/api/*`
- Docker DNS resolves `web-api` to backend container IP automatically
- Backend listens on port 3001 inside Docker network
- Frontend exposed on host port 80

**Health checks:**
- `web-api`: `GET http://localhost:3001/health` → 200 OK
- `web`: `GET http://localhost/` → 200 OK

### Database Changes

None - No database in this project.

### State Management

**Environment variables:**
- Injected via `.env` file
- Accessed in containers via `process.env` (Node.js) or runtime
- Frontend gets env vars at build time (embedded in bundle)
- Backend gets env vars at runtime (injected by Docker)

**Persistent data:**
- None required for MVP
- Future: Add volumes for logs, uploads, etc.

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Start entire stack with docker-compose
**Verification:**
- Run `docker-compose up -d`
- Verify both services start: `docker-compose ps`
- Check web service: `curl http://localhost/`
- Check API service: `curl http://localhost:3001/health`
- Verify logs show no errors: `docker-compose logs`

**Story criterion 2:** Frontend proxies API requests to backend
**Verification:**
- Start services: `docker-compose up -d`
- Open browser DevTools Network tab
- Load homepage
- Check server status widget (makes request to /api/server-status)
- Verify request goes to http://localhost/api/server-status (not localhost:3001)
- Verify nginx proxies to backend (check response headers)
- Test contact form submission
- Verify Discord webhook receives message

**Story criterion 3:** Services restart automatically on failure
**Verification:**
- Start services: `docker-compose up -d`
- Kill backend: `docker kill blockhaven-api`
- Wait 10 seconds
- Check status: `docker-compose ps`
- Verify web-api shows as restarted
- Test health check: `curl http://localhost:3001/health`
- Verify working again

**Story criterion 4:** Environment variables are loaded
**Verification:**
- Create .env file with test values
- Start services: `docker-compose up -d`
- Check backend logs: `docker-compose logs web-api`
- Verify env vars logged at startup (if logging is implemented)
- Test contact form - verify Discord webhook URL used
- Verify server status uses correct Minecraft IP

## Testing Requirements

### Build Tests

**Test 1: docker-compose builds both images**
```bash
# Clean slate
docker-compose down
docker rmi blockhaven-web blockhaven-api 2>/dev/null || true

# Build
docker-compose build

# Verify images created
docker images | grep blockhaven
```

**Expected:** Both blockhaven-web and blockhaven-api images created

**Test 2: docker-compose validates configuration**
```bash
# Validate config
docker-compose config

# Expected: No errors, prints parsed config
```

### Runtime Tests

**Test 3: Services start in correct order**
```bash
# Start services
docker-compose up -d

# Check startup sequence
docker-compose logs web-api | grep -i "starting"
docker-compose logs web | grep -i "starting"

# Verify web-api started before web (depends_on)
```

**Test 4: Health checks pass**
```bash
# Start services
docker-compose up -d

# Wait for health checks
sleep 40

# Check health status
docker inspect --format='{{.State.Health.Status}}' blockhaven-web
docker inspect --format='{{.State.Health.Status}}' blockhaven-api

# Expected: Both "healthy"
```

**Test 5: Inter-service networking works**
```bash
# Start services
docker-compose up -d

# Test API directly
curl http://localhost:3001/health

# Test API via frontend proxy
curl http://localhost/api/server-status

# Both should return 200
```

**Test 6: Restart policy works**
```bash
# Start services
docker-compose up -d

# Kill backend
docker kill blockhaven-api

# Wait for restart
sleep 15

# Verify running
docker ps | grep blockhaven-api

# Expected: Container restarted
```

### Integration Tests

**Scenario 1:** Full stack functionality
- Setup: docker-compose up -d
- Action: Open http://localhost in browser
- Assert: Homepage loads
- Assert: Server status widget shows data
- Action: Submit contact form
- Assert: Discord webhook receives message
- Assert: No errors in browser console

**Scenario 2:** Environment variable changes
- Setup: Modify .env file
- Action: docker-compose down && docker-compose up -d
- Assert: New env vars used
- Assert: Logs show new configuration

**Scenario 3:** Service failure recovery
- Setup: docker-compose up -d
- Action: Kill backend service
- Assert: Frontend shows error state
- Wait: 15 seconds for restart
- Assert: Backend restarts automatically
- Assert: Frontend recovers and shows data

### Manual Testing Checklist

- [ ] docker-compose.yml validates (docker-compose config)
- [ ] Both services build successfully
- [ ] Both services start with `docker-compose up -d`
- [ ] Both services show as "healthy" in `docker ps`
- [ ] Frontend accessible on http://localhost:80
- [ ] Backend accessible on http://localhost:3001
- [ ] API proxy works (test /api/server-status)
- [ ] Health checks pass for both services
- [ ] Services restart after kill
- [ ] Environment variables injected correctly
- [ ] Logs are accessible (docker-compose logs)
- [ ] No errors in logs
- [ ] Services stop cleanly (docker-compose down)
- [ ] Rebuild works (docker-compose up -d --build)

## Dependencies

**Must complete first:**
- Spec 01: Frontend Docker Container
- Spec 02: Backend Docker Container
- Docker installed on host
- Docker Compose installed on host

**Enables:**
- Spec 04: VPS deployment (uses this docker-compose.yml)
- Local development environment
- Production deployment

## Risks & Mitigations

**Risk 1:** Service startup race condition (frontend starts before backend ready)
**Mitigation:** Use `depends_on` with `condition: service_healthy`
**Fallback:** Add retry logic in frontend API calls
**Verification:** Test startup sequence with `docker-compose logs`

**Risk 2:** Environment variables not loaded
**Mitigation:** Use both `environment:` and `env_file:` in docker-compose.yml
**Fallback:** Set default values in backend code
**Verification:** Check logs for env var values at startup

**Risk 3:** Network isolation prevents inter-service communication
**Mitigation:** Use explicit network definition with bridge driver
**Fallback:** Use `network_mode: host` (less isolated but works)
**Verification:** Test API proxy from frontend to backend

**Risk 4:** Restart loop if service fails health check repeatedly
**Mitigation:** Set appropriate retries (3) and start_period (10s for API)
**Fallback:** Disable health check temporarily for debugging
**Verification:** Monitor `docker ps` for restart count

**Risk 5:** .env file missing or misconfigured
**Mitigation:** Provide clear .env.example with all required variables
**Fallback:** Use docker-compose config validation before starting
**Verification:** Test with fresh .env file

## Performance Considerations

**Startup time:**
- First start (build): ~3-5 minutes (build both images)
- Subsequent starts: ~10-15 seconds (cached images)
- Health check stabilization: ~30-40 seconds

**Resource usage:**
- Total memory: ~200-300MB (both containers)
- Total CPU: Minimal at idle
- Disk space: ~150MB (both images + layers)

**Network performance:**
- Internal Docker network: Very fast (near localhost speed)
- No performance penalty for service-to-service calls

**Optimization strategies:**
- Use restart: unless-stopped (not always)
- Limit log file size (max-size: 10m, max-file: 3)
- Use health checks to prevent routing to unhealthy containers
- Enable BuildKit for faster builds: `DOCKER_BUILDKIT=1 docker-compose build`

## Security Considerations

**Environment variable security:**
- .env file in .gitignore (never commit)
- Use .env.example for documentation
- Consider Docker secrets for production (more secure)

**Network security:**
- Bridge network isolates containers from host
- Only expose necessary ports to host (80, 3001)
- API not directly accessible from internet (behind nginx proxy)

**Container security:**
- Both containers run as non-root users
- Restart policy prevents manual tampering
- Health checks detect compromised containers

**Future enhancements:**
- Use Docker secrets instead of .env file
- Implement network policies (restrict inter-service communication)
- Add rate limiting at nginx level
- Consider using private Docker registry

## Success Verification

After implementation, verify:
- [ ] docker-compose.yml created and validates
- [ ] .env.example created with all variables
- [ ] .env added to .gitignore
- [ ] All build tests pass
- [ ] All runtime tests pass
- [ ] Manual testing checklist complete
- [ ] Both services start with single command
- [ ] Inter-service networking works
- [ ] Health checks pass
- [ ] Restart policy works
- [ ] Environment variables injected
- [ ] Logs accessible and clean
- [ ] Services stop cleanly

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-03-docker-compose-orchestration.md](../../stories/epic-005/story-03-docker-compose-orchestration.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**docker-compose.yml best practices:**
- Use version 3.8 (latest stable at time of writing)
- Define explicit network for better control
- Use restart: unless-stopped (not always) for reliability
- Set health checks for critical services
- Limit log file size to prevent disk filling

**depends_on with health checks:**
- Requires `condition: service_healthy`
- Backend must have working health check endpoint
- Frontend waits until backend is healthy before starting

**Environment variable precedence:**
1. `environment:` in docker-compose.yml (highest priority)
2. `env_file:` .env file
3. Default values in code (lowest priority)

**Service naming:**
- Service names (web, web-api) used for DNS resolution
- Container names (blockhaven-web) for docker commands
- Image names (blockhaven-web:latest) for registry

**Networking:**
- Docker creates DNS entries for service names
- `web-api` resolves to backend container IP
- No need for IP addresses or localhost references

**Logging:**
- json-file driver stores logs on host
- max-size: 10m prevents disk filling
- max-file: 3 keeps last 3 rotations
- Access with `docker-compose logs`

**Development vs Production:**
- Same docker-compose.yml for both
- Different .env files for different environments
- Consider docker-compose.override.yml for dev-specific config

**Future enhancements:**
- Add Redis service for caching
- Add volume mounts for persistent data
- Add Watchtower for auto-updates
- Implement blue-green deployment strategy

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-03-docker-compose-orchestration.md`
