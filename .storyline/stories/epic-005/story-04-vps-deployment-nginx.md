---
story_id: 004
epic_id: 005
title: VPS Deployment with nginx Reverse Proxy
status: ready_for_spec
created: 2026-01-12
---

# Story 004: VPS Deployment with nginx Reverse Proxy

## User Story

**As a** DevOps engineer,
**I want** to deploy the Docker containers to the Hetzner VPS with nginx reverse proxy,
**so that** the website is publicly accessible on the VPS IP address.

## Acceptance Criteria

### Scenario 1: Docker containers running on VPS
**Given** I have SSH access to the Hetzner VPS (5.161.69.191)
**When** I clone the repository and run `docker-compose up -d`
**Then** both web and web-api containers start successfully on the VPS
**And** the containers are running in the background
**And** I can verify with `docker-compose ps` that both services are up

### Scenario 2: Host nginx proxies to Docker containers
**Given** nginx is installed on the VPS host
**When** I configure /etc/nginx/sites-available/blockhaven with reverse proxy rules
**Then** nginx listens on ports 80 and 443
**And** nginx proxies requests to the web container (port 80)
**And** the website is accessible via http://5.161.69.191

### Scenario 3: All website features work in production
**Given** the website is deployed on the VPS
**When** I test all features (server status, contact form, dark mode, copy IP)
**Then** server status widget polls correctly and shows live data
**And** contact form submits successfully to backend API
**And** dark mode persists via localStorage
**And** copy IP button works
**And** all pages load without errors

### Scenario 4: VPS firewall allows web traffic
**Given** the VPS has a firewall configured
**When** I check the firewall rules
**Then** ports 80 (HTTP) and 443 (HTTPS) are open
**And** port 22 (SSH) is open for administration
**And** all other ports are blocked
**And** external users can access the website

## Business Value

**Why this matters:** Deploying to production makes the website publicly accessible, enabling real users to visit, see server status, and submit contact forms.

**Impact:** Moves from local development to live production, making the website available 24/7 to the Minecraft community.

**Success metric:** Website is accessible at http://5.161.69.191, all features work, and the deployment is stable.

## Technical Considerations

**Potential approaches:**
- Host nginx reverse proxy → Docker web container
- Alternative: Traefik reverse proxy (more complex, overkill for single service)
- Alternative: Direct Docker port mapping (less flexible, no SSL termination)

**Constraints:**
- Must use Hetzner VPS at 5.161.69.191
- Must configure host nginx as reverse proxy
- Must open firewall ports 80, 443, 22
- Must ensure Docker installed on VPS
- Must secure SSH access (key-based auth)

**Data requirements:**
- VPS IP: 5.161.69.191
- nginx configuration file: /etc/nginx/sites-available/blockhaven
- Docker Compose orchestration from Story 03
- .env file with environment variables (not committed to git)

## Dependencies

**Depends on stories:**
- Story 01: Frontend Docker Container - image to deploy
- Story 02: Backend Docker Container - image to deploy
- Story 03: Docker Compose orchestration - deployment config

**Enables stories:**
- Story 05: SSL/HTTPS setup - nginx config ready for SSL certificates
- Story 06: DNS setup - VPS ready to receive domain traffic

## Out of Scope

- SSL certificate installation (handled in Story 05)
- DNS configuration (handled in Story 06)
- Automated deployment pipeline (CI/CD future enhancement)
- Load balancing (single VPS sufficient for MVP)
- Blue-green deployment strategy (overkill for MVP)

## Notes

- Hetzner VPS should have Ubuntu 22.04 or 24.04 LTS
- Docker and docker-compose must be installed on VPS
- nginx acts as reverse proxy on the host (outside Docker)
- Use systemd to ensure Docker starts on boot
- Consider using Docker volumes for persistent data (if needed in future)

## Traceability

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

**Related stories:** Story 01-03 (Docker setup), Story 05 (SSL), Story 06 (DNS)

---

**Next step:** Run `/spec-story .storyline/stories/epic-005/story-04-vps-deployment-nginx.md`
