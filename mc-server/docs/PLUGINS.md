# BlockHaven Plugin Guide

## Plugin Stack Overview

BlockHaven uses 25+ plugins across multiple categories for grief prevention, economy, multi-world management, and cross-platform support.

---

## Core Plugins

### Cross-Platform Support

#### **Geyser-Spigot** + **Floodgate-Spigot**
- **Purpose:** Allow Bedrock Edition players to join Java Edition server
- **Configuration:** `plugins/configs/Geyser-Spigot/config.yml`
- **Bedrock Port:** 19132 UDP
- **Player Prefix:** `.` (dot before username)
- **Documentation:** https://geysermc.org/

**Key Settings:**
```yaml
bedrock:
  port: 19132
  motd1: "BlockHaven"
  motd2: "Anti-Griefer Survival & Creative"
remote:
  address: auto
  port: 25565
  auth-type: floodgate
```

---

### Grief Prevention & Land Claims

#### **GriefPrevention**
- **Purpose:** Land claims system for survival worlds
- **Per-World Rates:**
  - `survival_easy`: 200 blocks/hour (2x multiplier)
  - `survival_hard`: 50 blocks/hour (0.5x multiplier)
  - Creative/Resource: Claims disabled
- **Commands:**
  - `/claim` - Create claim with golden shovel
  - `/abandonclaim` - Delete current claim
  - `/trust <player>` - Give build permission
  - `/accesstrust <player>` - Allow container/button access
  - `/claimslist` - List all your claims

**Configuration:** See Phase 5 in planning doc

---

### Permissions & Ranks

#### **LuckPerms**
- **Purpose:** Permission management and rank system
- **Storage:** YAML (local files)
- **Web Editor:** https://luckperms.net/editor

**Rank Hierarchy:**
```
Staff Ranks:                 Donor Ranks:
default                      default
  └── helper                   └── friend ($4.99/mo)
        └── moderator                └── family ($9.99/mo)
              └── admin                    └── vip ($19.99/mo)
                                                └── lifetime_vip ($99.99)
```

**Key Commands:**
```bash
/lp user <player> info                    # View player info
/lp user <player> parent add <rank>       # Add rank
/lp user <player> permission set <perm>   # Set permission
/lp editor                                # Open web editor
```

---

### Economy System

#### **Jobs Reborn**
- **Purpose:** Earn money by performing job tasks
- **World Multipliers:**
  - `survival_easy`: 1.0x payout
  - `survival_hard`: 1.5x payout

**Available Jobs:**
- Miner - Mine ores and stone
- Farmer - Farm crops, breed animals
- Builder - Place blocks
- Hunter - Kill mobs
- Fisherman - Catch fish
- Woodcutter - Chop trees
- Explorer - Discover new chunks

**Commands:**
```bash
/jobs browse           # View available jobs
/jobs join <job>       # Join a job
/jobs leave <job>      # Leave a job
/jobs stats            # View earnings
```

#### **QuickShop-Hikari**
- **Purpose:** Player-run chest shops
- **Better than ChestShop:** More actively maintained, better 1.21+ support
- **Commands:**
  ```bash
  /qs create <price>     # Create shop (punch chest)
  /qs buy               # Buy mode
  /qs sell              # Sell mode
  /qs remove            # Delete shop
  /qs price <price>     # Change price
  ```

#### **Vault**
- **Purpose:** Economy API (bridges EssentialsX economy with other plugins)
- **No configuration needed** - automatically integrates

---

### World Management

#### **Multiverse-Core** + **Multiverse-Portals** + **Multiverse-Inventories**
- **Purpose:** Manage 6 worlds + private worlds
- **Inventory Groups:**
  - `survival`: survival_easy, survival_hard, resource, spawn (share inventory only)
  - `creative_flat`: isolated
  - `creative_terrain`: isolated

**Key Commands:**
```bash
/mv list                           # List all worlds
/mv tp <world>                     # Teleport to world
/mv create <name> <type>           # Create world
/mv modify set difficulty <diff>   # Set difficulty
/mvinv toggle                      # Toggle inventory sharing
```

**See:** [WORLDS.md](WORLDS.md) for complete setup

---

### Plot Management (Creative Worlds)

#### **PlotSquared v7**
- **Purpose:** Creative plot system
- **Plot Sizes:**
  - `creative_flat`: 64x64 blocks
  - `creative_terrain`: 128x128 blocks

**Max Plots by Rank:**
- Default: 3 plots
- Friend: 5 plots
- Family: 10 plots
- VIP: 20 plots
- Lifetime VIP: Unlimited

**Commands:**
```bash
/plot auto              # Auto-claim nearest plot
/plot claim             # Claim plot you're standing in
/plot add <player>      # Add player to plot
/plot remove <player>   # Remove player from plot
/plot trust <player>    # Give build permission
/plot clear             # Clear plot (confirmation required)
/plot delete            # Delete plot claim
```

---

### Logging & Rollback

#### **CoreProtect**
- **Purpose:** Block logging and rollback (anti-grief recovery)
- **Database:** SQLite (auto-created)

**Key Commands:**
```bash
/co inspect              # Toggle inspector (right-click blocks)
/co rollback u:<player> t:1h r:50    # Rollback player actions
/co restore u:<player> t:1h          # Restore rollback
/co lookup u:<player> t:24h          # View player actions
/co purge t:30d          # Delete logs older than 30 days (staff only)
```

**Staff Usage:**
- Moderators: Inspect, lookup
- Admins: Rollback, restore, purge

---

### Anti-Cheat

#### **Grim Anticheat**
- **Purpose:** Detect and prevent cheating
- **Geyser Compatible:** Bedrock players fully exempted (requires Floodgate)
- **Free & Open Source**

**Configuration:**
- Auto-configured for Bedrock exemption
- Alerts sent to staff with `griefac.alerts` permission
- Ban threshold: Configurable in `config.yml`

---

### Chat & Moderation

#### **ChatSentry**
- **Purpose:** Family-friendly chat filtering
- **Blocks:**
  - Profanity (configurable wordlist)
  - Server advertising (IPs)
  - Spam (3 messages in 5 seconds)
  - Excessive caps (>50%)
  - URLs (whitelist: YouTube, Imgur, your Discord)

**Staff Commands:**
```bash
/warn <player> <reason>     # Warn player (Helper+)
/mute <player> <time>       # Temp mute (Moderator+)
/unmute <player>            # Unmute
/kick <player> <reason>     # Kick (Helper+)
/ban <player> <time>        # Temp ban (Moderator+)
```

---

### Analytics & Monitoring

#### **Plan (Player Analytics)**
- **Purpose:** Server analytics dashboard
- **Web Interface:** http://play.bhsmp.com:8804
- **Tracks:**
  - Player activity
  - Peak times
  - TPS performance
  - Plugin performance
  - Geolocation data

**Access:** Staff only (configure in LuckPerms)

---

### Map Visualization

#### **BlueMap**
- **Purpose:** 3D web-based live map
- **Web Interface:** http://play.bhsmp.com:8100
- **Access:** Staff-only initially, public with rate limiting later
- **Performance:** Much better than Dynmap (async rendering, WebGL)

**Configuration:**
```hocon
# plugins/configs/BlueMap/core.conf
webserver {
  enabled: true
  port: 8100
}
```

**Staff Access:** Configure nginx reverse proxy or IP whitelist

---

### Discord Integration

#### **DiscordSRV**
- **Purpose:** Bridge Minecraft chat with Discord
- **Features:**
  - Bidirectional chat bridge
  - Join/leave announcements
  - Achievement broadcasts
  - Server status notifications
  - Staff console channel (read-only RCON)

**Setup:**
1. Create Discord bot: https://discord.com/developers/applications
2. Get bot token and channel IDs
3. Configure in `.env`:
   ```bash
   DISCORD_BOT_TOKEN=your_token
   DISCORD_CHANNEL_ID=your_channel_id
   ```
4. Restart server

**Future Advanced Features:**
- Economy commands from Discord
- Ticket system integration
- Automated moderation actions

---

### Utilities

#### **EssentialsX** + **EssentialsXChat** + **EssentialsXSpawn**
- **Purpose:** Core server utilities
- **Features:**
  - `/spawn`, `/sethome`, `/home`
  - Chat formatting
  - Spawn management
  - Economy backend (integrated with Vault)
  - Kits, warps, and more

**Key Commands:**
```bash
/spawn                 # Teleport to spawn
/sethome [name]        # Set home
/home [name]           # Teleport home
/tpa <player>          # Request teleport
/tpaccept              # Accept TP request
/kit                   # View available kits
```

#### **WorldEdit** + **WorldGuard**
- **Purpose:** Building tools and region protection (staff only)
- **WorldEdit:** Copy/paste, terrain manipulation
- **WorldGuard:** Protect spawn hub, create safe zones

**Staff Commands:**
```bash
//wand                 # Get selection wand
//copy                 # Copy selection
//paste                # Paste clipboard
/rg define <name>      # Create protected region
/rg flag <region> pvp deny    # Set region flag
```

#### **PlaceholderAPI**
- **Purpose:** Variable placeholders for other plugins
- **Used by:** Chat plugins, scoreboard, tab list
- **Auto-configured** - no manual setup needed

#### **Harbor**
- **Purpose:** Sleep voting (skip night when 50% of players sleep)
- **Enabled Worlds:** `survival_easy`, `survival_hard` only
- **Excluded:** Creative, resource, spawn, private worlds

---

## Private Worlds Plugin (Custom)

### **Skript: privateworlds.sk**
- **Purpose:** Player-owned invite-only worlds
- **Implementation:** Custom Skript + Multiverse-Core
- **Commands:**
  ```bash
  /pworld create <name>       # Create private world (Family+)
  /pworld invite <player>     # Invite player
  /pworld kick <player>       # Remove access
  /pworld list                # List your worlds
  /pworld tp <worldname>      # Teleport to world
  /pworld delete <name>       # Delete world (confirmation)
  ```

**World Limits:**
- Family: 1 private world
- VIP: 3 private worlds
- Lifetime VIP: 3 private worlds

**Implementation:** See Phase 6 in planning doc

---

## Plugin Update Process

### Automatic Updates (via Docker)
Plugins are auto-downloaded on server startup via:
- **SPIGET_RESOURCES** (SpigotMC)
- **MODRINTH_PROJECTS** (Modrinth)
- **MODS_FILE** (extras/plugins.txt - direct URLs)

### Manual Update
```bash
# 1. Stop server
docker-compose down

# 2. Update docker-compose.yml or plugins.txt with new versions
# 3. Remove old plugins
rm -rf data/plugins/*.jar

# 4. Restart (will download fresh)
docker-compose up -d
```

### Testing Updates
Always test plugin updates on a local instance before deploying to production!

---

## Plugin Compatibility

All plugins verified compatible with:
- **Minecraft:** 1.21.11 (Java Edition)
- **Paper:** 1.21.11 build
- **Geyser:** Bedrock 1.21.111-1.21.131

**Important:** Mojang is changing versioning to 26.1 in 2026. Monitor plugin compatibility.

---

## Troubleshooting

### Plugin Not Loading
```bash
# Check plugin file exists
docker exec -it blockhaven-mc ls /data/plugins

# View plugin errors
docker-compose logs minecraft | grep -i "error\|exception"

# Verify dependencies (e.g., Vault required for economy)
docker exec -it blockhaven-mc rcon-cli "/plugins"
```

### Permissions Not Working
```bash
# Verify LuckPerms loaded
/lp info

# Check user permissions
/lp user <player> permission check <permission>

# Reload permissions
/lp sync
```

### Economy Not Working
```bash
# Verify Vault loaded
/plugins

# Check balance
/balance

# Jobs not paying? Check world multipliers in Jobs config
```

---

## Next Steps

1. Configure each plugin per implementation phases
2. See [blockhaven-planning-doc.md](../../blockhaven-planning-doc.md) for detailed phase-by-phase setup
3. Join our Discord for plugin support: [link]
