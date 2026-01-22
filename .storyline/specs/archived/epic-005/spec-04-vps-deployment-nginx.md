---
spec_id: 04
story_id: 004
epic_id: 005
title: VPS Deployment with nginx Reverse Proxy
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 04: VPS Deployment with nginx Reverse Proxy

## Overview

**User story:** [.storyline/stories/epic-005/story-04-vps-deployment-nginx.md](../../stories/epic-005/story-04-vps-deployment-nginx.md)

**Goal:** Deploy Docker containers to Hetzner VPS (5.161.69.191) with host nginx as reverse proxy, configure firewall, and ensure website is publicly accessible with all features working.

**Approach:** SSH into VPS, install Docker and Docker Compose, install and configure nginx on host as reverse proxy to Docker containers, configure UFW firewall to allow ports 80/443/22, clone repository, set up .env file, and deploy with docker-compose.

## Technical Design

### Architecture Decision

**Chosen approach:** Host nginx reverse proxy → Docker containers

**Alternatives considered:**
- **Traefik reverse proxy** - More complex setup, overkill for single domain
- **Direct port mapping (no reverse proxy)** - Can't handle SSL termination, less flexible
- **Caddy server** - Simpler SSL but less mature ecosystem
- **nginx inside Docker** - Already have nginx in web container, host nginx better for SSL

**Rationale:** Host nginx provides SSL termination, can serve multiple domains if needed, easier to manage SSL certificates with Certbot, and provides additional layer of configuration control. Docker containers remain portable and isolated.

### System Components

**VPS Infrastructure:**
- Hetzner VPS (5.161.69.191)
- Ubuntu 22.04 or 24.04 LTS
- Docker Engine (latest stable)
- Docker Compose v2
- nginx (host, outside Docker)
- UFW firewall

**Docker services:**
- web (frontend) - port 80 internal
- web-api (backend) - port 3001 internal

**Networking:**
- Host nginx listens on 80/443
- nginx proxies to Docker web container port 80
- Docker internal networking for web ↔ web-api communication

**File locations:**
- `/home/deploy/blockhaven/` - Application directory
- `/etc/nginx/sites-available/blockhaven` - nginx config
- `/etc/nginx/sites-enabled/blockhaven` - Symlink to config
- `/home/deploy/blockhaven/.env` - Environment variables

## Implementation Details

### VPS Setup Steps

#### Step 1: Initial VPS Configuration

**Connect to VPS:**
```bash
ssh root@5.161.69.191
```

**Update system:**
```bash
apt update && apt upgrade -y
```

**Create deployment user:**
```bash
# Create user
adduser deploy
usermod -aG sudo deploy

# Set up SSH key authentication for deploy user
mkdir -p /home/deploy/.ssh
cp /root/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys

# Test login as deploy user
exit
ssh deploy@5.161.69.191
```

#### Step 2: Install Docker

**Install Docker Engine:**
```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add deploy user to docker group
sudo usermod -aG docker deploy

# Logout and login for group changes to take effect
exit
ssh deploy@5.161.69.191

# Verify Docker installation
docker --version
docker compose version
```

**Expected output:**
```
Docker version 24.0.x
Docker Compose version v2.x.x
```

#### Step 3: Install nginx

**Install nginx on host:**
```bash
sudo apt install -y nginx

# Verify installation
nginx -v
sudo systemctl status nginx
```

**Expected:** nginx installed and running

#### Step 4: Configure Firewall

**Set up UFW firewall:**
```bash
# Install UFW (usually pre-installed)
sudo apt install -y ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (IMPORTANT: Do this first!)
sudo ufw allow 22/tcp comment 'SSH'

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Optional: Allow Minecraft server port (if on same VPS)
sudo ufw allow 25565/tcp comment 'Minecraft Server'

# Enable firewall
sudo ufw enable

# Verify rules
sudo ufw status verbose
```

**Expected output:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere    # SSH
80/tcp                     ALLOW       Anywhere    # HTTP
443/tcp                    ALLOW       Anywhere    # HTTPS
25565/tcp                  ALLOW       Anywhere    # Minecraft Server
```

#### Step 5: Clone Repository

**Clone and set up project:**
```bash
# Navigate to home directory
cd /home/deploy

# Install git if not already installed
sudo apt install -y git

# Clone repository (use HTTPS or SSH)
git clone https://github.com/yourusername/blockhaven.git
# OR if using SSH:
# git clone git@github.com:yourusername/blockhaven.git

# Navigate to project
cd blockhaven

# Verify structure
ls -la
```

**Expected:** web/, web-api/, docker-compose.yml, etc.

#### Step 6: Configure Environment Variables

**Create .env file:**
```bash
cd /home/deploy/blockhaven

# Copy example
cp .env.example .env

# Edit with actual values
nano .env
```

**Contents of .env:**
```bash
PORT=3001
NODE_ENV=production

DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_ACTUAL_WEBHOOK_ID/YOUR_ACTUAL_TOKEN

HYPIXEL_API_KEY=your-actual-hypixel-api-key

MINECRAFT_SERVER_IP=5.161.69.191:25565

FRONTEND_URL=http://5.161.69.191
```

**Secure .env file:**
```bash
chmod 600 .env
```

### nginx Configuration

#### `/etc/nginx/sites-available/blockhaven`

**Purpose:** Host nginx configuration for reverse proxy
**Location:** `/etc/nginx/sites-available/blockhaven`

**Implementation:**
```nginx
# ============================================
# BlockHaven Website - nginx Configuration
# ============================================
# Location: /etc/nginx/sites-available/blockhaven
# Enable with: sudo ln -s /etc/nginx/sites-available/blockhaven /etc/nginx/sites-enabled/

# Upstream to Docker web container
upstream docker_web {
    server localhost:80;
}

# HTTP Server (will be upgraded to HTTPS in Spec 05)
server {
    listen 80;
    listen [::]:80;
    server_name 5.161.69.191 bhsmp.com www.bhsmp.com;

    # Logging
    access_log /var/log/nginx/blockhaven-access.log;
    error_log /var/log/nginx/blockhaven-error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Client body size limit (for contact form)
    client_max_body_size 10M;

    # Proxy to Docker web container
    location / {
        proxy_pass http://docker_web;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint (optional, for monitoring)
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

**Enable nginx configuration:**
```bash
# Create symlink to enable site
sudo ln -s /etc/nginx/sites-available/blockhaven /etc/nginx/sites-enabled/

# Remove default nginx site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Deployment Commands

**Deploy application:**
```bash
cd /home/deploy/blockhaven

# Build and start containers
docker compose up -d --build

# Verify containers running
docker compose ps

# Check logs
docker compose logs -f

# Verify health
docker ps
```

**Expected output:**
```
NAME               STATUS           PORTS
blockhaven-web     Up (healthy)     0.0.0.0:80->80/tcp
blockhaven-api     Up (healthy)     0.0.0.0:3001->3001/tcp
```

### Systemd Service (Optional)

**Create systemd service for auto-start:**

**File:** `/etc/systemd/system/blockhaven.service`
```ini
[Unit]
Description=BlockHaven Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/deploy/blockhaven
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

**Enable service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable blockhaven.service
sudo systemctl start blockhaven.service
sudo systemctl status blockhaven.service
```

### Files to Create

1. `/etc/nginx/sites-available/blockhaven` - nginx config (shown above)
2. `/home/deploy/blockhaven/.env` - Environment variables
3. `/etc/systemd/system/blockhaven.service` - Systemd service (optional)

### Files to Modify

None on VPS - all configuration in new files.

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Docker containers running on VPS
**Verification:**
- SSH to VPS: `ssh deploy@5.161.69.191`
- Check containers: `docker compose ps`
- Verify both running: `docker ps | grep blockhaven`
- Check health: Both show "(healthy)" status
- Test locally on VPS: `curl http://localhost/`

**Story criterion 2:** Host nginx proxies to Docker containers
**Verification:**
- Check nginx config: `sudo nginx -t`
- Verify nginx running: `sudo systemctl status nginx`
- Test from outside VPS: `curl http://5.161.69.191/`
- Verify HTML response (homepage)
- Check nginx logs: `sudo tail -f /var/log/nginx/blockhaven-access.log`

**Story criterion 3:** All website features work in production
**Verification:**
- Open browser to http://5.161.69.191
- Test navigation: Home, About, Contact, Rules, Voting
- Test server status widget: Shows online/offline + player count
- Test contact form: Submit test message, check Discord webhook
- Test dark mode: Toggle persists after refresh
- Test copy IP button: Copies 5.161.69.191:25565
- Check browser console: No errors

**Story criterion 4:** VPS firewall allows web traffic
**Verification:**
- Check firewall: `sudo ufw status`
- Verify ports 22, 80, 443 open
- Test SSH: Can connect from local machine
- Test HTTP: `curl http://5.161.69.191/` from local machine
- Test HTTPS: Will be configured in Spec 05
- Test blocked ports: `telnet 5.161.69.191 8080` should fail

## Testing Requirements

### Pre-Deployment Tests

**Test 1: Docker installation**
```bash
docker --version
docker compose version
docker ps
```

**Expected:** Commands work without sudo, versions displayed

**Test 2: nginx installation**
```bash
sudo nginx -t
sudo systemctl status nginx
curl http://localhost/
```

**Expected:** nginx running, responds to requests

**Test 3: Firewall configuration**
```bash
sudo ufw status verbose
```

**Expected:** Ports 22, 80, 443 allowed

### Deployment Tests

**Test 4: Application starts**
```bash
cd /home/deploy/blockhaven
docker compose up -d
sleep 30
docker compose ps
```

**Expected:** Both services up and healthy

**Test 5: Services respond**
```bash
# Test API health
curl http://localhost:3001/health

# Test frontend via Docker
curl http://localhost:80/

# Test frontend via nginx
curl http://localhost/
```

**Expected:** All return 200 OK with content

**Test 6: External access**
```bash
# From local machine
curl http://5.161.69.191/
curl http://5.161.69.191/api/server-status
```

**Expected:** Both work, return content

### Integration Tests

**Scenario 1:** Full deployment from scratch
- Setup: Fresh VPS
- Action: Follow all setup steps
- Assert: Website accessible from internet
- Assert: All features work

**Scenario 2:** Reboot resilience
- Setup: Deployed application
- Action: `sudo reboot`
- Wait: 2 minutes for reboot
- Assert: Docker starts automatically
- Assert: Containers start automatically
- Assert: Website accessible

**Scenario 3:** Update deployment
- Setup: Application running
- Action: `git pull && docker compose up -d --build`
- Assert: Zero-downtime update (or minimal downtime)
- Assert: New version deployed
- Assert: Old containers removed

### Manual Testing Checklist

**VPS Setup:**
- [ ] SSH access works
- [ ] Deploy user created
- [ ] Docker installed and working
- [ ] Docker Compose installed
- [ ] nginx installed and running
- [ ] UFW firewall configured
- [ ] Ports 22, 80, 443 open
- [ ] Repository cloned
- [ ] .env file created and secured

**Deployment:**
- [ ] docker-compose builds successfully
- [ ] Both containers start
- [ ] Both containers healthy
- [ ] Containers auto-restart on failure
- [ ] nginx config valid
- [ ] nginx proxies to containers

**Website Access:**
- [ ] Homepage loads (http://5.161.69.191/)
- [ ] All pages accessible
- [ ] Server status widget works
- [ ] Contact form submits
- [ ] Dark mode works
- [ ] Copy IP button works
- [ ] No console errors
- [ ] No 502/503/504 errors

**System:**
- [ ] VPS survives reboot
- [ ] Docker auto-starts
- [ ] Containers auto-start
- [ ] nginx auto-starts
- [ ] Website accessible after reboot

## Dependencies

**Must complete first:**
- Spec 01: Frontend Docker Container
- Spec 02: Backend Docker Container
- Spec 03: Docker Compose orchestration
- VPS provisioned (Hetzner account)
- SSH access to VPS

**Enables:**
- Spec 05: SSL/HTTPS configuration
- Spec 06: DNS configuration
- Production website accessible

## Risks & Mitigations

**Risk 1:** Docker containers don't auto-start after reboot
**Mitigation:** Use restart: unless-stopped in docker-compose.yml + systemd service
**Fallback:** Manual start via cron @reboot
**Verification:** Test with `sudo reboot`

**Risk 2:** nginx fails to proxy to containers
**Mitigation:** Test nginx config with `sudo nginx -t` before reload
**Fallback:** Revert to previous nginx config
**Verification:** Test with curl from VPS and external

**Risk 3:** Firewall blocks access
**Mitigation:** Set up firewall rules carefully, test before enabling
**Fallback:** `sudo ufw disable` (temporary)
**Verification:** Test access before and after ufw enable

**Risk 4:** .env file missing or wrong permissions
**Mitigation:** Use .env.example as template, document in deployment guide
**Fallback:** Hard-code non-sensitive defaults in code
**Verification:** Test deployment with fresh .env

**Risk 5:** Port conflicts (80/3001 already in use)
**Mitigation:** Check for existing services: `sudo lsof -i :80 -i :3001`
**Fallback:** Use different ports, update nginx config
**Verification:** Test ports before deployment

## Performance Considerations

**VPS Resources:**
- Recommended: 2 vCPU, 4GB RAM, 40GB SSD
- Minimum: 1 vCPU, 2GB RAM, 20GB SSD

**Expected resource usage:**
- Docker containers: ~200-300MB RAM
- nginx: ~10-20MB RAM
- System: ~500MB RAM
- Total: ~800MB RAM used

**Network:**
- Hetzner provides 20TB traffic/month (more than sufficient)
- Expected: <100GB/month for moderate traffic

**Optimization strategies:**
- Enable nginx gzip compression (already in web container)
- Use nginx caching for static assets
- Enable Docker BuildKit for faster builds
- Use Docker layer caching

## Security Considerations

**VPS Security:**
- Use non-root user (deploy) for all operations
- Disable root SSH login (optional but recommended)
- Use SSH key authentication only (disable password auth)
- Keep system updated: `sudo apt update && sudo apt upgrade`

**Firewall:**
- UFW blocks all ports except 22, 80, 443, 25565
- Consider fail2ban for SSH brute force protection
- Monitor logs: `/var/log/auth.log` for suspicious activity

**Application Security:**
- .env file secured (chmod 600)
- Secrets never in git
- Docker containers run as non-root
- nginx security headers configured

**SSH Hardening (Recommended):**
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Recommended changes:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

**Future enhancements:**
- Set up fail2ban for brute force protection
- Implement log rotation and monitoring
- Add automated security updates
- Consider Cloudflare for DDoS protection

## Success Verification

After implementation, verify:
- [ ] VPS setup complete (Docker, nginx, firewall)
- [ ] All setup tests pass
- [ ] All deployment tests pass
- [ ] Manual testing checklist complete
- [ ] Website accessible from internet
- [ ] All features work in production
- [ ] Containers auto-restart
- [ ] System survives reboot
- [ ] Logs accessible and clean
- [ ] Firewall configured correctly
- [ ] No security vulnerabilities exposed

## Traceability

**Parent story:** [.storyline/stories/epic-005/story-04-vps-deployment-nginx.md](../../stories/epic-005/story-04-vps-deployment-nginx.md)

**Parent epic:** [.storyline/epics/epic-005-docker-deployment-production.md](../../epics/epic-005-docker-deployment-production.md)

## Implementation Notes

**Deployment Workflow:**
1. Initial setup (once): VPS provisioning, Docker/nginx install, firewall
2. Application deployment: Clone repo, configure .env, docker-compose up
3. Updates: git pull, docker-compose up -d --build

**Docker auto-start:**
- Docker service auto-starts on boot (enabled by default)
- Containers auto-restart with `restart: unless-stopped`
- Optional: systemd service for explicit control

**nginx best practices:**
- Keep default nginx.conf unchanged
- Put site configs in sites-available
- Use symlinks to sites-enabled
- Test config before reload: `sudo nginx -t`

**Zero-downtime deployments:**
- Current setup has brief downtime during docker-compose restart
- For true zero-downtime: Use rolling updates or blue-green deployment
- MVP: Accept brief downtime during updates

**Monitoring:**
- Check logs: `docker compose logs -f`
- Check container health: `docker ps`
- Check nginx logs: `sudo tail -f /var/log/nginx/blockhaven-*.log`
- Consider adding monitoring tools: Prometheus, Grafana, Uptime Robot

**Backup strategy:**
- Code: In git repository (already backed up)
- .env file: Backup separately (encrypted)
- No database to backup
- Docker images: Rebuild from source

**Troubleshooting:**
```bash
# Container issues
docker compose ps
docker compose logs web
docker compose logs web-api
docker compose restart

# nginx issues
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log

# Firewall issues
sudo ufw status
sudo ufw allow 80/tcp
sudo systemctl status ufw

# Network issues
curl http://localhost/
netstat -tulpn | grep :80
```

**Future enhancements:**
- Implement CI/CD pipeline (GitHub Actions)
- Add monitoring and alerting
- Set up automated backups
- Implement blue-green deployment
- Add staging environment

---

**Next step:** Run `/dev-story .storyline/specs/epic-005/spec-04-vps-deployment-nginx.md`
