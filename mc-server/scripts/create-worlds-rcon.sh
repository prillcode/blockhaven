#!/bin/bash
# Run Multiverse world creation commands via RCON
# Update seeds before running!
# Run from mc-server directory: bash scripts/create-worlds-rcon.sh

# === REPLACE THESE SEEDS ===
SEED_SURVIVAL_EASY="-1718501946501227358"
SEED_SURVIVAL_HARD="-9163391121958459490"
SEED_CREATIVE_TERRAIN="4504535438041489910"
SEED_RESOURCE="-7723232821704547830"

# All seeds from this URL (for image references):
# https://www.rockpapershotgun.com/best-minecraft-seeds-java-survival-seeds
# 


echo "Creating BlockHaven worlds..."
echo "Using seeds:"
echo "  Survival Easy: $SEED_SURVIVAL_EASY"
echo "  Survival Hard: $SEED_SURVIVAL_HARD"
echo "  Creative Terrain: $SEED_CREATIVE_TERRAIN"
echo "  Resource: $SEED_RESOURCE"
echo ""

# Survival Easy - Normal terrain
echo "Creating survival_easy..."
docker exec -i blockhaven-mc rcon-cli "mv create survival_easy normal -s $SEED_SURVIVAL_EASY"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty normal survival_easy"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode survival survival_easy"

# Survival Hard - More Mountains
echo "Creating survival_hard..."
docker exec -i blockhaven-mc rcon-cli "mv create survival_hard normal -s $SEED_SURVIVAL_HARD"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty hard survival_hard"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode survival survival_hard"

# Creative Flat - Superflat for plots
echo "Creating creative_flat..."
docker exec -i blockhaven-mc rcon-cli "mv create creative_flat normal -t FLAT"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty peaceful creative_flat"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode creative creative_flat"

# Creative Terrain - Normal generation
echo "Creating creative_terrain..."
docker exec -i blockhaven-mc rcon-cli "mv create creative_terrain normal -s $SEED_CREATIVE_TERRAIN"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty peaceful creative_terrain"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode creative creative_terrain"

# Resource World - Normal, will be reset monthly
echo "Creating resource..."
docker exec -i blockhaven-mc rcon-cli "mv create resource normal -s $SEED_RESOURCE"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty normal resource"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode survival resource"
docker exec -i blockhaven-mc rcon-cli "gamerule keepInventory true"

# Spawn Hub - Void world
echo "Creating spawn (void world)..."
docker exec -i blockhaven-mc rcon-cli "mv create spawn normal -g VoidGen"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty peaceful spawn"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode adventure spawn"

# Set world borders
echo ""
echo "Setting world borders..."
docker exec -i blockhaven-mc rcon-cli "mv modify set worldborder 10000 survival_easy"
docker exec -i blockhaven-mc rcon-cli "mv modify set worldborder 10000 survival_hard"
docker exec -i blockhaven-mc rcon-cli "mv modify set worldborder 5000 resource"
docker exec -i blockhaven-mc rcon-cli "mv modify set worldborder 5000 creative_flat"
docker exec -i blockhaven-mc rcon-cli "mv modify set worldborder 10000 creative_terrain"
docker exec -i blockhaven-mc rcon-cli "mv modify set worldborder 500 spawn"

# List all worlds
echo ""
echo "Listing all worlds..."
docker exec -i blockhaven-mc rcon-cli "mv list"

echo ""
echo "========================================="
echo "✅ All worlds created successfully!"
echo "========================================="
echo ""
echo "Worlds created:"
echo "  ✓ survival_easy (Normal, seed: $SEED_SURVIVAL_EASY)"
echo "  ✓ survival_hard (Amplified, seed: $SEED_SURVIVAL_HARD)"
echo "  ✓ creative_flat (Superflat)"
echo "  ✓ creative_terrain (Normal, seed: $SEED_CREATIVE_TERRAIN)"
echo "  ✓ resource (Normal, seed: $SEED_RESOURCE)"
echo "  ✓ spawn (Void)"
echo ""
echo "Next steps:"
echo "  1. The spawn world is now the default (LEVEL=spawn in docker-compose.yml)"
echo "  2. Build your spawn hub in the spawn world"
echo "  3. Set spawn point: /setworldspawn ~ ~ ~"
echo "  4. Test world teleports: /mv tp <world>"
echo ""
