# Quick Start - World Creation

**Copy-paste commands for fastest setup**

---

## 1. Install Plugins (on VPS)

```bash
ssh blockhaven_vps
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server
bash INSTALL-PLUGINS.sh
sudo chown -R 1000:1000 data/plugins/
docker compose restart minecraft
# Wait 30 seconds
docker exec -i blockhaven-mc rcon-cli "plugins"
```

---

## 2. Update Seeds

Edit `scripts/create-worlds-rcon.sh` lines 7-10 with your seeds:

```bash
SEED_SURVIVAL_EASY="12345"        # Replace with your seed
SEED_SURVIVAL_HARD="67890"        # Replace with your seed
SEED_CREATIVE_TERRAIN="11111"     # Replace with your seed
SEED_RESOURCE="22222"             # Replace with your seed
```

---

## 3. Create Worlds

```bash
bash scripts/create-worlds-rcon.sh
```

**Done!** ✅

---

## Alternative: Manual RCON Commands

If automated script doesn't work, paste these manually:

```bash
# Access RCON
docker exec -i blockhaven-mc rcon-cli
```

Then paste (replace SEED_* with actual seeds):

```
mv create survival_easy normal -s SEED_SURVIVAL_EASY
mv modify set difficulty normal survival_easy
mv modify set gamemode survival survival_easy

mv create survival_hard normal -t AMPLIFIED -s SEED_SURVIVAL_HARD
mv modify set difficulty hard survival_hard
mv modify set gamemode survival survival_hard

mv create creative_flat normal -t FLAT
mv modify set difficulty peaceful creative_flat
mv modify set gamemode creative creative_flat

mv create creative_terrain normal -s SEED_CREATIVE_TERRAIN
mv modify set difficulty peaceful creative_terrain
mv modify set gamemode creative creative_terrain

mv create resource normal -s SEED_RESOURCE
mv modify set difficulty normal resource
mv modify set gamemode survival resource
gamerule keepInventory true

mv create spawn normal -g VoidGen
mv modify set difficulty peaceful spawn
mv modify set gamemode adventure spawn

mv modify set worldborder 10000 survival_easy
mv modify set worldborder 10000 survival_hard
mv modify set worldborder 5000 resource
mv modify set worldborder 5000 creative_flat
mv modify set worldborder 10000 creative_terrain
mv modify set worldborder 500 spawn

mv list
```

---

**Need more details?** See [CREATE-WORLDS-GUIDE.md](CREATE-WORLDS-GUIDE.md)
