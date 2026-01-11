# BlockHaven Deployment Guide

## Pre-Deployment Checklist

Before deploying to your Hetzner VPS via Dokploy, complete these steps:

### 1. Local Testing ✅ (COMPLETED)
- [x] Docker Compose runs successfully
- [x] Server starts and accepts connections
- [x] Plugins load correctly
- [x] Basic gameplay works (Java + Bedrock)

### 2. Repository Preparation

#### Commit World Creation Scripts
```bash
git add mc-server/scripts/create-worlds.sh
git add mc-server/scripts/create-worlds-rcon.sh
git add mc-server/docs/WORLD-CREATION.md
git commit -m "docs: Add world creation scripts and documentation"
git push origin main
```

#### Verify .gitignore is Correct
Check that sensitive data is NOT committed:
```bash
# These should be ignored (verify they're not in git):
git check-ignore mc-server/.env          # Should be ignored
git check-ignore mc-server/data/         # Should be ignored
git check-ignore mc-server/backups/      # Should be ignored
```

### 3. Production Environment Variables

On your **Dokploy dashboard** (or VPS), you'll need to set these environment variables:

#### Required Variables
```bash
# CRITICAL: Change this to a strong password!
RCON_PASSWORD=<generate-secure-password-here>

# Your Minecraft username (must match exactly)
SERVER_OPS=PRLLAGER207
```

**Generate a secure RCON password:**
```bash
# On your local machine, run:
openssl rand -base64 32
# Copy output to RCON_PASSWORD in Dokploy
```

#### Optional Variables (Add Later)
```bash
# Discord Integration (Phase 9)
DISCORD_BOT_TOKEN=<from-discord-developer-portal>
DISCORD_CHANNEL_ID=<your-discord-channel-id>

# Cloud Backups (Recommended after launch)
S3_ENDPOINT=https://s3.amazonaws.com
S3_BUCKET=blockhaven-backups
S3_ACCESS_KEY=<your-s3-access-key>
S3_SECRET_KEY=<your-s3-secret-key>
S3_REGION=us-east-1
```

### 4. VPS Requirements

#### Minimum Hetzner VPS Specs
- **Instance:** CPX31 (4 vCPU, 8GB RAM)
- **Storage:** 80GB+ SSD
- **Location:** Your choice (consider player base location)
- **OS:** Ubuntu 22.04 LTS (or Debian 11+)

#### Required VPS Setup (Dokploy handles most of this)
- Docker installed
- Docker Compose installed
- Firewall configured (ports 25565, 19132, 8100, 8804)

### 5. Domain/DNS Configuration

Before deploying, ensure DNS is configured:

#### A Records
| Subdomain | Type | Value |
|-----------|------|-------|
| `play.bhsmp.com` | A | `<your-vps-ip>` |
| `map.bhsmp.com` | A | `<your-vps-ip>` |
| `stats.bhsmp.com` | A | `<your-vps-ip>` |

#### SRV Record (Optional - allows players to use `bhsmp.com` without port)
| Name | Type | Priority | Weight | Port | Target |
|------|------|----------|--------|------|--------|
| `_minecraft._tcp.bhsmp.com` | SRV | 0 | 5 | 25565 | `play.bhsmp.com` |

**Note:** SRV records don't work for Bedrock Edition. Bedrock players must use `play.bhsmp.com:19132`.

---

## Dokploy Deployment Steps

### Step 1: Access Dokploy Dashboard

1. Install Dokploy on your Hetzner VPS (if not already done):
   ```bash
   ssh root@your-vps-ip
   curl -sSL https://dokploy.com/install.sh | sh
   ```

2. Access Dokploy dashboard at `http://your-vps-ip:3000`

### Step 2: Create New Project

1. Click **"Create Project"**
2. **Project Name:** `blockhaven`
3. **Description:** "Family-friendly Minecraft SMP"

### Step 3: Create Application

1. Inside the `blockhaven` project, click **"Create Application"**
2. **Application Type:** Docker Compose
3. **Name:** `blockhaven-minecraft`
4. **Repository:** `https://github.com/YOUR-USERNAME/blockhaven` (or your repo URL)
5. **Branch:** `main`
6. **Compose File Path:** `mc-server/docker-compose.yml`

### Step 4: Configure Environment Variables

In the Dokploy dashboard, add these environment variables:

| Variable | Value | Notes |
|----------|-------|-------|
| `RCON_PASSWORD` | `<secure-password>` | Generate with `openssl rand -base64 32` |
| `SERVER_OPS` | `PRLLAGER207` | Your Minecraft username |
| `DISCORD_BOT_TOKEN` | *(leave empty for now)* | Add in Phase 9 |
| `DISCORD_CHANNEL_ID` | *(leave empty for now)* | Add in Phase 9 |
| `S3_ACCESS_KEY` | *(leave empty for now)* | Add when setting up cloud backups |
| `S3_SECRET_KEY` | *(leave empty for now)* | Add when setting up cloud backups |

### Step 5: Configure Volumes (Persistent Data)

Dokploy should auto-detect volumes from `docker-compose.yml`, but verify:

- `/data` - Server world data (persistent)
- `/backups` - Server backups (persistent)
- `/plugins/configs` - Plugin configurations (read-only from repo)

### Step 6: Deploy

1. Click **"Deploy"** in Dokploy dashboard
2. Monitor deployment logs
3. Wait for "Server started successfully" message

### Step 7: Verify Deployment

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Check containers are running
docker ps

# Check Minecraft server logs
docker logs blockhaven-mc -f

# Test RCON connection
docker exec -i blockhaven-mc rcon-cli
# Type: /list
# Should see "There are 0 of a max of 100 players online"
```

### Step 8: Test Connection

**Java Edition:**
```
Server Address: play.bhsmp.com:25565
```

**Bedrock Edition:**
```
Server Address: play.bhsmp.com
Port: 19132
```

---

## Post-Deployment Tasks

### 1. Create Worlds

Once the server is running on VPS, create your custom worlds:

#### Choose Your Seeds First
1. Visit https://www.chunkbase.com/apps/seed-map
2. Find seeds for:
   - `survival_easy` - Village-heavy seed
   - `survival_hard` - Any seed (AMPLIFIED makes it extreme)
   - `creative_terrain` - Scenic seed
   - `resource` - Any seed

#### Update and Run Script

On your **local machine**:

1. Edit `mc-server/scripts/create-worlds-rcon.sh`
2. Replace all `YOUR_SEED_HERE` with chosen seeds
3. Save and commit:
   ```bash
   git add mc-server/scripts/create-worlds-rcon.sh
   git commit -m "feat: Add production world seeds"
   git push origin main
   ```

On your **VPS** (SSH):

```bash
# Navigate to repo directory
cd /path/to/blockhaven

# Pull latest changes
git pull origin main

# Make script executable
chmod +x mc-server/scripts/create-worlds-rcon.sh

# Run world creation
./mc-server/scripts/create-worlds-rcon.sh

# Verify worlds created
docker exec -i blockhaven-mc rcon-cli "mv list"
```

### 2. Configure Firewall (UFW)

```bash
# Allow SSH (if not already allowed)
ufw allow 22/tcp

# Allow Minecraft Java Edition
ufw allow 25565/tcp

# Allow Minecraft Bedrock Edition (Geyser)
ufw allow 19132/udp

# Allow BlueMap (restrict to your IP initially)
ufw allow from YOUR_HOME_IP to any port 8100

# Allow Plan Analytics (restrict to your IP initially)
ufw allow from YOUR_HOME_IP to any port 8804

# Enable firewall
ufw enable

# Verify rules
ufw status
```

### 3. Set Up Reverse Proxy (Optional - Recommended for BlueMap/Plan)

Use Dokploy's built-in reverse proxy or nginx to expose BlueMap and Plan with proper domains:

#### BlueMap
- URL: `https://map.bhsmp.com`
- Internal Port: `8100`
- Add authentication (basic auth or Cloudflare Access)

#### Plan Analytics
- URL: `https://stats.bhsmp.com`
- Internal Port: `8804`
- Add authentication

### 4. Configure Backups

#### Local Backups (Already Running)
The `backup` service runs every 2 hours automatically. Verify:

```bash
# Check backup logs
docker logs blockhaven-backup

# List backups
ls -lh mc-server/backups/
```

#### Cloud Backups (Recommended)

**Option A: Backblaze B2 (Recommended - Cheapest)**
1. Create Backblaze B2 account
2. Create bucket: `blockhaven-backups`
3. Generate API keys
4. Add to Dokploy environment variables:
   ```bash
   S3_ENDPOINT=https://s3.us-west-002.backblazeb2.com
   S3_BUCKET=blockhaven-backups
   S3_ACCESS_KEY=<your-key-id>
   S3_SECRET_KEY=<your-application-key>
   S3_REGION=us-west-002
   ```
5. Redeploy application

**Option B: AWS S3**
Same process, use AWS S3 endpoint and credentials.

### 5. Verify Plugin Functionality

Connect to the server and test:

```bash
# In-game or via RCON:
/plugins                    # All plugins green
/mv list                    # All worlds listed
/lp listgroups              # LuckPerms working
/jobs browse                # Jobs Reborn working
/co inspect                 # CoreProtect working
```

---

## Monitoring & Maintenance

### Health Checks

**Automated (Already Configured):**
- Docker healthcheck runs every 30s
- Automatic restart on failure

**Manual Monitoring:**
```bash
# Server status
docker ps

# Server logs
docker logs blockhaven-mc -f

# Backup logs
docker logs blockhaven-backup -f

# Resource usage
docker stats blockhaven-mc
```

### Uptime Monitoring

Set up UptimeRobot (free tier):
1. Create account at https://uptimerobot.com
2. Add monitor: `play.bhsmp.com:25565` (port monitoring)
3. Get alerts on downtime

### Performance Monitoring

Use **Plan** (already installed):
- Access: `http://your-vps-ip:8804`
- Or via reverse proxy: `https://stats.bhsmp.com`
- Monitor player count, TPS, resource usage

### Log Rotation

Logs are in `mc-server/data/logs/`. Set up rotation:

```bash
# Create logrotate config
sudo nano /etc/logrotate.d/minecraft

# Add:
/path/to/blockhaven/mc-server/data/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

---

## Rollback Procedure (If Deployment Fails)

### Quick Rollback
```bash
# In Dokploy dashboard:
1. Go to Deployments tab
2. Click "Rollback" on previous working deployment
```

### Manual Rollback
```bash
# SSH into VPS
docker-compose down
git checkout <previous-commit-hash>
docker-compose up -d
```

### Restore from Backup
```bash
# Stop server
docker-compose down

# Restore backup
cd mc-server
tar -xzf backups/backup-YYYY-MM-DD-HH-MM-SS.tar.gz -C data/

# Start server
docker-compose up -d
```

---

## Next Phases After Deployment

Once deployed and worlds are created:

1. **Phase 2:** LuckPerms rank configuration
2. **Phase 3:** Jobs Reborn economy setup
3. **Phase 4:** PlotSquared plot configuration
4. **Phase 5:** GriefPrevention claim rates
5. **Phase 6:** Private worlds system (Skript)
6. **Phase 7:** Tebex monetization
7. **Phase 8:** Chat filtering (ChatSentry)
8. **Phase 9:** Spawn build, Discord integration, launch!

See [blockhaven-planning-doc.md](blockhaven-planning-doc.md) for full phase details.

---

## Troubleshooting

### Server Won't Start
```bash
# Check logs
docker logs blockhaven-mc --tail 100

# Common issues:
# - EULA not accepted (should be auto-accepted)
# - Port already in use (check with: lsof -i :25565)
# - Out of memory (check VPS specs)
```

### Can't Connect (Java Edition)
- Verify firewall: `ufw status`
- Check port forwarding: `telnet play.bhsmp.com 25565`
- Verify online-mode in server.properties

### Can't Connect (Bedrock Edition)
- Verify UDP port 19132 is open: `ufw status`
- Check Geyser plugin loaded: `/plugins`
- Verify Geyser config: `mc-server/data/plugins/Geyser-Spigot/config.yml`

### Plugins Not Loading
```bash
# Check plugin JARs exist
docker exec -i blockhaven-mc ls -la /data/plugins/

# Check for errors in logs
docker logs blockhaven-mc | grep -i error

# Verify plugin compatibility
# All plugins should be 1.21.1+ compatible
```

### RCON Not Working
```bash
# Verify RCON password matches .env
docker exec -i blockhaven-mc rcon-cli

# If fails, check server.properties
docker exec -i blockhaven-mc cat /data/server.properties | grep rcon
```

### Backups Not Running
```bash
# Check backup container status
docker ps -a | grep backup

# Check backup logs
docker logs blockhaven-backup

# Verify RCON connection (backups use RCON)
docker exec -i blockhaven-backup env | grep RCON
```

---

## Support Resources

- **Dokploy Docs:** https://docs.dokploy.com/
- **itzg/minecraft-server:** https://docker-minecraft-server.readthedocs.io/
- **Paper Docs:** https://docs.papermc.io/
- **Multiverse Wiki:** https://github.com/Multiverse/Multiverse-Core/wiki

---

## Security Checklist

Before going public:

- [ ] Strong RCON password set
- [ ] Firewall configured (UFW)
- [ ] BlueMap/Plan restricted to staff IPs or behind auth
- [ ] Regular backups running and tested
- [ ] Cloud backups configured
- [ ] Uptime monitoring set up
- [ ] fail2ban configured (optional but recommended)
- [ ] SSH key authentication enabled (disable password auth)
- [ ] Non-root user for SSH access

---

**Ready to deploy?** Follow the steps above and you'll have BlockHaven running on your VPS in no time! 🚀
