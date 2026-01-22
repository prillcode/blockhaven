---
story_id: 001
epic_id: 005
title: Frontend Docker Container with Multi-Stage Build
status: ready_for_spec
created: 2026-01-12
---

# Story 001: Frontend Docker Container with Multi-Stage Build

## User Story

**As a** DevOps engineer deploying the BlockHaven website,
**I want** a Docker image that builds and serves the React frontend efficiently,
**so that** the production deployment is fast, secure, and has a minimal image size.

## Acceptance Criteria

### Scenario 1: Multi-stage Docker build succeeds
**Given** I have the frontend source code in the web/ directory
**When** I run `docker build -f web/Dockerfile -t blockhaven-web:latest web/`
**Then** the Docker image builds successfully using a multi-stage build
**And** stage 1 uses Node.js to build the React app with `pnpm build`
**And** stage 2 uses nginx:alpine to serve the static files
**And** the final image size is less than 50MB

### Scenario 2: nginx serves React SPA correctly
**Given** the Docker container is running
**When** I navigate to any route (e.g., /about, /contact, /rules)
**Then** nginx serves index.html for all routes (SPA routing works)
**And** React Router handles client-side navigation
**And** no 404 errors occur for valid routes

### Scenario 3: Static assets are cached properly
**Given** the Docker container is serving the frontend
**When** I check the HTTP response headers for CSS/JS files
**Then** I see `Cache-Control: public, max-age=31536000, immutable` headers
**And** Vite-generated hashed filenames ensure cache busting works
**And** HTML files have `Cache-Control: no-cache` to ensure updates propagate

### Scenario 4: Gzip compression enabled
**Given** the Docker container is running
**When** I request a text file (HTML, CSS, JS, JSON)
**Then** nginx serves the file with gzip compression
**And** the response includes `Content-Encoding: gzip` header
**And** file sizes are reduced by 60-70%

## Business Value

**Why this matters:** Docker containerization enables consistent, reproducible deployments across development and production environments, reducing "works on my machine" issues.

**Impact:** Reduces deployment complexity, improves security (minimal attack surface with nginx:alpine), and enables easy scaling and rollback capabilities.

**Success metric:** Docker image builds successfully, serves the React app correctly, and is less than 50MB in size.

## Technical Considerations

**Potential approaches:**
- Multi-stage build: Stage 1 (Node.js build) → Stage 2 (nginx serve)
- Use nginx:alpine as final base image (smallest nginx image ~5MB)
- Custom nginx.conf for SPA routing and caching headers
- .dockerignore to exclude node_modules, .git, etc. from build context

**Constraints:**
- Must use pnpm (not npm) for package management
- Must work with Vite build output (dist/ directory)
- Must support React Router client-side routing
- Must set proper caching headers for performance
- Image must be production-ready (no dev dependencies)

**Data requirements:**
- Vite build outputs static files to web/dist/
- nginx.conf configuration for SPA routing
- Environment variables injected at runtime (if needed)

## Dependencies

**Depends on stories:**
- Epic 001-004: Complete frontend application (all features implemented)

**Enables stories:**
- Story 03: Docker Compose orchestration - provides web service image
- Story 04: VPS deployment - image to deploy

## Out of Scope

- Backend API Dockerfile (handled in Story 02)
- Docker Compose configuration (handled in Story 03)
- VPS deployment (handled in Story 04)
- SSL certificates (handled in Story 05)
- CI/CD automation (future enhancement)

## Notes

- Multi-stage builds reduce final image size by excluding build tools (Node.js, pnpm, source code)
- nginx:alpine is the smallest production-ready nginx image (~23MB compressed)
- Vite generates hashed filenames (e.g., main-abc123.js) for automatic cache busting
- nginx try_files directive handles SPA routing: `try_files $uri $uri/ /index.html`

## Traceability

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

**Related stories:** Story 02 (Backend Dockerfile), Story 03 (Docker Compose)

---

**Next step:** Run `/spec-story .storyline/stories/epic-005/story-01-frontend-docker-container.md`
