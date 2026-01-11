# World Creation Guide - BlockHaven

## Prerequisites

Before creating worlds, ensure you have:
1. ✅ Multiverse-Core plugin installed
2. ✅ VoidGen plugin installed (for spawn world)
3. ✅ Selected seeds for your worlds

---

## Step 1: Install Required Plugins on VPS

SSH to your VPS and run the installation script:

```bash
# SSH to VPS
ssh blockhaven_vps

# Navigate to mc-server directory
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server

# Run plugin installation script
bash INSTALL-PLUGINS.sh

# Fix file permissions (Docker container runs as UID 1000)
sudo chown -R 1000:1000 data/plugins/

# Restart server to load new plugins
docker compose restart minecraft

# Wait ~30 seconds, then check if plugins loaded
docker exec -i blockhaven-mc rcon-cli "plugins"
```

**Expected Output (should show):**
- Multiverse-Core
- Multiverse-Portals
- Multiverse-Inventories
- VoidGen

---

## Step 2: Prepare Your Seeds

Replace `YOUR_SEED_HERE` with your actual seeds in the commands below:

| World | Purpose | Seed |
|-------|---------|------|
| survival_easy | Village-heavy, flatter terrain | `YOUR_SEED_1` |
| survival_hard | Mountainous/amplified | `YOUR_SEED_2` |
| creative_terrain | Natural landscape for plots | `YOUR_SEED_3` |
| resource | Any seed (resets monthly) | `YOUR_SEED_4` or leave blank |

---

## Step 3: Create Worlds via RCON

Access RCON on the VPS:

```bash
# From VPS
docker exec -i blockhaven-mc rcon-cli
```

Then paste these commands **one at a time** (replace seeds first!):

### 3.1 Survival Easy (Normal terrain with villages)
```
mv create survival_easy normal -s YOUR_SEED_1
mv modify set difficulty normal survival_easy
mv modify set gamemode survival survival_easy
```

### 3.2 Survival Hard (Amplified mountains)
```
mv create survival_hard normal -t AMPLIFIED -s YOUR_SEED_2
mv modify set difficulty hard survival_hard
mv modify set gamemode survival survival_hard
```

### 3.3 Creative Flat (Superflat for plots)
```
mv create creative_flat normal -t FLAT
mv modify set difficulty peaceful creative_flat
mv modify set gamemode creative creative_flat
```

### 3.4 Creative Terrain (Natural landscape)
```
mv create creative_terrain normal -s YOUR_SEED_3
mv modify set difficulty peaceful creative_terrain
mv modify set gamemode creative creative_terrain
```

### 3.5 Resource World (Resets monthly)
```
mv create resource normal -s YOUR_SEED_4
mv modify set difficulty normal resource
mv modify set gamemode survival resource
gamerule keepInventory true
```

### 3.6 Spawn Hub (Void world)
```
mv create spawn normal -g VoidGen
mv modify set difficulty peaceful spawn
mv modify set gamemode adventure spawn
```

---

## Step 4: Verify Worlds Created

Still in RCON:

```
mv list
```

**Expected Output:**
```
Worlds:
  - survival_easy
  - survival_hard
  - creative_flat
  - creative_terrain
  - resource
  - spawn
  - world (default world - you can delete this later)
```

---

## Step 5: Set Default Spawn World

The `LEVEL=spawn` setting in [docker-compose.yml:30](docker-compose.yml#L30) will make `spawn` the default world on next restart.

**However**, until you build your spawn hub and set a spawn point, players will spawn at random safe locations near 0,0. To fix this later:

1. Build your spawn hub in the `spawn` world
2. Stand at the desired spawn location
3. Run in RCON:
   ```
   setworldspawn ~ ~ ~
   mv modify set respawnWorld spawn spawn
   ```

---

## Step 6: Set World Borders (Optional but Recommended)

Prevent players from exploring infinitely:

```
mv modify set worldborder 10000 survival_easy
mv modify set worldborder 10000 survival_hard
mv modify set worldborder 5000 resource
mv modify set worldborder 5000 creative_flat
mv modify set worldborder 10000 creative_terrain
mv modify set worldborder 500 spawn
```

---

## Step 7: Test World Teleportation

```
mv tp survival_easy
mv tp survival_hard
mv tp creative_flat
mv tp creative_terrain
mv tp resource
mv tp spawn
```

All teleports should work without errors.

---

## Troubleshooting

### "Plugin Multiverse-Core not found"
- Run `INSTALL-PLUGINS.sh` again
- Check file permissions: `sudo chown -R 1000:1000 data/plugins/`
- Restart server: `docker compose restart minecraft`

### "Unknown generator VoidGen"
- VoidGen plugin not loaded
- Check `docker logs blockhaven-mc | grep -i voidgen`
- Reinstall VoidGen from INSTALL-PLUGINS.sh

### "World already exists"
- Delete world first: `mv delete <worldname>`
- Or use: `mv confirm` after the delete command

### Random spawn location changing
- This is normal until you set a spawn point with `/setworldspawn`
- Build your spawn hub first, then set the spawn point

---

## Next Steps

After creating worlds:
1. ✅ Configure Multiverse-Inventories (separate creative/survival inventories)
2. ✅ Set up PlotSquared in creative worlds
3. ✅ Configure GriefPrevention in survival worlds
4. ✅ Build spawn hub with portals/NPCs
5. ✅ Set permanent spawn point

See [NEXT-STEPS.md](../../NEXT-STEPS.md) for the full roadmap.

---

**Good luck! 🌍**
