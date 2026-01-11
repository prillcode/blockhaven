# BlockHaven SMP - Minecraft Server Project Planning Document

## Project Overview

**Server Name:** BlockHaven (possibly branded as "BlockHaven SMP" in listings/marketing)

**Domains:** bhsmp.com (marketing website) / play.bhsmp.com (server deployment location)

**Tagline:** Family-Friendly Anti-Griefer Survival & Creative!

**Goal:** Launch a public, family-friendly, grief-free Minecraft server as a monetized business.

**Base Repository:** https://github.com/prillcode/minecraft-crossplatform-docker

**Infrastructure:** Hetzner VPS (starting with CPX31 - 8GB RAM, €14/month, upgrade path to CPX41)

**Platform:** Cross-platform (Java Edition + Bedrock Edition via Geyser/Floodgate)

---

## Update Log

### January 2026 - Plugin Stack Validation
**Updated plugin versions and finalized technology choices for 1.21.11 compatibility:**

**Version Updates:**
- Minecraft version: 1.21.4 → **1.21.11**
- EssentialsX: 2.20.1 → **2.21.2** ("Chase the Skies" update)
- Paper: Updated to latest 1.21.11 build
- All plugins verified compatible with 1.21.11

**Plugin Changes:**
- ✅ **Added:** UltimateLandClaim for land protection (FREE mode with golden shovel)
- ✅ **Added:** VoidGen for void world generation
- ✅ **Added to core:** WorldGuard for spawn/portal protection
- ❌ **Not Added:** PlotSquared - Creative worlds are open creative, not plot-based
- ❌ **Not Added:** Skript - Postponed for future private worlds system
- ⏳ **Postponed:** Shop plugin (ChestShop/QuickShop-Hikari)

**Finalized Decisions:**
- **Land Claims:** UltimateLandClaim in FREE mode (GriefPrevention-style)
- **Creative Worlds:** Open creative mode, not plot-based
- **World Protection:** WorldGuard for spawn/portals, UltimateLandClaim for player claims
- **BlueMap Access:** Staff-only initially, public with rate limiting later
- **Discord Integration:** Moderate features at launch (chat bridge, notifications, staff console) with advanced features planned (economy commands, tickets)

**Important Notes:**
- Mojang changing versioning to 26.1 in 2026 (monitor for breaking changes)
- Deployment method: DokPloy for CI/CD automation

---

## Server Architecture

### Worlds (6 Total)

| World ID | Display Name | Type | Description | Seed | Special Settings |
|----------|--------------|------|-------------|------|------------------|
| `survival_easy` | SMP_Plains | Survival | Easy difficulty, plains biome | 8377987092687320925 | Standard claim blocks, normal job payouts |
| `survival_normal` | SMP_Ravine | Survival | Normal difficulty, ravine terrain | -3821186818266249955 | Standard claim blocks, normal job payouts |
| `survival_hard` | SMP_Cliffs | Survival | Hard difficulty, mountainous cliffs | -8913466909937400889 | Standard claim blocks, higher challenge |
| `creative_flat` | Creative_Plots | Creative | Superflat for creative building | Default FLAT | No claims, frozen time/weather |
| `creative_terrain` | Creative_Hills | Creative | Natural landscape creative building | 3017885471480990383 | No claims, frozen time/weather |
| `spawn` | Spawn_Hub | Adventure | Central hub with portals to all worlds | VoidGen | Protected with WorldGuard, no building |

> **Note:** All worlds created and configured. Creative worlds have `advance_time` and `advance_weather` set to false.

### Inventory Grouping (Multiverse-Inventories)

**Status:** Plugin installed but not yet configured. Planned grouping:

| Group | Worlds | Shares | Rationale |
|-------|--------|--------|-----------|
| **survival** | `survival_easy`, `survival_normal`, `survival_hard`, `spawn` | Inventory + Ender Chest only | Share items across all survival worlds; XP/health/hunger stay per-world |
| **creative_flat** | `creative_flat` | All | Isolated to prevent creative items leaking to survival |
| **creative_terrain** | `creative_terrain` | All | Isolated to prevent creative items leaking to survival |

> **Design Note:** Survival worlds will share inventory but NOT XP, health, or hunger. This prevents exploits (grind XP in easy world, use in hard world) while allowing resource gathering to benefit all survival gameplay. Configuration pending.

### Private Worlds (Premium Feature)

Premium subscribers can create invite-only worlds they control:
- **Family Rank ($9.99/month):** 1 private world
- **VIP Rank ($19.99/month):** 3 private worlds
- **Lifetime VIP ($99.99):** 3 private worlds

World naming convention: `pw_<player_uuid_short>_<worldname>`

---

## Currently Installed Plugin Stack

### Active Plugins (15 Total)

| Plugin | Purpose | Status |
|--------|---------|--------|
| Geyser-Spigot | Bedrock player support | ✅ Installed |
| Floodgate | Bedrock authentication | ✅ Installed |
| UltimateLandClaim | Land claims (survival worlds) | ✅ Installed, needs configuration |
| EssentialsX | Core server features | ✅ Installed |
| Vault | Economy/permissions API | ✅ Installed |
| Jobs Reborn | Job/economy system | ✅ Installed, needs configuration |
| Multiverse-Core | World management | ✅ Installed, worlds created |
| Multiverse-Portals | Portal creation | ✅ Installed |
| Multiverse-NetherPortals | Nether portal linking | ✅ Installed |
| Multiverse-Inventories | Per-world inventories | ✅ Installed, needs configuration |
| LuckPerms | Permissions/ranks | ✅ Installed, portal perms configured |
| WorldEdit | Building tools (staff) | ✅ Installed |
| WorldGuard | Region protection (spawn) | ✅ Installed, needs region setup |
| ViaVersion | Protocol support for older clients | ✅ Installed |
| VoidGen | Void world generation | ✅ Installed |

### Planned But Not Yet Installed

| Plugin | Purpose | Priority |
|--------|---------|----------|
| CoreProtect | Block logging/rollback | High - anti-grief |
| EssentialsXChat | Chat formatting | Medium |
| EssentialsXSpawn | Spawn management | Medium |
| Plan | Analytics dashboard | Medium |
| DiscordSRV | Discord integration | Medium |
| BlueMap | Live web map | Low - resource intensive |
| Harbor | Sleep voting | Low - quality of life |
| PlaceholderAPI | Variable placeholders | Low - dependency for future plugins |
| Shop Plugin | Player shops (ChestShop or QuickShop) | Medium - economy feature |

### Not Using

- **PlotSquared** - Creative worlds are open creative, not plot-based
- **GriefPrevention** - Using UltimateLandClaim instead
- **Skript** - Not needed yet, may add for private worlds later
- **ChatSentry/ChatFilter** - Postponed
- **Grim** - Anti-cheat postponed
- **ZNPCs** - Tutorial system postponed

---

## Docker Configuration

### Directory Structure

```
blockhaven/
├── mc-server/
│   ├── docker-compose.yml
│   ├── .env
│   ├── .env.example
│   ├── scripts/
│   │   ├── download-plugins.sh
│   │   ├── backup.sh
│   │   └── restore.sh
│   ├── config/
│   │   ├── server.properties.template
│   │   ├── spigot.yml.template
│   │   ├── paper-global.yml.template
│   │   └── bukkit.yml.template
│   ├── plugins/
│   │   ├── .gitkeep
│   │   └── configs/           # Plugin config templates
│   │       ├── UltimateLandClaim/
│   │       ├── Jobs/
│   │       ├── EssentialsX/
│   │       ├── Multiverse-Core/
│   │       ├── Multiverse-Inventories/
│   │       ├── LuckPerms/
│   │       ├── WorldGuard/
│   │       └── Geyser-Spigot/
│   ├── data/
│   │   └── .gitkeep
│   ├── backups/
│   │   └── .gitkeep
│   └── docs/
│       ├── SETUP.md
│       ├── PLUGINS.md
│       ├── WORLDS.md
│       └── MONETIZATION.md
├── web/                        # Future: React/Vue marketing website
│   └── .gitkeep
└── README.md                   # Monorepo root README
```

### docker-compose.yml

```yaml
services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: blockhaven-mc
    restart: unless-stopped
    tty: true
    stdin_open: true
    
    ports:
      - "25565:25565"      # Java Edition
      - "19132:19132/udp"  # Bedrock Edition (Geyser)
      - "8100:8100"        # BlueMap web interface
      - "8804:8804"        # Plan analytics
    
    environment:
      # Server Type
      TYPE: PAPER
      VERSION: "1.21.11"
      EULA: "TRUE"
      
      # Memory Settings (6GB for 8GB VPS, leave headroom)
      MEMORY: "6G"
      JVM_XX_OPTS: "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"
      
      # Server Properties
      SERVER_NAME: "BlockHaven"
      MOTD: "§a§lBlockHaven §7- §fFamily-Friendly Anti-Griefer Survival & Creative!"
      MAX_PLAYERS: 100
      DIFFICULTY: normal
      MODE: survival
      PVP: "false"
      ONLINE_MODE: "true"
      SPAWN_PROTECTION: 0
      VIEW_DISTANCE: 10
      SIMULATION_DISTANCE: 8
      MAX_WORLD_SIZE: 10000
      
      # Whitelist (disable for public server)
      ENABLE_WHITELIST: "false"
      
      # RCON for remote management
      ENABLE_RCON: "true"
      RCON_PASSWORD: "${RCON_PASSWORD}"
      RCON_PORT: 25575
      
      # Ops
      OPS: "${SERVER_OPS}"
      
      # Plugin Downloads (auto-download on startup)
      SPIGET_RESOURCES: >-
        1884,
        9089,
        100125,
        4441,
        81534,
        21925,
        19254
      
      # Modrinth plugins
      MODRINTH_PROJECTS: >-
        luckperms,
        multiverse-core,
        multiverse-portals,
        multiverse-inventories,
        worldedit,
        worldguard,
        plotsquared,
        grim,
        bluemap,
        plan,
        skript
      
      # Additional downloads
      MODS_FILE: /extras/plugins.txt
      
      # Timezone
      TZ: "America/New_York"
      
    volumes:
      - ./data:/data
      - ./plugins/configs:/plugins-config:ro
      - ./scripts:/scripts:ro
      - ./extras:/extras:ro
      - ./backups:/backups
    
    healthcheck:
      test: mc-health
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 120s
    
    labels:
      - "com.centurylinklabs.watchtower.enable=false"

  # Backup service - runs every 2 hours
  backup:
    image: itzg/mc-backup
    container_name: blockhaven-backup
    restart: unless-stopped
    environment:
      BACKUP_INTERVAL: "2h"
      RCON_HOST: minecraft
      RCON_PORT: 25575
      RCON_PASSWORD: "${RCON_PASSWORD}"
      BACKUP_METHOD: tar
      PRUNE_BACKUPS_DAYS: 7
      INITIAL_DELAY: 5m
      TAR_COMPRESS_METHOD: gzip
      EXCLUDES: "*.jar,cache,BlueMap/web"
      TZ: "America/New_York"
      # S3 Backup Configuration (optional - enable for cloud backups)
      # DEST_DIR: /backups                    # Local backup location
      # SRC_DIR: /data                        # What to backup
      # Uncomment below for S3 sync after local backup:
      # BACKUP_ON_STARTUP: "false"
      # PRE_BACKUP_SCRIPT: |
      #   echo "Starting backup..."
      # POST_BACKUP_SCRIPT: |
      #   aws s3 sync /backups s3://${S3_BUCKET}/blockhaven-backups/ --delete
    volumes:
      - ./data:/data:ro
      - ./backups:/backups
    depends_on:
      minecraft:
        condition: service_healthy
  
  # Optional: S3 sync service (weekly full backup to S3)
  # Uncomment if you want dedicated S3 backup service
  # s3-backup:
  #   image: amazon/aws-cli
  #   container_name: blockhaven-s3-backup
  #   environment:
  #     AWS_ACCESS_KEY_ID: "${S3_ACCESS_KEY}"
  #     AWS_SECRET_ACCESS_KEY: "${S3_SECRET_KEY}"
  #     AWS_DEFAULT_REGION: "${S3_REGION:-us-east-1}"
  #   volumes:
  #     - ./backups:/backups:ro
  #   entrypoint: >
  #     /bin/sh -c "aws s3 sync /backups s3://${S3_BUCKET}/blockhaven-backups/ --delete"
  #   profiles:
  #     - backup

volumes:
  data:
  backups:
```

### .env.example

```bash
# Server Admin Configuration
RCON_PASSWORD=change_this_to_a_secure_password

# Server Operators (comma-separated for multiple ops)
# Example: SERVER_OPS=PRLLAGER207,AnotherAdmin,ThirdOp
SERVER_OPS=PRLLAGER207

# Optional: Discord Integration
DISCORD_BOT_TOKEN=
DISCORD_CHANNEL_ID=

# Cloud Backup (S3-compatible storage)
# Supports AWS S3, Backblaze B2, Wasabi, MinIO, etc.
S3_ENDPOINT=https://s3.amazonaws.com
S3_BUCKET=blockhaven-backups
S3_ACCESS_KEY=
S3_SECRET_KEY=
S3_REGION=us-east-1
```

### extras/plugins.txt (Additional Plugin Downloads)

```txt
# Geyser and Floodgate (direct downloads)
https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot
https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot

# EssentialsX Suite (GitHub releases) - v2.21.2
https://github.com/EssentialsX/Essentials/releases/latest/download/EssentialsX.jar
https://github.com/EssentialsX/Essentials/releases/latest/download/EssentialsXChat.jar
https://github.com/EssentialsX/Essentials/releases/latest/download/EssentialsXSpawn.jar

# Vault
https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar

# Harbor (sleep voting)
https://github.com/nkomarn/Harbor/releases/latest/download/Harbor.jar

# PlaceholderAPI
https://github.com/PlaceholderAPI/PlaceholderAPI/releases/latest/download/PlaceholderAPI-2.11.6.jar

# DiscordSRV
https://github.com/DiscordSRV/DiscordSRV/releases/latest/download/DiscordSRV-Build-1.28.0.jar

# ZNPCs Plus
https://github.com/Pyrbu/ZNPCsPlus/releases/latest/download/ZNPCsPlus.jar

# ChatSentry
https://github.com/GhastCraftHD/ChatSentry/releases/latest/download/ChatSentry.jar
```

> **Note:** Update version numbers before deployment. The itzg/minecraft-server image handles these downloads automatically on startup.

### SPIGET_RESOURCES Reference

The numbers in `SPIGET_RESOURCES` correspond to SpigotMC resource IDs:
- `1884` - GriefPrevention
- `9089` - Jobs Reborn
- `100125` - QuickShop-Hikari
- `4441` - Plan (Player Analytics)
- `81534` - CoreProtect
- `21925` - WorldGuard
- `19254` - WorldGuard Extra Flags

---

## Implementation Phases

### Phase 1: Docker Foundation ✅ COMPLETE
- [x] Docker Compose configuration
- [x] Plugin auto-download setup
- [x] Directory structure
- [x] Backup automation
- [x] Test deployment on local Docker
- [x] Deploy to Hetzner VPS
- [x] Fix data persistence with named volumes
- [x] Disable Dokploy auto-deployment

### Phase 2: LuckPerms Configuration 🚧 IN PROGRESS
**Goal:** Full rank hierarchy with inheritance, donation perks, and world-specific contexts

**Current Status:**
- [x] LuckPerms installed
- [x] Basic portal permissions configured for default group
- [ ] Full rank hierarchy
- [ ] Donation rank permissions
- [ ] World-specific contexts

**Rank Hierarchy:**
```
default (everyone)
  └── helper (volunteer staff)
        └── moderator (chat mod, support)
              └── admin (full control)

default
  └── friend ($4.99/month)
        └── family ($9.99/month)
              └── vip ($19.99/month)
                    └── lifetime_vip ($99.99 one-time)
```

**Key Configuration Tasks:**
1. Create `luckperms/` config directory with YAML storage
2. Define permission nodes for each rank
3. Set up world-specific contexts (creative fly, survival restrictions)
4. Configure Tebex integration commands for rank assignment
5. Create permission tracks for donation upgrades

**Files to Create:**
- `plugins/configs/LuckPerms/config.yml`
- `plugins/configs/LuckPerms/groups.yml` (exported via /lp export)
- `docs/PERMISSIONS.md` - Permission reference

### Phase 3: Jobs Reborn + Economy Balancing
**Goal:** Job definitions with different payouts for survival worlds

**Jobs to Configure:**
- Miner - Mining ores, stone
- Farmer - Farming crops, breeding animals  
- Builder - Placing blocks
- Hunter - Killing mobs
- Fisherman - Fishing
- Woodcutter - Chopping trees
- Explorer - Discovering new chunks

**Economy Settings:**
- Starting balance: 500 coins
- Max balance: 10,000,000 coins
- Currency name: "coins" (singular: "coin")
- Job payout multipliers: 1.0x base rate (same across all worlds)

**Files to Create:**
- `plugins/configs/Jobs/config.yml`
- `plugins/configs/Jobs/jobConfig.yml`
- `plugins/configs/EssentialsX/config.yml` (economy section)
- `docs/ECONOMY.md` - Economy reference

### Phase 4: World Generation ✅ COMPLETE
**Goal:** Create all 6 worlds with proper settings

**Current Status:**
- [x] All 6 worlds created with specific seeds
- [x] World difficulties configured
- [x] World aliases set (display names)
- [x] Creative worlds have frozen time/weather
- [ ] Multiverse-Inventories groups configured

**Worlds Created:**
1. **spawn** (Spawn_Hub) - VoidGen, adventure mode, peaceful
2. **survival_easy** (SMP_Plains) - Seed: 8377987092687320925, easy difficulty
3. **survival_normal** (SMP_Ravine) - Seed: -3821186818266249955, normal difficulty
4. **survival_hard** (SMP_Cliffs) - Seed: -8913466909937400889, hard difficulty
5. **creative_flat** (Creative_Plots) - FLAT type, creative mode, peaceful
6. **creative_terrain** (Creative_Hills) - Seed: 3017885471480990383, creative mode, peaceful

**Files to Create:**
- `plugins/configs/Multiverse-Core/worlds.yml`
- `plugins/configs/Multiverse-Inventories/config.yml` (world groups)
- `plugins/configs/Multiverse-Inventories/groups.yml`
- `scripts/reset-resource-world.sh` (monthly cron)
- `docs/WORLDS.md` - World reference

**Multiverse-Inventories groups.yml Template:**
```yaml
groups:
  survival:
    worlds:
      - survival_easy
      - survival_hard
      - resource
      - spawn
    shares:
      - inventory      # Hotbar + main inventory
      - ender_chest    # Ender chest contents
      # Excluded: exp, health, hunger, saturation, bed_spawn, potion_effects
      # Each world maintains its own survival state
  
  creative_flat:
    worlds:
      - creative_flat
    shares:
      - all
  
  creative_terrain:
    worlds:
      - creative_terrain
    shares:
      - all
```

> **Survival Group Behavior:** Players carry items between survival worlds, but health, hunger, and XP are per-world. This means dying in `survival_hard` doesn't affect your `survival_easy` health, and XP grinding in `resource` stays in that world.

### Phase 5: UltimateLandClaim Configuration 🚧 NEXT
**Goal:** Configure land claiming system for survival worlds

**Current Status:**
- [x] UltimateLandClaim installed
- [ ] Basic configuration (FREE mode with golden shovel)
- [ ] WorldGuard integration enabled
- [ ] Test claims in survival worlds

**Configuration:**
- Mode: FREE (GriefPrevention-style golden shovel claiming)
- Initial claim blocks: 100
- Blocks earned: Per minute of playtime
- Creative worlds: Claims disabled (open creative mode)
- Spawn: Claims disabled (WorldGuard protected)
- WorldGuard integration: Prevent claiming in protected regions

**Files to Configure:**
- `plugins/configs/UltimateLandClaim/config.yml`
- Enable WorldGuard integration
- Set claim block rates
- Configure golden shovel as claim tool

**See:** [mc-server/docs/IN-GAME-PROTECTION-SETUP.md](mc-server/docs/IN-GAME-PROTECTION-SETUP.md) for step-by-step testing guide

### Phase 6: Private Worlds System
**Goal:** Premium players can create/manage invite-only worlds

**Implementation Approach:** Multiverse-Core + custom Skript for permission/invite management

**Technical Details:**
- Multiverse-Core handles world creation/loading
- Custom Skript manages player permissions, invites, and world ownership
- World data stored in YAML config with owner UUID and invited player list
- Automatic world unloading when empty (configurable timeout)

**Commands:**
- `/pworld create <name>` - Create a private world (checks rank permission)
- `/pworld invite <player>` - Invite player to your world
- `/pworld kick <player>` - Remove player access
- `/pworld list` - List your private worlds
- `/pworld tp <worldname>` - Teleport to your private world
- `/pworld delete <name>` - Delete a private world (confirmation required)

**Permission Nodes:**
- `privateworld.create.1` - Can have 1 private world (Family rank)
- `privateworld.create.3` - Can have 3 private worlds (VIP rank)

**Files to Create:**
- `plugins/configs/Skript/scripts/privateworlds.sk` OR
- Custom Java plugin (if Skript insufficient)
- `docs/PRIVATE-WORLDS.md`

### Phase 7: Monetization Setup
**Goal:** Configure Tebex packages and integrate with server

**Tebex Packages:**
1. **Friend Rank** - $4.99/month subscription
   - Commands: `lp user {username} parent add friend`
   - Expiry: `lp user {username} parent remove friend`

2. **Family Rank** - $9.99/month subscription
   - Commands: `lp user {username} parent add family`
   - Expiry: `lp user {username} parent remove family`

3. **VIP Rank** - $19.99/month subscription
   - Commands: `lp user {username} parent add vip`
   - Expiry: `lp user {username} parent remove vip`

4. **Lifetime VIP** - $99.99 one-time
   - Commands: `lp user {username} parent add lifetime_vip`
   - No expiry

**Files to Create:**
- `docs/MONETIZATION.md` - Full package configs for Tebex import
- `docs/TEBEX-SETUP.md` - Step-by-step Tebex configuration

### Phase 8: Safety & Moderation
**Goal:** Family-friendly chat filtering and moderation tools

**ChatSentry Configuration:**
- Block profanity (extensive wordlist)
- Block URLs (whitelist: YouTube, Imgur, Discord invite for your server)
- Block advertising (other server IPs)
- Caps filter (50% max caps)
- Spam filter (3 messages in 5 seconds)

**Staff Permissions:**
- Helper: `/warn`, `/mute 10m`, `/kick`
- Moderator: `/ban 1d`, `/mute`, `/vanish`, CoreProtect lookup
- Admin: All commands

**Files to Create:**
- `plugins/configs/ChatSentry/config.yml`
- `plugins/configs/ChatSentry/blacklist.txt`
- `docs/MODERATION.md` - Staff guide

### Phase 9: Polish & Launch
**Goal:** Final testing, documentation, marketing prep

**Tasks:**
- [ ] Create spawn hub build (WorldEdit schematic)
- [ ] Configure BlueMap for all worlds (staff-only access initially)
- [ ] Set up Discord server with DiscordSRV integration (moderate features):
  - Chat bridge (bidirectional)
  - Server status notifications
  - Player join/leave announcements
  - Achievement broadcasts
  - Staff channel with read-only console access
  - (Future: advanced features like economy commands, ticket system)
- [ ] Write Terms of Service
- [ ] Write Privacy Policy
- [ ] Create server listing descriptions (PMC, MCSL, etc.)
- [ ] Beta test with friends/family
- [ ] Soft launch
- [ ] Marketing push

---

## Configuration Templates

### Harbor (Sleep Voting) - Per-World Config

`plugins/configs/Harbor/config.yml`:
```yaml
version: 1.6.3

night-skip:
  enabled: true
  mode: percentage
  percentage: 50
  
worlds:
  # Enable sleep voting in survival worlds only
  excluded:
    - creative_flat
    - creative_terrain
    - resource
    - spawn
    # Private worlds will be dynamically added or use wildcard
    
messages:
  chat:
    enabled: true
    sleeping: "&e{player} is now sleeping. ({sleeping}/{needed})"
    skipped: "&eGood morning!"
```

### BlueMap Configuration

`plugins/configs/BlueMap/core.conf`:
```hocon
# Staff-only access initially (can open to public later with rate limiting)
accept-download: false
webserver {
  enabled: true
  port: 8100
  # Restrict access via reverse proxy or firewall rules to staff IPs
}
```

> **Note:** For production, configure nginx reverse proxy with authentication or IP whitelist for staff-only access. Consider opening to public with rate limiting after launch.

### Geyser Configuration

`plugins/configs/Geyser-Spigot/config.yml`:
```yaml
bedrock:
  port: 19132
  motd1: "BlockHaven"
  motd2: "Anti-Griefer Survival & Creative"
  
remote:
  address: auto
  port: 25565
  auth-type: floodgate

# Bedrock player prefix (visible in player list)
floodgate:
  username-prefix: "."
  
# Allow Bedrock resource packs
allow-third-party-capes: true
show-cooldown: title
```

---

## Deployment Checklist

### Deployment Options

**Option A: Dokploy (Recommended)**
If using Dokploy from your dev machine connected to your GitHub repo:
- Push to GitHub triggers automatic deployment
- Dokploy handles container orchestration on Hetzner VPS
- Environment variables configured in Dokploy dashboard
- Simplifies CI/CD workflow

**Option B: Manual Docker Compose**
Direct SSH deployment (steps below)

### Pre-Deployment
- [ ] Copy `.env.example` to `.env` and fill in values
- [ ] Review all plugin config templates
- [ ] Update `extras/plugins.txt` with latest plugin versions
- [ ] Test locally with `docker-compose up`

### Initial Server Setup
- [ ] SSH into Hetzner VPS
- [ ] Install Docker and Docker Compose
- [ ] Clone repository
- [ ] Configure `.env`
- [ ] Run `docker-compose up -d`
- [ ] Verify server starts (check logs: `docker-compose logs -f minecraft`)
- [ ] Connect and verify Geyser works (Java + Bedrock)

### Post-Boot Configuration
- [ ] Accept EULA (should be auto-accepted)
- [ ] Verify all plugins loaded (`/plugins`)
- [ ] Create worlds with Multiverse commands
- [ ] Configure world borders
- [ ] Build spawn hub
- [ ] Test economy (give yourself money, test shops)
- [ ] Test claims (GriefPrevention)
- [ ] Test ranks (LuckPerms)
- [ ] Configure Tebex integration

### Production Hardening
- [ ] Set up firewall (UFW)
- [ ] Configure fail2ban
- [ ] Set up UptimeRobot monitoring
- [ ] Test backup restoration
- [ ] Configure weekly S3 backups
- [ ] Set up Discord webhooks for alerts

---

## Quick Reference Commands

### Docker Commands
```bash
# Start server
docker compose up -d

# View logs
docker compose logs -f minecraft

# Stop server
docker compose down

# Restart server
docker compose restart minecraft

# RCON access
docker exec -i blockhaven-mc rcon-cli

# Manual backup
docker exec blockhaven-backup backup now
```

### Common Server Commands
```bash
# Multiverse
/mv list
/mv tp <world>
/mv create <name> <type>

# LuckPerms
/lp user <player> info
/lp user <player> parent add <rank>
/lp group <group> listmembers

# GriefPrevention
/claimslist <player>
/deleteclaim
/abandonclaim

# CoreProtect
/co inspect
/co rollback u:<player> t:1h
/co lookup u:<player> t:24h
```

---

## Notes for Claude Code

When continuing this project:

1. **Start with Phase 1 validation** - Ensure Docker Compose works locally before proceeding
2. **Create configs incrementally** - Each phase should be testable independently
3. **Use template files** - Plugin configs should be templated and copied on first boot
4. **Document everything** - Each plugin config should have inline comments explaining choices
5. **Test cross-platform** - Always verify both Java and Bedrock clients work after changes

**IMPORTANT - Minecraft Versioning Change (2026):**
> Mojang is changing Minecraft's versioning scheme in 2026. The first release will be version **26.1** instead of continuing the 1.x pattern. This affects:
> - Version parsing in scripts/configs that expect "1.x" format
> - Plugin compatibility checks
> - Docker image version tags
>
> Current deployment uses 1.21.11. Monitor for the 26.1 release and update accordingly.

**Key Design Decisions:**
- Using YAML storage for LuckPerms (not MySQL) - simpler for single-server setup
- Multiverse-Core for world management - well-documented, stable
- **UltimateLandClaim** over GriefPrevention - all-in-one solution with FREE mode
- **Open creative worlds** (not plot-based) - simplified building experience
- VoidGen for void world generation - built-in with Multiverse
- **Docker named volumes** over bind mounts - prevents data loss on redeployment
- Disabled Dokploy auto-deployment - manual control for production Minecraft server

**Resource Constraints:**
- 8GB RAM VPS (6GB to JVM)
- Plan upgrade to 16GB at 30-40 concurrent players
- View distance 10, simulation distance 8 to conserve resources
