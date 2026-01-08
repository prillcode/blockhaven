# BlockHaven Pre-Deployment Checklist

## Quick Reference: Are You Ready to Deploy?

Use this checklist before deploying to your Hetzner VPS via Dokploy.

---

## ✅ Local Testing (COMPLETED)

- [x] Docker Compose runs successfully
- [x] Server starts without errors
- [x] Connected with Java Edition client
- [x] Verified most plugins loaded (15/19 plugins)
- [x] Basic gameplay tested

### ⚠️ Known Issues to Address Post-Deployment

**Missing Plugins (will auto-download on VPS first boot):**
- Geyser-Spigot (Bedrock support)
- Floodgate-Spigot (Bedrock auth)
- Jobs Reborn (economy)
- QuickShop-Hikari (player shops)
- PlotSquared (creative plots)
- Grim (anti-cheat)
- Harbor (sleep voting)
- ZNPCs (tutorial NPCs)
- ChatSentry (chat filter)
- DiscordSRV (Discord integration)

**Why missing locally?** Some plugins may have failed to download during local testing due to network issues or version mismatches. The itzg/minecraft-server image will retry on VPS deployment.

**Action:** Monitor first VPS deployment logs to ensure all plugins download successfully.

---

## 📋 Repository Preparation

### 1. Commit Recent Changes

```bash
# Add world creation scripts
git add mc-server/scripts/create-worlds.sh
git add mc-server/scripts/create-worlds-rcon.sh
git add mc-server/docs/WORLD-CREATION.md
git add DEPLOYMENT.md
git add PRE-DEPLOYMENT-CHECKLIST.md

# Commit
git commit -m "docs: Add deployment guide and world creation scripts"

# Push to GitHub
git push origin main
```

### 2. Verify .gitignore Works

```bash
# These should NOT be in git (verify):
git check-ignore mc-server/.env          # ✓ Should be ignored
git check-ignore mc-server/data/         # ✓ Should be ignored
git check-ignore mc-server/backups/      # ✓ Should be ignored

# If any show as NOT ignored, fix .gitignore before pushing!
```

### 3. Verify .env.example is Up-to-Date

```bash
# Check .env.example has all required variables
cat mc-server/.env.example

# Should include:
# - RCON_PASSWORD
# - SERVER_OPS
# - DISCORD_BOT_TOKEN (optional)
# - DISCORD_CHANNEL_ID (optional)
# - S3_* variables (optional)
```

✅ **Status:** All verified

---

## 🔐 Production Secrets

### Generate Secure RCON Password

**On your local machine:**
```bash
openssl rand -base64 32
```

**Copy output - you'll paste this into Dokploy environment variables.**

Example output: `8kJ2nP9xL4mQ6rT1vZ3sC5hW7yB0oE4iF8gD2aK6uM=`

⚠️ **IMPORTANT:** Do NOT use `just_another_dev_password_207` in production!

---

## 🌐 DNS Configuration

### Before Deployment, Set These DNS Records:

| Record Type | Name/Host | Value | TTL |
|-------------|-----------|-------|-----|
| **A** | `play.bhsmp.com` | `<your-vps-ip>` | 300 |
| **A** | `map.bhsmp.com` | `<your-vps-ip>` | 300 |
| **A** | `stats.bhsmp.com` | `<your-vps-ip>` | 300 |
| **SRV** | `_minecraft._tcp.bhsmp.com` | `0 5 25565 play.bhsmp.com` | 300 |

### Where to Set DNS:

If `bhsmp.com` is registered:
- Go to your domain registrar (Namecheap, GoDaddy, etc.)
- Navigate to DNS management
- Add the A records above

**Note:** SRV record allows Java players to connect with just `bhsmp.com` (no port). Bedrock players still need port `19132`.

### Verify DNS Propagation

```bash
# After setting DNS, verify:
dig play.bhsmp.com +short
# Should return your VPS IP

# Check SRV record:
dig _minecraft._tcp.bhsmp.com SRV +short
# Should return: 0 5 25565 play.bhsmp.com.
```

---

## 🖥️ VPS Requirements

### Hetzner VPS Specs

**Recommended Instance:** CPX31
- **vCPU:** 4 cores
- **RAM:** 8GB
- **Storage:** 80GB SSD
- **Bandwidth:** 20TB
- **Cost:** ~€14/month

**Upgrade Path:** CPX41 (8GB → 16GB RAM) at 30-40 concurrent players

### VPS Initial Setup (Do This BEFORE Dokploy)

```bash
# SSH into fresh VPS
ssh root@your-vps-ip

# Update system
apt update && apt upgrade -y

# Install Docker (if not already installed by Dokploy)
curl -fsSL https://get.docker.com | sh

# Enable Docker service
systemctl enable docker
systemctl start docker

# Verify Docker is running
docker --version

# Install Docker Compose (if needed)
apt install docker-compose-plugin -y

# Verify
docker compose version
```

---

## 🚀 Dokploy Deployment Configuration

### Install Dokploy (If Not Already Installed)

```bash
# On your VPS
ssh root@your-vps-ip
curl -sSL https://dokploy.com/install.sh | sh

# Access dashboard
# http://your-vps-ip:3000
```

### Dokploy Application Settings

When creating the application in Dokploy:

| Setting | Value |
|---------|-------|
| **Project Name** | `blockhaven` |
| **Application Name** | `blockhaven-minecraft` |
| **Application Type** | Docker Compose |
| **Repository URL** | `https://github.com/YOUR-USERNAME/blockhaven` |
| **Branch** | `main` |
| **Compose File Path** | `mc-server/docker-compose.yml` |
| **Auto Deploy** | Enabled (deploy on git push) |

### Environment Variables to Set in Dokploy

| Variable | Value | Required? |
|----------|-------|-----------|
| `RCON_PASSWORD` | `<from-openssl-rand>` | ✅ Required |
| `SERVER_OPS` | `PRLLAGER207` | ✅ Required |
| `DISCORD_BOT_TOKEN` | *(leave empty)* | ❌ Optional (Phase 9) |
| `DISCORD_CHANNEL_ID` | *(leave empty)* | ❌ Optional (Phase 9) |
| `S3_ACCESS_KEY` | *(leave empty)* | ❌ Optional (later) |
| `S3_SECRET_KEY` | *(leave empty)* | ❌ Optional (later) |
| `S3_ENDPOINT` | `https://s3.amazonaws.com` | ❌ Optional (later) |
| `S3_BUCKET` | `blockhaven-backups` | ❌ Optional (later) |
| `S3_REGION` | `us-east-1` | ❌ Optional (later) |

---

## 🧪 Post-Deployment Verification

### 1. Check Deployment Logs (Dokploy Dashboard)

Watch for:
- ✅ "Server started successfully"
- ✅ All plugins loaded (check for errors)
- ✅ Listening on ports 25565 (Java) and 19132 (Bedrock)

### 2. SSH into VPS and Verify

```bash
ssh root@your-vps-ip

# Check containers running
docker ps
# Should see: blockhaven-mc, blockhaven-backup

# Check logs
docker logs blockhaven-mc -f
# Should show: "Done! For help, type 'help'"

# Test RCON
docker exec -i blockhaven-mc rcon-cli
# Type: /list
# Should return: "There are 0 of a max of 100 players online"
```

### 3. Test Client Connection

**Java Edition:**
```
Server: play.bhsmp.com
Port: (leave default or use 25565)
```

**Bedrock Edition:**
```
Server: play.bhsmp.com
Port: 19132
```

### 4. Verify All Plugins Loaded

```bash
docker exec -i blockhaven-mc rcon-cli "plugins"
```

**Expected plugins (19 total):**
- BlueMap
- CoreProtect
- EssentialsX (+ Chat, Spawn modules)
- Floodgate
- Geyser
- GriefPrevention
- Grim
- Harbor
- Jobs Reborn
- LuckPerms
- Multiverse-Core (+ Inventories, Portals)
- PlaceholderAPI
- Plan
- PlotSquared
- QuickShop-Hikari
- Skript
- Vault
- WorldEdit
- WorldGuard

**If any missing:** Check logs for download errors. May need to manually download and place in `mc-server/data/plugins/`.

---

## 🌍 World Creation (Post-Deployment)

### Do NOT Create Worlds Locally!

Wait until VPS deployment is complete, then follow these steps:

### 1. Choose Seeds

Visit https://www.chunkbase.com/apps/seed-map and find seeds for:

- **survival_easy:** Village-heavy seed (e.g., `8638613833825887773`)
- **survival_hard:** Any seed (AMPLIFIED makes it extreme)
- **creative_terrain:** Scenic seed (e.g., `-1932600624`)
- **resource:** Any seed (resets monthly)

### 2. Update create-worlds-rcon.sh

On your **local machine**:

```bash
# Edit the script
nano mc-server/scripts/create-worlds-rcon.sh

# Replace all instances of YOUR_SEED_HERE with your chosen seeds
# Example:
# -s YOUR_SEED_HERE  →  -s 8638613833825887773

# Save, commit, push
git add mc-server/scripts/create-worlds-rcon.sh
git commit -m "feat: Add production world seeds"
git push origin main
```

### 3. Run World Creation on VPS

```bash
# SSH into VPS
ssh root@your-vps-ip

# Navigate to repo (Dokploy should have cloned it)
cd /path/to/blockhaven  # Find this in Dokploy deployment logs

# Pull latest
git pull origin main

# Make executable
chmod +x mc-server/scripts/create-worlds-rcon.sh

# Run script
./mc-server/scripts/create-worlds-rcon.sh

# Verify worlds created
docker exec -i blockhaven-mc rcon-cli "mv list"
```

**Expected output:**
```
survival_easy - NORMAL
survival_hard - NORMAL (AMPLIFIED)
creative_flat - NORMAL (FLAT)
creative_terrain - NORMAL
resource - NORMAL
spawn - NORMAL (VoidGen)
```

---

## 🔒 Security Hardening (First 24 Hours)

### 1. Configure Firewall (UFW)

```bash
# On VPS
ssh root@your-vps-ip

# Install UFW
apt install ufw -y

# Default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (CRITICAL - do this first!)
ufw allow 22/tcp

# Allow Minecraft
ufw allow 25565/tcp   # Java Edition
ufw allow 19132/udp   # Bedrock Edition (Geyser)

# Restrict BlueMap/Plan to your IP initially
ufw allow from YOUR_HOME_IP to any port 8100  # BlueMap
ufw allow from YOUR_HOME_IP to any port 8804  # Plan

# Enable firewall
ufw enable

# Verify
ufw status verbose
```

### 2. Verify Backups Running

```bash
# Check backup container
docker ps -a | grep backup

# Check backup logs
docker logs blockhaven-backup

# Verify backup files
ls -lh mc-server/backups/
```

### 3. Set Up Uptime Monitoring

1. Create free account: https://uptimerobot.com
2. Add monitor:
   - **Type:** Port Monitoring
   - **Host:** play.bhsmp.com
   - **Port:** 25565
   - **Interval:** 5 minutes
3. Add alert contact (email)

---

## 📊 Phase 1 Completion Checklist

Before moving to Phase 2 (LuckPerms), verify:

- [ ] Server deployed to VPS via Dokploy
- [ ] Can connect with Java Edition client
- [ ] Can connect with Bedrock Edition client (if Geyser loaded)
- [ ] All 19 plugins loaded successfully
- [ ] All 6 worlds created with chosen seeds
- [ ] Firewall configured (UFW)
- [ ] Backups running every 2 hours
- [ ] Uptime monitoring configured
- [ ] DNS records pointing to VPS
- [ ] Can access server via `play.bhsmp.com`

---

## 🎯 Next Steps After Deployment

Once Phase 1 is complete and verified, proceed to:

**Phase 2: LuckPerms Configuration**
- Set up rank hierarchy (default → helper → moderator → admin)
- Set up donation ranks (friend → family → vip → lifetime_vip)
- Configure permissions for each rank
- World-specific contexts (creative fly, survival restrictions)

See [blockhaven-planning-doc.md](blockhaven-planning-doc.md) lines 413-440 for Phase 2 details.

---

## ❓ Need Help?

- **Dokploy Issues:** https://docs.dokploy.com/
- **Plugin Issues:** Check logs with `docker logs blockhaven-mc`
- **Connection Issues:** Verify firewall with `ufw status`
- **World Creation:** See [mc-server/docs/WORLD-CREATION.md](mc-server/docs/WORLD-CREATION.md)

---

**You're ready to deploy! 🚀** Follow [DEPLOYMENT.md](DEPLOYMENT.md) for step-by-step instructions.
