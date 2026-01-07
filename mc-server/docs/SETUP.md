# BlockHaven Setup Guide

## Quick Start (Local Development)

### Prerequisites
- Docker & Docker Compose installed
- 8GB+ RAM available
- Ports 25565 (Java), 19132 (Bedrock), 8100 (BlueMap), 8804 (Plan) available

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd blockhaven/mc-server
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your settings
   ```

   Required changes:
   - `RCON_PASSWORD`: Set a secure password
   - `SERVER_OPS`: Add your Minecraft username

3. **Start the server:**
   ```bash
   docker-compose up -d
   ```

4. **Monitor startup:**
   ```bash
   docker-compose logs -f minecraft
   ```

   Wait for: `Done (XXs)! For help, type "help"`

5. **Connect to the server:**
   - **Java Edition:** `localhost:25565`
   - **Bedrock Edition:** `localhost:19132`

### First Boot Configuration

After the server starts for the first time:

1. **Verify plugins loaded:**
   ```bash
   docker exec -it blockhaven-mc rcon-cli
   /plugins
   ```

   You should see all 25+ plugins listed in green.

2. **Create worlds** (see [WORLDS.md](WORLDS.md))

3. **Configure LuckPerms** (see [blockhaven-planning-doc.md](../../blockhaven-planning-doc.md) Phase 2)

4. **Set up economy system** (Phase 3)

---

## Production Deployment (Hetzner VPS)

### Option A: DokPloy Deployment (Recommended)

DokPloy provides automated deployment from your GitHub repository.

#### Prerequisites
1. GitHub repository with BlockHaven code
2. Hetzner VPS (CPX31 or higher) with DokPloy installed
3. Domain: `play.blockhaven.gg` pointed to VPS IP

#### Deployment Steps

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Initial BlockHaven setup"
   git push origin main
   ```

2. **Configure DokPloy:**
   - Log into DokPloy dashboard
   - Create new application
   - Connect to GitHub repository
   - Set working directory: `mc-server`
   - Configure environment variables (copy from `.env.example`)

3. **Deploy:**
   - DokPloy will automatically:
     - Pull latest code
     - Build Docker containers
     - Start services
     - Monitor health checks

4. **Configure DNS:**
   ```
   play.blockhaven.gg → <VPS IP>
   ```

5. **Verify deployment:**
   ```bash
   ssh root@<vps-ip>
   docker ps  # Verify containers running
   ```

### Option B: Manual Docker Compose Deployment

#### VPS Setup

1. **SSH into VPS:**
   ```bash
   ssh root@<vps-ip>
   ```

2. **Install Docker:**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

3. **Install Docker Compose:**
   ```bash
   apt install docker-compose-plugin -y
   ```

4. **Clone repository:**
   ```bash
   cd /opt
   git clone <repo-url> blockhaven
   cd blockhaven/mc-server
   ```

5. **Configure environment:**
   ```bash
   cp .env.example .env
   nano .env
   ```

6. **Start services:**
   ```bash
   docker-compose up -d
   ```

7. **Configure firewall:**
   ```bash
   ufw allow 25565/tcp  # Java Edition
   ufw allow 19132/udp  # Bedrock Edition
   ufw allow 8100/tcp   # BlueMap (staff only - add IP restriction)
   ufw allow 8804/tcp   # Plan analytics
   ufw enable
   ```

---

## Post-Deployment Configuration

### Security Hardening

1. **Set up fail2ban:**
   ```bash
   apt install fail2ban -y
   systemctl enable fail2ban
   systemctl start fail2ban
   ```

2. **Configure automatic updates:**
   ```bash
   apt install unattended-upgrades -y
   dpkg-reconfigure -plow unattended-upgrades
   ```

3. **Restrict BlueMap access:**
   - Configure nginx reverse proxy with basic auth
   - OR use IP whitelist in firewall
   - See `plugins/configs/BlueMap/core.conf`

### Monitoring Setup

1. **UptimeRobot:**
   - Monitor: `play.blockhaven.gg:25565`
   - Alert on downtime via Discord webhook

2. **Discord Alerts:**
   - Configure DiscordSRV (see [PLUGINS.md](PLUGINS.md))
   - Set up webhook for server status

3. **Backup Verification:**
   ```bash
   # Test restore process
   ./scripts/restore.sh backups/latest.tar.gz
   ```

### S3 Cloud Backups (Optional)

1. **Configure S3 credentials in `.env`:**
   ```bash
   S3_ACCESS_KEY=your_access_key
   S3_SECRET_KEY=your_secret_key
   S3_BUCKET=blockhaven-backups
   S3_REGION=us-east-1
   ```

2. **Uncomment S3 backup service** in `docker-compose.yml`

3. **Restart services:**
   ```bash
   docker-compose up -d
   ```

---

## Troubleshooting

### Server won't start
```bash
# Check logs
docker-compose logs minecraft

# Common issues:
# - EULA not accepted (should be auto-accepted)
# - Port 25565 already in use
# - Insufficient memory
```

### Plugins not loading
```bash
# Verify plugin downloads
docker-compose logs minecraft | grep -i "plugin"

# Manually check plugins directory
docker exec -it blockhaven-mc ls /data/plugins

# Test single plugin load
docker exec -it blockhaven-mc rcon-cli "/plugins"
```

### Can't connect (Bedrock)
- Verify Geyser and Floodgate are installed
- Check port 19132 UDP is open
- Bedrock players use prefix: `.YourName` (dot before username)

### Out of memory
```bash
# Check Java memory allocation
docker stats blockhaven-mc

# Adjust MEMORY in docker-compose.yml
# Restart: docker-compose restart minecraft
```

### Backup restoration failed
```bash
# Verify backup file
tar -tzf backups/backup.tar.gz

# Manual restore:
docker-compose stop minecraft
tar -xzf backups/backup.tar.gz -C data/
docker-compose start minecraft
```

---

## Useful Commands

### Server Management
```bash
# Start server
docker-compose up -d

# Stop server
docker-compose down

# Restart server
docker-compose restart minecraft

# View logs
docker-compose logs -f minecraft

# Server console (RCON)
docker exec -it blockhaven-mc rcon-cli
```

### Backups
```bash
# Manual backup
./scripts/backup.sh

# List backups
ls -lh backups/

# Restore from backup
./scripts/restore.sh backups/backup-YYYY-MM-DD.tar.gz
```

### Maintenance
```bash
# Update plugins (restart required)
docker-compose pull
docker-compose up -d

# View container stats
docker stats

# Clean up old backups
find backups/ -name "*.tar.gz" -mtime +30 -delete
```

---

## Next Steps

1. ✅ Complete [Phase 2: LuckPerms Configuration](../../blockhaven-planning-doc.md#phase-2-luckperms-configuration)
2. ✅ Set up [Jobs & Economy](../../blockhaven-planning-doc.md#phase-3-jobs-reborn--economy-balancing)
3. ✅ Create all [6 worlds](WORLDS.md)
4. ✅ Configure [PlotSquared](../../blockhaven-planning-doc.md#plotsquared-setup-for-creative-worlds)
5. ✅ Build spawn hub
6. ✅ Test cross-platform (Java + Bedrock)

**See:** [blockhaven-planning-doc.md](../../blockhaven-planning-doc.md) for complete phase-by-phase implementation guide.
