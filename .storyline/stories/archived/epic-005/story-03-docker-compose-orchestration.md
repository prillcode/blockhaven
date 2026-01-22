---
story_id: 003
epic_id: 005
title: Docker Compose Orchestration
status: ready_for_spec
created: 2026-01-12
---

# Story 003: Docker Compose Orchestration

## User Story

**As a** DevOps engineer,
**I want** a docker-compose.yml file that orchestrates both frontend and backend services,
**so that** I can start the entire application stack with a single command.

## Acceptance Criteria

### Scenario 1: Start entire stack with docker-compose
**Given** I have docker-compose.yml in the project root
**When** I run `docker-compose up -d`
**Then** both web (frontend) and web-api (backend) services start successfully
**And** the web service is accessible on http://localhost:80
**And** the web-api service is accessible on http://localhost:3001
**And** both services are running in detached mode

### Scenario 2: Frontend proxies API requests to backend
**Given** both services are running via docker-compose
**When** the frontend makes a request to `/api/server-status`
**Then** nginx in the web container proxies the request to the web-api container
**And** the request is routed via Docker network (no external calls)
**And** the response is returned correctly to the frontend

### Scenario 3: Services restart automatically on failure
**Given** the docker-compose services are running
**When** one service crashes or stops unexpectedly
**Then** Docker automatically restarts the failed service
**And** the restart policy is `restart: unless-stopped`
**And** the service recovers without manual intervention

### Scenario 4: Environment variables are loaded
**Given** I have a .env file in the project root
**When** I run `docker-compose up`
**Then** environment variables from .env are injected into the web-api service
**And** sensitive values (DISCORD_WEBHOOK_URL) are not exposed in docker-compose.yml
**And** the API uses the provided environment variables

## Business Value

**Why this matters:** Docker Compose simplifies local development and deployment by orchestrating multiple services with networking, dependencies, and environment configuration in one declarative file.

**Impact:** Developers can start the entire stack with one command. Production deployments become more reliable with proper service orchestration and auto-restart policies.

**Success metric:** Single `docker-compose up` command starts both services, frontend can communicate with backend, services auto-restart on failure.

## Technical Considerations

**Potential approaches:**
- Standard docker-compose.yml with services: web, web-api
- Docker internal networking (bridge network)
- Environment variable injection via .env file
- Volume mounts for development (optional, not required for production)

**Constraints:**
- Must define both web and web-api services
- Must configure Docker networking for inter-service communication
- Must set restart policies for reliability
- Must use .env file for sensitive environment variables
- Frontend port 80, backend port 3001

**Data requirements:**
- Service definitions: web (frontend), web-api (backend)
- Docker network configuration (default bridge or custom network)
- Environment variables from .env file
- Depends_on directives for service startup order

## Dependencies

**Depends on stories:**
- Story 01: Frontend Docker Container - provides web service image
- Story 02: Backend Docker Container - provides web-api service image

**Enables stories:**
- Story 04: VPS Deployment - orchestration config ready for production
- Local development: developers can run full stack easily

## Out of Scope

- Kubernetes orchestration (future scaling option)
- Multi-environment configs (dev, staging, prod) - single docker-compose for now
- Volume mounts for hot-reload development (nice-to-have, not required)
- External databases or Redis (no database in scope)

## Notes

- Docker Compose automatically creates a network for services to communicate
- nginx in web container will proxy `/api/*` to `http://web-api:3001/api/*`
- .env file should be in .gitignore (use .env.example as template)
- depends_on ensures web starts after web-api (but doesn't wait for health)
- Use healthcheck directives for proper startup sequencing

## Traceability

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

**Related stories:** Story 01 (Frontend Dockerfile), Story 02 (Backend Dockerfile), Story 04 (VPS Deployment)

---

**Next step:** Run `/spec-story .storyline/stories/epic-005/story-03-docker-compose-orchestration.md`
