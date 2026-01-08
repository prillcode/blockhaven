# BlockHaven World Creation Guide

## Overview

BlockHaven uses **Multiverse-Core** to manage multiple worlds with different purposes. The default `world`, `world_nether`, and `world_the_end` are created by Paper automatically but **won't be used** in production.

## World List

| World ID | Purpose | Terrain Type | Seed Required? |
|----------|---------|--------------|----------------|
| `survival_easy` | Easier survival progression | Normal with villages | Yes - find village-heavy seed |
| `survival_hard` | Challenging survival | Amplified (extreme mountains) | Yes - any seed works |
| `creative_flat` | 64x64 building plots | Superflat | No - flat is flat |
| `creative_terrain` | 128x128 scenic plots | Normal generation | Yes - find scenic seed |
| `resource` | Monthly reset mining | Normal generation | Yes - changes on reset |
| `spawn` | Hub with portals | Void (custom built) | No - empty void |

## Finding Seeds

### For `survival_easy` - Village-Heavy Seeds
You want a seed with multiple villages close to spawn for easy progression:

**Recommended sites:**
- https://minecraftseedhq.com/ (filter by "villages")
- https://www.chunkbase.com/apps/seed-map (visualize before committing)
- Reddit: r/minecraftseeds

**Good 1.21 village seeds:**
- `8638613833825887773` - 6 villages within 1000 blocks
- `-1654510255` - Village at spawn with bonus structures
- `3257840388504953787` - Multiple biomes + villages

**How to verify:** Use [Chunkbase Seed Map](https://www.chunkbase.com/apps/seed-map) - enter seed, set version to 1.21, view village locations.

### For `survival_hard` - Amplified Terrain
Any seed works well with AMPLIFIED - the terrain generator makes everything extreme. Choose based on biome variety:

- `2151901553968352745` - Good biome mix
- `8678942899319966093` - Extreme mountains
- `-4530634556500121041` - Varied landscapes

### For `creative_terrain` - Scenic Seeds
Look for visually interesting terrain for creative building:

- `-1932600624` - Beautiful mixed biomes
- `3257840388504953787` - Varied elevation
- `2907998703124736264` - Scenic coastlines

### For `resource` - Mining World
Doesn't matter much since it resets monthly. Use a random number or simple seed like `12345`.

## Creating Worlds

### Step 1: Choose Your Seeds

1. Visit https://www.chunkbase.com/apps/seed-map
2. Test different seeds for `survival_easy`, `survival_hard`, `creative_terrain`, and `resource`
3. Note down the seeds you like

### Step 2: Update the Script

Edit `scripts/create-worlds-rcon.sh` and replace all instances of `YOUR_SEED_HERE` with your chosen seeds:

```bash
# Example:
nano mc-server/scripts/create-worlds-rcon.sh

# Replace:
# YOUR_SEED_HERE (for survival_easy) → 8638613833825887773
# YOUR_SEED_HERE (for survival_hard) → 2151901553968352745
# YOUR_SEED_HERE (for creative_terrain) → -1932600624
# YOUR_SEED_HERE (for resource) → 12345
```

### Step 3: Run the Script

**Make sure the server is running:**
```bash
cd mc-server
docker-compose up -d
```

**Execute the world creation script:**
```bash
./scripts/create-worlds-rcon.sh
```

**Or run commands manually in-game:**
```bash
./scripts/create-worlds.sh
# Copy commands and paste in-game console
```

### Step 4: Verify Worlds Created

**Check via RCON:**
```bash
docker exec -i blockhaven-mc rcon-cli "mv list"
```

**Or check data directory:**
```bash
ls -la mc-server/data/
# Should see: survival_easy, survival_hard, creative_flat, creative_terrain, resource, spawn
```

## World Directories After Creation

After running the creation commands, you'll see new directories in `mc-server/data/`:

```
mc-server/data/
├── world/              # Default - not used in production
├── world_nether/       # Default - not used in production
├── world_the_end/      # Default - not used in production
├── survival_easy/      # BlockHaven survival world (easy)
├── survival_hard/      # BlockHaven survival world (hard)
├── creative_flat/      # BlockHaven creative plots (64x64)
├── creative_terrain/   # BlockHaven creative plots (128x128)
├── resource/           # BlockHaven mining world (monthly reset)
└── spawn/              # BlockHaven hub world
```

## Recreating Worlds with New Seeds

If you want to change a world's seed **after** creation:

1. **Stop the server:**
   ```bash
   docker-compose down
   ```

2. **Delete the world folder:**
   ```bash
   rm -rf mc-server/data/survival_easy  # or whichever world
   ```

3. **Update the seed in your script**

4. **Start server and recreate:**
   ```bash
   docker-compose up -d
   docker exec -i blockhaven-mc rcon-cli "mv create survival_easy normal -s NEW_SEED_HERE"
   ```

## Important Notes

### Void World Generator
The `spawn` world uses `-g VoidGen` which requires a void generator plugin. If this fails:

**Option A: Use WorldEdit to clear chunks**
```bash
# Create as normal world then clear with WorldEdit
/mv create spawn normal
# Then use WorldEdit to clear the area
```

**Option B: Use VoidGen plugin**
```bash
# Add to plugins.txt:
# https://github.com/Scarsz/VoidGenerator/releases/download/v1.1.0/VoidGenerator.jar
```

**Option C: Use Multiverse NetherPortals with custom generator**
```bash
# Install a void generator through Multiverse itself
/mv create spawn normal -g Multiverse-Core:void
```

### Seed Format
Seeds can be:
- **Numbers:** `8638613833825887773`, `-1654510255`
- **Text:** `MyAwesomeSeed` (gets converted to a number)

Both work identically - text is just easier to remember.

### Testing Seeds Before Committing

**Quick test method:**
1. Create a temporary single-player world with the seed
2. Explore in creative mode
3. If you like it, use it for your server

**Or use online tools:**
- https://www.chunkbase.com/apps/seed-map (visualize without playing)

## Troubleshooting

### "World already exists" error
Delete the world folder in `mc-server/data/` and try again.

### Void generator not found
See "Void World Generator" section above.

### Wrong terrain type
Double-check the `-t` flag:
- `-t FLAT` = Superflat (only for creative_flat)
- `-t AMPLIFIED` = Extreme mountains (only for survival_hard)
- No `-t` flag = Normal terrain

## Next Steps

After creating worlds:

1. **Configure PlotSquared** for creative worlds (see docs/PLOTS.md)
2. **Set up Multiverse-Inventories** for inventory separation (see Phase 4 in planning doc)
3. **Build spawn hub** with portals to all worlds
4. **Set up world borders** and protection

See the main [blockhaven-planning-doc.md](../blockhaven-planning-doc.md) for the full implementation roadmap.
