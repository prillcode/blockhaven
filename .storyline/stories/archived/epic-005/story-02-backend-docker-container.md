---
story_id: 002
epic_id: 005
title: Backend API Docker Container
status: ready_for_spec
created: 2026-01-12
---

# Story 002: Backend API Docker Container

## User Story

**As a** DevOps engineer deploying the BlockHaven API,
**I want** a Docker image that runs the Hono backend API in production mode,
**so that** the API is containerized, secure, and ready for orchestration with the frontend.

## Acceptance Criteria

### Scenario 1: Docker build succeeds
**Given** I have the backend source code in the web-api/ directory
**When** I run `docker build -f web-api/Dockerfile -t blockhaven-api:latest web-api/`
**Then** the Docker image builds successfully
**And** the image uses node:20-alpine as the base (minimal size)
**And** the image installs production dependencies only (no devDependencies)
**And** the final image size is less than 100MB

### Scenario 2: API starts and responds to health checks
**Given** the Docker container is running
**When** I make a GET request to `http://localhost:3001/health`
**Then** I receive a 200 OK response
**And** the response body is `{"status":"ok"}`
**And** the API is ready to handle requests

### Scenario 3: API endpoints are accessible
**Given** the Docker container is running
**When** I make requests to `/api/server-status` and `/api/contact`
**Then** both endpoints respond correctly
**And** rate limiting is enforced
**And** CORS headers are present
**And** no crashes or errors occur

### Scenario 4: Environment variables are injected
**Given** I provide environment variables via docker run -e or .env file
**When** the container starts
**Then** the API uses the provided environment variables (DISCORD_WEBHOOK_URL, PORT, etc.)
**And** the API fails gracefully if required env vars are missing
**And** sensitive data is not hardcoded in the image

## Business Value

**Why this matters:** Containerizing the backend API enables deployment to any Docker-compatible host, simplifies orchestration with frontend, and improves security through isolation.

**Impact:** Makes the API portable, scalable, and easy to deploy alongside the frontend using Docker Compose or Kubernetes.

**Success metric:** Docker image builds successfully, API starts and responds to all endpoints, image size is under 100MB.

## Technical Considerations

**Potential approaches:**
- Single-stage build with node:20-alpine (backend doesn't need compilation)
- Use pnpm for package installation (faster, more efficient)
- Run as non-root user for security
- Use .dockerignore to exclude node_modules, .git, tests

**Constraints:**
- Must use pnpm (not npm) for package management
- Must run on port 3001 (or configurable via PORT env var)
- Must work with Hono framework (not Express)
- Must handle environment variables securely
- Must run as non-root user (security best practice)

**Data requirements:**
- Environment variables: DISCORD_WEBHOOK_URL, HYPIXEL_API_KEY, MINECRAFT_SERVER_IP, PORT
- Health check endpoint for container orchestration
- CORS configuration for frontend domain

## Dependencies

**Depends on stories:**
- Epic 003: Backend API Services - complete API implementation

**Enables stories:**
- Story 03: Docker Compose orchestration - provides web-api service image
- Story 04: VPS deployment - image to deploy

## Out of Scope

- Frontend Dockerfile (handled in Story 01)
- Docker Compose configuration (handled in Story 03)
- Database container (no database in this project)
- Redis container for caching (future enhancement)

## Notes

- node:20-alpine is the smallest production-ready Node.js image (~40MB compressed)
- Hono is designed for edge runtimes but works great with Node.js
- No build step needed for backend (TypeScript already transpiled or using tsx/ts-node)
- Health check endpoint is essential for Docker Compose healthcheck and load balancer probes

## Traceability

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

**Related stories:** Story 01 (Frontend Dockerfile), Story 03 (Docker Compose)

---

**Next step:** Run `/spec-story .storyline/stories/epic-005/story-02-backend-docker-container.md`
