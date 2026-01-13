---
epic_id: 005
title: Docker Deployment & Production Release
status: ready_for_stories
source: web/WEB-COMPLETE-PLAN.md
created: 2026-01-10
---

# Epic 005: Docker Deployment & Production Release

## Business Goal

Deploy the BlockHaven marketing website to production on Hetzner VPS with proper containerization, SSL encryption, and monitoring, making it publicly accessible at https://bhsmp.com.

**Target outcome:** A production-ready website running in Docker containers with nginx reverse proxy, SSL certificates, optimized performance (Lighthouse 90+), and zero-downtime deployment capability.

## User Value

**Who benefits:** All BlockHaven server users and potential players

**How they benefit:**
- **Accessibility**: Website is live and accessible 24/7 at a memorable domain (bhsmp.com)
- **Security**: HTTPS encryption protects user data (especially contact form submissions)
- **Performance**: Fast loading times and optimized assets provide smooth experience
- **Reliability**: Containerized deployment ensures consistent uptime and easy recovery

**Current pain point:** Without production deployment, the website only exists locally and cannot attract new players or serve the community.

## Success Criteria

When this epic is complete:

- [ ] Frontend Docker image builds successfully (multi-stage build with nginx)
- [ ] Backend API Docker image builds successfully
- [ ] docker-compose.yml successfully orchestrates both services
- [ ] Website accessible at http://localhost when running locally
- [ ] nginx serves React SPA with proper routing (all routes → index.html)
- [ ] nginx proxies `/api/*` requests to backend container
- [ ] Static assets cached with appropriate headers (1 year expiry)
- [ ] Gzip compression enabled for text files (HTML, CSS, JS)
- [ ] Website deployed to Hetzner VPS at 5.161.69.191
- [ ] DNS A records configured: bhsmp.com and www.bhsmp.com → 5.161.69.191
- [ ] SSL certificates installed via Certbot (Let's Encrypt)
- [ ] HTTPS enforced: HTTP → HTTPS redirect working
- [ ] www → non-www redirect working (www.bhsmp.com → bhsmp.com)
- [ ] All features working in production (server status, contact form, dark mode)
- [ ] Lighthouse performance score ≥90
- [ ] Docker containers restart automatically on failure
- [ ] Environment variables properly configured in production

**Definition of Done:**
- All user stories completed
- Docker images built and tested locally
- docker-compose successfully deploys both services
- Production deployment completed on VPS
- SSL certificates installed and auto-renewal configured
- DNS propagation verified
- All website features tested in production
- Performance audit passed (Lighthouse ≥90)
- Monitoring/alerting configured (optional but recommended)
- Deployment documentation updated

## Scope

### In Scope
- Frontend Dockerfile (multi-stage: build with Node, serve with nginx)
- Backend API Dockerfile (Node.js production build)
- docker-compose.yml (web + web-api services with networking)
- nginx configuration (container nginx.conf for SPA routing and API proxy)
- VPS nginx reverse proxy configuration (/etc/nginx/sites-available/blockhaven)
- SSL certificate installation with Certbot
- DNS configuration (A records for bhsmp.com, www.bhsmp.com)
- Environment variable configuration (.env file setup)
- Production testing checklist (all features, all pages, all devices)
- Performance optimization (bundle size, image compression, caching headers)
- Lighthouse audit and optimization
- Docker ignore files (.dockerignore)
- Restart policies for containers

### Out of Scope
- CI/CD pipeline automation (manual deployment is acceptable for MVP)
- Blue-green or canary deployment strategies
- Multiple environment staging (only production)
- Database deployment (no database in scope)
- CDN integration (not needed for initial launch)
- Advanced monitoring/observability (basic uptime monitoring is sufficient)
- Automated backups (no database to backup)

### Boundaries
This epic handles containerization and production deployment. Application code and features are complete from previous epics. This focuses purely on DevOps and making the site publicly accessible.

## Dependencies

**Depends on:**
- Epic 001: Website Foundation & Theme System - needs complete foundation
- Epic 002: Content Pages & UI Component Library - needs all pages complete
- Epic 003: Backend API Services - needs API ready for deployment
- Epic 004: Interactive Features & Frontend Integration - needs full functionality ready

**Enables:**
- Public launch and marketing activities
- Player acquisition and community growth

## Estimated Stories

**Story count:** ~7 user stories

**Complexity:** Medium

**Estimated effort:** Medium epic (2-3 days)

## Technical Considerations

- **Multi-Stage Docker Build**: Use Node.js to build React app, then copy dist to nginx image to minimize production image size
- **Docker Networking**: Use docker-compose networking to allow web container to communicate with web-api container
- **nginx SPA Routing**: Must configure `try_files $uri $uri/ /index.html` to handle client-side routing
- **SSL Renewal**: Certbot sets up automatic renewal cron job, but verify it's configured correctly
- **Environment Variables**: Must inject at runtime (not build time) for sensitive data like Discord webhook URL
- **Port Mapping**: VPS nginx (host) on 443/80 → web container (port 80) → web-api container (port 3001)
- **Security Headers**: Add X-Frame-Options, X-Content-Type-Options, X-XSS-Protection headers

## Risks & Assumptions

**Risks:**
- SSL certificate setup could fail if DNS not propagated yet (mitigation: verify DNS first, wait for propagation)
- Docker build could fail due to memory constraints on VPS (mitigation: use smaller base images, multi-stage builds)
- VPS firewall could block ports 80/443 (mitigation: verify firewall rules, open necessary ports)
- Discord webhook URL in production environment could be exposed if .env committed (mitigation: ensure .env in .gitignore, use .env.example template)

**Assumptions:**
- Hetzner VPS has sufficient resources (2GB RAM minimum recommended)
- Root or sudo access available on VPS
- Docker and docker-compose can be installed on VPS
- DNS registrar allows A record configuration for bhsmp.com
- No existing services running on ports 80/443 on VPS
- VPS has outbound internet access for Certbot verification

## Related Epics

- Epic 001: Website Foundation & Theme System - deploys foundation
- Epic 002: Content Pages & UI Component Library - deploys content
- Epic 003: Backend API Services - deploys API
- Epic 004: Interactive Features & Frontend Integration - deploys interactive features

## Source Reference

**Original PRD/Spec:** web/WEB-COMPLETE-PLAN.md

**Relevant sections:**
- Phase 5: Docker & Deployment (lines 836-881)
- Docker & Deployment (lines 986-1207)
- Frontend Dockerfile (lines 988-1021)
- Backend API Dockerfile (lines 1025-1048)
- docker-compose.yml (lines 1052-1094)
- nginx configuration (lines 1098-1138, 1142-1188)
- Environment Variables (lines 1192-1207)
- Verification Checklist - Production VPS (lines 1271-1287)

---

**Next step:** Run `/story-creator .storyline/epics/epic-005-docker-deployment-production.md`
