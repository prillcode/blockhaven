# World Setup Summary - Quick Reference

## What We've Prepared

✅ Updated [INSTALL-PLUGINS.sh](INSTALL-PLUGINS.sh) to include:
  - Multiverse-Core v4.4.0
  - Multiverse-Portals v4.2.4
  - Multiverse-Inventories v4.2.6
  - VoidGen v2.1.3

✅ Created [CREATE-WORLDS-GUIDE.md](CREATE-WORLDS-GUIDE.md) - Step-by-step guide

✅ Updated [scripts/create-worlds-rcon.sh](scripts/create-worlds-rcon.sh) - Automated script with seed variables

---

## Your Workflow (3 Easy Steps)

### Step 1: Install Multiverse Plugins on VPS

```bash
# SSH to VPS
ssh blockhaven_vps

# Navigate to server directory
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server

# Run installation script
bash INSTALL-PLUGINS.sh

# Fix permissions
sudo chown -R 1000:1000 data/plugins/

# Restart to load plugins
docker compose restart minecraft

# Verify plugins loaded (wait ~30 seconds)
docker exec -i blockhaven-mc rcon-cli "plugins"
```

**Expected output should include:**
- Multiverse-Core
- Multiverse-Portals
- Multiverse-Inventories
- VoidGen

---

### Step 2: Update Seeds in Script

**Option A: Edit the script directly on VPS**
```bash
nano scripts/create-worlds-rcon.sh
```

Update these lines (7-10):
```bash
SEED_SURVIVAL_EASY="your_seed_here"
SEED_SURVIVAL_HARD="your_seed_here"
SEED_CREATIVE_TERRAIN="your_seed_here"
SEED_RESOURCE="your_seed_here"
```

**Option B: Edit locally and redeploy**
1. Edit [scripts/create-worlds-rcon.sh](scripts/create-worlds-rcon.sh) with your seeds
2. Git commit and push
3. Redeploy via Dokploy

---

### Step 3: Run World Creation Script

```bash
# From VPS in mc-server directory
bash scripts/create-worlds-rcon.sh
```

This will:
- Create all 6 worlds with your seeds
- Set difficulty and gamemode for each
- Set world borders
- List all created worlds

**Total time:** ~2-3 minutes

---

## Alternative: Manual RCON Method

If you prefer to run commands manually or the script fails:

```bash
# Access RCON
docker exec -i blockhaven-mc rcon-cli

# Then paste commands from CREATE-WORLDS-GUIDE.md one by one
```

See [CREATE-WORLDS-GUIDE.md](CREATE-WORLDS-GUIDE.md) for full command list.

---

## Seeds You Need

| World | Type | Purpose |
|-------|------|---------|
| survival_easy | Normal | Flatter terrain, village-heavy |
| survival_hard | Normal | Mountainous, challenging |
| creative_terrain | Normal | Natural landscape for plots |
| resource | Normal | Any seed | An easy survival world |
| creative_flat | Superflat | No seed needed |
| spawn | Void | No seed needed |

**Total seeds needed:** 4

**Good seed sources:**
- https://www.chunkbase.com/apps/seed-map
- r/minecraftseeds
- https://www.minecraft-seeds.com/

---

## After World Creation

1. **LEVEL=spawn** is already set in [docker-compose.yml:30](docker-compose.yml#L30)
2. **No redeploy needed** - worlds persist in `/data/` volume
3. **Next steps:**
   - Build spawn hub in spawn world
   - Set spawn point: `/setworldspawn ~ ~ ~`
   - Configure Multiverse-Inventories (Phase 4)
   - Set up PlotSquared in creative worlds

---

## Files Reference

| File | Purpose |
|------|---------|
| [INSTALL-PLUGINS.sh](INSTALL-PLUGINS.sh) | Download Multiverse + VoidGen |
| [CREATE-WORLDS-GUIDE.md](CREATE-WORLDS-GUIDE.md) | Step-by-step manual instructions |
| [scripts/create-worlds-rcon.sh](scripts/create-worlds-rcon.sh) | Automated world creation script |
| [docker-compose.yml](docker-compose.yml) | LEVEL=spawn already configured |

---

## Troubleshooting

**Plugins not loading?**
```bash
# Check plugin files exist
ls -lh data/plugins/

# Check permissions
sudo chown -R 1000:1000 data/plugins/

# View server logs
docker logs blockhaven-mc | tail -50
```

**VoidGen not found?**
```bash
# Check if VoidGen loaded
docker logs blockhaven-mc | grep -i voidgen

# Reinstall if needed
bash INSTALL-PLUGINS.sh
```

**World already exists error?**
```bash
# Delete and recreate
docker exec -i blockhaven-mc rcon-cli "mv delete worldname"
docker exec -i blockhaven-mc rcon-cli "mv confirm"
```

---

**Ready? Let's create some worlds! 🌍**
