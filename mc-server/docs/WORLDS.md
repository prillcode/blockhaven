# BlockHaven Worlds Guide

## World Overview

BlockHaven features **6 main worlds** plus unlimited **private worlds** for premium players.

| World | Type | Difficulty | Claim Rate | Job Payout | Description |
|-------|------|------------|-----------|------------|-------------|
| **survival_easy** | Survival | Normal | 200/hr (2x) | 1.0x | Flat villages, easier progression |
| **survival_hard** | Survival | Hard | 50/hr (0.5x) | 1.5x | Mountainous, challenging |
| **creative_flat** | Creative | Peaceful | Plots (64x64) | N/A | Superflat building plots |
| **creative_terrain** | Creative | Peaceful | Plots (128x128) | N/A | Natural terrain plots |
| **resource** | Survival | Normal | No claims | 1.0x | Monthly reset mining world |
| **spawn** | Adventure | Peaceful | Protected | N/A | Hub with portals to all worlds |

---

## Initial World Creation

Run these commands **after first server boot** via RCON or in-game console:

```bash
# Access RCON console
docker exec -it blockhaven-mc rcon-cli
```

### 1. Survival Easy - Flat Villages
```bash
/mv create survival_easy normal -t FLAT
/mv modify set difficulty normal survival_easy
/mv modify set gamemode survival survival_easy
/mv modify set spawning monsters true survival_easy
/mv modify set spawning animals true survival_easy
```

### 2. Survival Hard - Mountainous Terrain
```bash
/mv create survival_hard normal -t AMPLIFIED
/mv modify set difficulty hard survival_hard
/mv modify set gamemode survival survival_hard
/mv modify set spawning monsters true survival_hard
/mv modify set spawning animals true survival_hard
```

### 3. Creative Flat - Superflat Plots
```bash
/mv create creative_flat normal -t FLAT
/mv modify set difficulty peaceful creative_flat
/mv modify set gamemode creative creative_flat
/mv modify set spawning monsters false creative_flat
/mv modify set pvp false creative_flat
```

### 4. Creative Terrain - Natural Landscape
```bash
/mv create creative_terrain normal
/mv modify set difficulty peaceful creative_terrain
/mv modify set gamemode creative creative_terrain
/mv modify set spawning monsters false creative_terrain
/mv modify set pvp false creative_terrain
```

### 5. Resource World - Monthly Reset
```bash
/mv create resource normal
/mv modify set difficulty normal resource
/mv modify set gamemode survival resource
/mv modify set gamerule keepInventory true resource
/mv modify set gamerule announceAdvancements false resource
```

### 6. Spawn Hub - Void World
```bash
/mv create spawn normal -g VoidGen
/mv modify set difficulty peaceful spawn
/mv modify set gamemode adventure spawn
/mv modify set spawning monsters false spawn
/mv modify set spawning animals false spawn
/mv modify set pvp false spawn
```

---

## Inventory Sharing Configuration

Configure Multiverse-Inventories to share/isolate inventories:

**File:** `plugins/Multiverse-Inventories/groups.yml`

```yaml
groups:
  # Survival worlds share inventory & ender chest only
  # XP, health, hunger, saturation stay per-world
  survival:
    worlds:
      - survival_easy
      - survival_hard
      - resource
      - spawn
    shares:
      - inventory      # Hotbar + main inventory
      - ender_chest    # Ender chest contents

  # Creative Flat - isolated from everything
  creative_flat:
    worlds:
      - creative_flat
    shares:
      - all           # Everything shared (only 1 world in group)

  # Creative Terrain - isolated from everything
  creative_terrain:
    worlds:
      - creative_terrain
    shares:
      - all           # Everything shared (only 1 world in group)
```

**What this means:**
- Players can mine in `resource`, teleport to `survival_easy`, and have the same items
- Dying in `survival_hard` doesn't affect your health in `survival_easy`
- XP grinding in `resource` stays in that world (prevents exploits)
- Creative worlds are completely isolated (no creative items in survival)

**Apply configuration:**
```bash
/mvinv reload
```

---

## PlotSquared Setup (Creative Worlds)

After creating creative worlds, set up plots:

### Creative Flat (64x64 plots)
```bash
/plot area create creative_flat
# Follow prompts:
# - Plot size: 64
# - Path width: 7
# - Ground height: 64
# - Wall block: stone_bricks
# - Floor block: grass_block
```

### Creative Terrain (128x128 plots)
```bash
/plot area create creative_terrain
# Follow prompts:
# - Plot size: 128
# - Path width: 10
# - Ground height: varies
# - Wall block: oak_planks
# - Floor block: grass_block
```

**Configure plot limits** in `plugins/PlotSquared/settings.yml`:
```yaml
limit:
  global:
    default: 3          # Default rank
    friend: 5           # Friend rank
    family: 10          # Family rank
    vip: 20             # VIP rank
    lifetime_vip: -1    # Unlimited
```

---

## World Borders

Set world borders to conserve server resources:

```bash
/mv modify set worldborder 10000 survival_easy
/mv modify set worldborder 10000 survival_hard
/mv modify set worldborder 5000 resource
/mv modify set worldborder 5000 creative_flat
/mv modify set worldborder 10000 creative_terrain
/mv modify set worldborder 500 spawn
```

**Rationale:**
- 10,000 block radius = 20k x 20k area (400M blocks)
- Resource world smaller (will be reset monthly)
- Spawn hub tiny (custom-built)

---

## GriefPrevention World Configuration

**File:** `plugins/GriefPrevention/worlds.yml`

```yaml
worlds:
  survival_easy:
    claims:
      enabled: true
      blocks_per_hour: 200    # 2x multiplier
      initial_blocks: 100
      max_accrued: 50000

  survival_hard:
    claims:
      enabled: true
      blocks_per_hour: 50     # 0.5x multiplier
      initial_blocks: 100
      max_accrued: 50000

  resource:
    claims:
      enabled: false          # No claims in reset world

  creative_flat:
    claims:
      enabled: false          # Use PlotSquared instead

  creative_terrain:
    claims:
      enabled: false          # Use PlotSquared instead

  spawn:
    claims:
      enabled: false          # WorldGuard protected
```

---

## WorldGuard Spawn Protection

Protect the spawn hub from any modifications:

```bash
# Select entire spawn area with WorldEdit
//wand
# (Select the entire spawn build)

# Create global spawn region
/rg define spawn_hub

# Set protection flags
/rg flag spawn_hub build deny
/rg flag spawn_hub pvp deny
/rg flag spawn_hub mob-spawning deny
/rg flag spawn_hub use allow           # Allow buttons/doors
/rg flag spawn_hub chest-access deny   # No chest access (unless staff shops)

# Allow admins to build
/rg addmember spawn_hub -a admin
```

---

## Resource World Monthly Reset

**Automated Reset Script:** `scripts/reset-resource-world.sh`

```bash
#!/bin/bash
# Reset resource world on 1st of each month
# Run via cron: 0 3 1 * * /path/to/reset-resource-world.sh

set -e

echo "🔄 Resetting resource world..."

# Announce to server
docker exec blockhaven-mc rcon-cli "say §c§lResource world resetting in 5 minutes! Return to spawn now!"
sleep 300  # 5 minutes

docker exec blockhaven-mc rcon-cli "say §c§lResource world resetting NOW!"

# Remove all players from resource world
docker exec blockhaven-mc rcon-cli "mv tp resource spawn"

# Delete world
docker exec blockhaven-mc rcon-cli "mv delete resource"

# Recreate world
docker exec blockhaven-mc rcon-cli "mv create resource normal"
docker exec blockhaven-mc rcon-cli "mv modify set difficulty normal resource"
docker exec blockhaven-mc rcon-cli "mv modify set gamemode survival resource"
docker exec blockhaven-mc rcon-cli "mv modify set gamerule keepInventory true resource"

echo "✅ Resource world reset complete!"
docker exec blockhaven-mc rcon-cli "say §a§lResource world has been reset! Fresh resources available!"
```

**Setup Cron Job:**
```bash
# Edit crontab
crontab -e

# Add line (reset at 3 AM on 1st of month)
0 3 1 * * /opt/blockhaven/mc-server/scripts/reset-resource-world.sh >> /var/log/blockhaven-resource-reset.log 2>&1
```

---

## Private Worlds (Premium Feature)

Premium players can create their own invite-only worlds.

### Commands (Custom Skript)
```bash
/pworld create <name>       # Create private world
/pworld invite <player>     # Invite player to your world
/pworld kick <player>       # Remove player access
/pworld list                # List your private worlds
/pworld tp <worldname>      # Teleport to your world
/pworld delete <name>       # Delete world (confirmation)
```

### World Naming Convention
```
pw_<player_uuid_short>_<worldname>
```

Example: `pw_a1b2c3d4_MyIsland`

### World Limits by Rank
- **Family ($9.99/mo):** 1 private world
- **VIP ($19.99/mo):** 3 private worlds
- **Lifetime VIP ($99.99):** 3 private worlds

### Technical Implementation
- **World Creation:** Multiverse-Core API
- **Permission Management:** Custom Skript
- **Data Storage:** YAML config with owner UUID + invited players
- **Auto-Unload:** Worlds unload after 30 minutes of inactivity (configurable)

**See:** Phase 6 in planning doc for Skript implementation

---

## World Teleportation & Portals

### Spawn Hub Portals

Build portals in the spawn hub to each world:

```bash
# Create portal from spawn to survival_easy
/mvp create <portal_name> spawn survival_easy
# (Select portal region with WorldEdit wand)

# Repeat for all worlds
```

**Portal Locations (recommended layout):**
- North: Survival Easy
- East: Survival Hard
- South: Creative Flat
- West: Creative Terrain
- Center Platform: Resource World
- Underground: Private Worlds

### Player Commands

```bash
/spawn                    # Return to spawn hub
/mv tp <world>            # Teleport to world (if permitted)
/sethome <name>           # Set home in current world
/home <name>              # Teleport to home
```

---

## World Maintenance

### Backup Individual Worlds
```bash
# Backup specific world
docker exec blockhaven-mc rcon-cli "save-all"
tar -czf backups/survival_easy-$(date +%Y%m%d).tar.gz data/survival_easy
```

### Prune Unused Chunks (Reduce World Size)
```bash
# Install MCEdit or use WorldBorder fill/trim commands
/wb <world> trim           # Remove chunks outside border
/wb <world> fill           # Pre-generate chunks
```

### World Performance Monitoring
```bash
# Check TPS per world
/tps

# View loaded chunks
/forge tps

# Unload unused worlds
/mv unload <world>
```

---

## Troubleshooting

### Players Stuck Between Worlds
```bash
# Teleport to spawn
/spawn

# Or force to default world
/mv tp <player> spawn
```

### Inventory Not Shared
```bash
# Verify Multiverse-Inventories loaded
/plugins

# Check groups configuration
/mvinv info

# Reload config
/mvinv reload
```

### Resource World Not Resetting
```bash
# Manually trigger reset
./scripts/reset-resource-world.sh

# Check cron logs
tail -f /var/log/blockhaven-resource-reset.log

# Verify cron job exists
crontab -l
```

### Plots Not Working
```bash
# Verify PlotSquared area created
/plot area list

# Regenerate area (DESTRUCTIVE!)
/plot area delete <area>
/plot area create <area>
```

---

## Next Steps

1. ✅ Create all 6 worlds using commands above
2. ✅ Configure inventory groups (Multiverse-Inventories)
3. ✅ Set up PlotSquared areas for creative worlds
4. ✅ Configure GriefPrevention per-world settings
5. ✅ Protect spawn hub with WorldGuard
6. ✅ Set up resource world reset cron job
7. ✅ Build spawn hub with portals to all worlds
8. ✅ Test cross-world teleportation
9. ✅ Implement private worlds Skript (Phase 6)

**See:** [blockhaven-planning-doc.md](../../blockhaven-planning-doc.md) for detailed phase-by-phase setup.
