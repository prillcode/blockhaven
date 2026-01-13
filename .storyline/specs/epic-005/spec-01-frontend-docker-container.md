---
spec_id: 01
story_id: 001
epic_id: 005
title: Frontend Docker Container with Multi-Stage Build
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 01: Frontend Docker Container with Multi-Stage Build

## Overview

**User story:** [.storyline/stories/epic-005/story-01-frontend-docker-container.md](../../stories/epic-005/story-01-frontend-docker-container.md)

**Goal:** Create a production-ready Docker image for the React frontend using multi-stage build to minimize image size (<50MB) and serve static files efficiently with nginx.

**Approach:** Two-stage Docker build: Stage 1 uses Node.js 20 Alpine with pnpm to build the Vite React app, Stage 2 uses nginx Alpine to serve the optimized static files with proper caching, compression, and SPA routing.

## Technical Design

### Architecture Decision

**Chosen approach:** Multi-stage Docker build (Node.js build → nginx serve)

**Alternatives considered:**
- **Single-stage with Node.js serve-static** - Larger image (~200MB), inefficient for static content
- **Caddy server instead of nginx** - Less mature ecosystem, harder to find production configs
- **Node.js base with nginx installed** - Unnecessarily includes Node.js in final image

**Rationale:** Multi-stage build eliminates build dependencies (Node.js, pnpm, source code) from final image. nginx Alpine is production-proven, extremely efficient for static files, and adds only ~23MB to image size. Separating build and serve stages follows Docker best practices.

### System Components

**Frontend:**
- `web/Dockerfile` - Multi-stage Dockerfile (new file)
- `web/.dockerignore` - Build context exclusions (new file)
- `web/nginx.conf` - Custom nginx configuration (new file)
- `web/` directory - React app source (existing)

**Build artifacts:**
- `web/dist/` - Vite production build output (generated at build time)

**Runtime:**
- nginx:alpine base image
- Serves from `/usr/share/nginx/html`

**External integrations:**
- None (static file serving only)

## Implementation Details

### Files to Create

#### `web/Dockerfile`
**Purpose:** Multi-stage Docker build for React frontend
**Location:** `/home/aaronprill/projects/blockhaven/web/Dockerfile`

**Implementation:**
```dockerfile
# ============================================
# Stage 1: Build the React application
# ============================================
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm@latest

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install dependencies (including devDependencies for build)
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application for production
RUN pnpm build

# Verify build output exists
RUN ls -la /app/dist

# ============================================
# Stage 2: Serve with nginx
# ============================================
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# nginx runs as non-root by default in nginx:alpine
# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
```

#### `web/.dockerignore`
**Purpose:** Exclude unnecessary files from Docker build context
**Location:** `/home/aaronprill/projects/blockhaven/web/.dockerignore`

**Implementation:**
```
# Dependencies
node_modules
pnpm-lock.yaml

# Build outputs (will be generated in container)
dist
build
.vite

# Development files
.git
.gitignore
.env.local
.env.development
.env.test

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
```

#### `web/nginx.conf`
**Purpose:** Custom nginx configuration for SPA routing, caching, and compression
**Location:** `/home/aaronprill/projects/blockhaven/web/nginx.conf`

**Implementation:**
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        font/truetype
        font/opentype
        application/vnd.ms-fontobject
        image/svg+xml;

    # Cache static assets with hash in filename (Vite generates these)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Don't cache HTML files (to ensure updates propagate)
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Proxy API requests to backend (when running with docker-compose)
    location /api/ {
        proxy_pass http://web-api:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # SPA routing: serve index.html for all non-file requests
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Custom 404 page (optional)
    error_page 404 /index.html;
}
```

### Files to Modify

None - All new files for this feature.

### Build Commands

**Build the Docker image:**
```bash
cd /home/aaronprill/projects/blockhaven
docker build -f web/Dockerfile -t blockhaven-web:latest web/
```

**Run the container (standalone):**
```bash
docker run -d -p 80:80 --name blockhaven-web blockhaven-web:latest
```

**Verify image size:**
```bash
docker images blockhaven-web:latest
# Expected: < 50MB
```

**Test the container:**
```bash
# Check health
docker ps

# View logs
docker logs blockhaven-web

# Test HTTP response
curl http://localhost/
```

### API Contracts

None - Serves static files only. API proxy configuration is in nginx.conf but API calls handled by backend container.

### Database Changes

None

### State Management

None - Static file serving only. Client-side state managed by React app.

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Multi-stage Docker build succeeds
**Verification:**
- Run `docker build -f web/Dockerfile -t blockhaven-web:latest web/`
- Verify build completes without errors
- Check build output shows both stages: builder and final nginx stage
- Verify final image size: `docker images blockhaven-web:latest` shows < 50MB
- Test: Build on clean system to ensure reproducibility

**Story criterion 2:** nginx serves React SPA correctly
**Verification:**
- Start container: `docker run -d -p 80:80 blockhaven-web:latest`
- Navigate to http://localhost/ - verify homepage loads
- Navigate to http://localhost/about - verify About page loads (not 404)
- Navigate to http://localhost/contact - verify Contact page loads
- Check browser DevTools Network tab - verify no 404 errors for routes
- Test: Hard refresh on deep route (/rules) - should serve index.html

**Story criterion 3:** Static assets cached properly
**Verification:**
- Start container
- Open DevTools Network tab
- Load homepage
- Check CSS file response headers: `Cache-Control: public, immutable` and `expires: 1y`
- Check JS file response headers: `Cache-Control: public, immutable` and `expires: 1y`
- Check index.html headers: `Cache-Control: no-cache, no-store, must-revalidate`
- Verify Vite-generated filenames include hash (e.g., main-abc123.js)

**Story criterion 4:** Gzip compression enabled
**Verification:**
- Start container
- Make request with curl: `curl -H "Accept-Encoding: gzip" -I http://localhost/`
- Verify response includes `Content-Encoding: gzip` header
- Check file sizes: `curl http://localhost/ | wc -c` (without gzip)
- Check file sizes: `curl -H "Accept-Encoding: gzip" http://localhost/ | wc -c` (with gzip)
- Verify gzip reduces size by 60-70%

## Testing Requirements

### Build Tests

**Test 1: Clean build succeeds**
```bash
# Remove any existing images
docker rmi blockhaven-web:latest 2>/dev/null || true

# Build fresh
docker build -f web/Dockerfile -t blockhaven-web:latest web/

# Verify build succeeded
docker images blockhaven-web:latest
```

**Expected:** Build completes, image exists, size < 50MB

**Test 2: Build output contains required files**
```bash
# Run container with shell override
docker run --rm blockhaven-web:latest ls -la /usr/share/nginx/html

# Expected files: index.html, assets/, favicon.ico, etc.
```

**Test 3: nginx configuration is valid**
```bash
# Test nginx config syntax
docker run --rm blockhaven-web:latest nginx -t
```

**Expected:** "nginx: configuration file /etc/nginx/nginx.conf test is successful"

### Runtime Tests

**Test 4: Container starts and serves content**
```bash
# Start container
docker run -d -p 80:80 --name test-web blockhaven-web:latest

# Wait for startup
sleep 2

# Test homepage
curl -f http://localhost/

# Cleanup
docker stop test-web && docker rm test-web
```

**Expected:** HTTP 200, HTML content returned

**Test 5: SPA routing works**
```bash
# Start container
docker run -d -p 80:80 --name test-web blockhaven-web:latest

# Test various routes
curl -f http://localhost/about
curl -f http://localhost/contact
curl -f http://localhost/rules

# All should return 200 (index.html)
docker stop test-web && docker rm test-web
```

**Test 6: Health check passes**
```bash
# Start container with health check
docker run -d -p 80:80 --name test-web blockhaven-web:latest

# Wait for health check
sleep 35

# Check health status
docker inspect --format='{{.State.Health.Status}}' test-web

# Expected: "healthy"
docker stop test-web && docker rm test-web
```

### Integration Tests

**Scenario 1:** Build and run full stack with docker-compose
- Setup: Create docker-compose.yml with web and web-api services
- Action: Run `docker-compose up -d`
- Assert: Both services start
- Assert: Frontend accessible on http://localhost:80
- Assert: API requests from frontend proxy to backend

**Scenario 2:** Test caching headers in production
- Setup: Deploy to VPS
- Action: Load site, check Network tab for asset headers
- Assert: JS/CSS files have max-age=31536000
- Assert: HTML files have no-cache

### Manual Testing Checklist

- [ ] Build image successfully
- [ ] Image size is < 50MB
- [ ] Container starts without errors
- [ ] Homepage loads at http://localhost/
- [ ] About page loads at http://localhost/about
- [ ] Contact page loads at http://localhost/contact
- [ ] Rules page loads at http://localhost/rules
- [ ] Hard refresh on deep route works (no 404)
- [ ] Static assets load (CSS, JS, images)
- [ ] Caching headers present on assets
- [ ] Gzip compression active (check DevTools)
- [ ] Health check passes (docker ps shows "healthy")
- [ ] Container logs show no errors
- [ ] API proxy works (when running with backend)

## Dependencies

**Must complete first:**
- Epic 001-004: Complete frontend application
- Frontend must use Vite for build (outputs to dist/)
- Frontend must use pnpm package manager

**Enables:**
- Spec 03: Docker Compose orchestration
- Spec 04: VPS deployment
- Production deployment of website

## Risks & Mitigations

**Risk 1:** Image size exceeds 50MB target
**Mitigation:** Use nginx:alpine (smallest nginx ~23MB) + multi-stage build
**Fallback:** Optimize Vite build output (tree-shaking, code splitting)
**Verification:** Check `docker images` after build

**Risk 2:** SPA routing breaks (404 on deep routes)
**Mitigation:** nginx `try_files $uri /index.html` directive
**Fallback:** Add explicit location blocks for each route
**Verification:** Test all routes with curl and browser

**Risk 3:** Build fails due to missing pnpm-lock.yaml
**Mitigation:** Dockerfile uses `pnpm-lock.yaml*` (optional with *)
**Fallback:** Add `RUN pnpm install` without --frozen-lockfile
**Verification:** Test build on clean system

**Risk 4:** Caching headers break after updates
**Mitigation:** HTML has no-cache, Vite generates hashed filenames
**Fallback:** Clear CDN cache manually after deployment
**Verification:** Deploy update, verify new assets load

## Performance Considerations

**Image size:**
- Stage 1 (builder): ~400MB (node:20-alpine + dependencies) - discarded
- Stage 2 (final): ~25-45MB (nginx:alpine + static files)
- Target: < 50MB achieved

**Build time:**
- First build: ~2-3 minutes (pnpm install + Vite build)
- Cached builds: ~30 seconds (Docker layer caching)

**Runtime performance:**
- nginx serves static files: <10ms response time
- Gzip reduces bandwidth by 60-70%
- Cached assets reduce repeat visitor load time

**Optimization strategies:**
- Enable Docker BuildKit for faster builds: `DOCKER_BUILDKIT=1 docker build ...`
- Use .dockerignore to minimize build context
- Multi-stage build excludes dev dependencies
- nginx gzip_comp_level 6 (balanced compression/CPU)

## Security Considerations

**Container security:**
- nginx:alpine runs as non-root user (nginx user)
- Minimal attack surface (no shell, no compilers in final image)
- No secrets in image (environment variables injected at runtime)

**HTTP security headers:**
- X-Frame-Options: SAMEORIGIN (prevent clickjacking)
- X-Content-Type-Options: nosniff (prevent MIME sniffing)
- X-XSS-Protection: 1; mode=block (legacy XSS protection)
- Referrer-Policy: no-referrer-when-downgrade

**Future enhancements:**
- Add Content-Security-Policy header
- Add HSTS header (after SSL setup in Spec 05)
- Consider running nginx as fully unprivileged user (custom UID)

## Success Verification

After implementation, verify:
- [ ] Dockerfile builds successfully
- [ ] Image size < 50MB
- [ ] All build tests pass
- [ ] All runtime tests pass
- [ ] Manual testing checklist complete
- [ ] SPA routing works for all routes
- [ ] Caching headers correct
- [ ] Gzip compression active
- [ ] Health check passes
- [ ] No console errors in browser
- [ ] Container restarts successfully
- [ ] Works with docker-compose (Spec 03)

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-01-frontend-docker-container.md](../../stories/epic-005/story-01-frontend-docker-container.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**Dockerfile best practices:**
- Use specific image tags (node:20-alpine) not latest
- Minimize layers (combine RUN commands where logical)
- Order layers by change frequency (dependencies first, code last)
- Use .dockerignore to speed up builds

**nginx configuration:**
- SPA routing: `try_files $uri /index.html` is critical
- API proxy: `proxy_pass http://web-api:3001` uses Docker service name
- Gzip: Don't compress already-compressed formats (images, fonts)

**Vite build output:**
- Outputs to dist/ directory by default
- Generates hashed filenames for automatic cache busting
- Creates assets/ subdirectory for chunks

**Testing tips:**
- Test with `docker run --rm` for quick cleanup
- Use `docker logs -f <container>` to watch nginx logs
- Test API proxy by making requests to /api/* endpoints

**Future enhancements:**
- Add nginx access logs parsing for analytics
- Implement CDN integration (Cloudflare)
- Add Brotli compression (better than gzip)
- Implement service worker for offline support

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-01-frontend-docker-container.md`
