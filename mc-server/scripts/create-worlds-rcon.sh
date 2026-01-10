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
docker exec -i blockhaven-mc rcon-cli "mv modify survival_easy set difficulty normal"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_easy set gamemode survival"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_easy set alias SMP_Smokey_Plains"

# Survival Hard - More Mountains
echo "Creating survival_hard..."
docker exec -i blockhaven-mc rcon-cli "mv create survival_hard normal -s $SEED_SURVIVAL_HARD"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_hard set difficulty hard"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_hard set gamemode survival"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_hard set alias SMP_Forest_Cliffs"

# Creative Flat - Superflat for plots
echo "Creating creative_flat..."
docker exec -i blockhaven-mc rcon-cli "mv create creative_flat normal -t FLAT"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_flat set difficulty peaceful"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_flat set gamemode creative"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_flat set alias Creative_Plots"

# Creative Terrain - Normal generation
echo "Creating creative_terrain..."
docker exec -i blockhaven-mc rcon-cli "mv create creative_terrain normal -s $SEED_CREATIVE_TERRAIN"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_terrain set difficulty peaceful"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_terrain set gamemode creative"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_terrain set alias Creative_Hills"

# Resource World - Normal, will be reset monthly
echo "Creating resource..."
docker exec -i blockhaven-mc rcon-cli "mv create resource normal -s $SEED_RESOURCE"
docker exec -i blockhaven-mc rcon-cli "mv modify resource set difficulty normal"
docker exec -i blockhaven-mc rcon-cli "mv modify resource set gamemode survival"
docker exec -i blockhaven-mc rcon-cli "mv modify resource set alias Resource_Ravine"
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:resource run gamerule keepInventory true"

# Spawn Hub - Void world
echo "Creating spawn (void world)..."
docker exec -i blockhaven-mc rcon-cli "mv create spawn normal -g VoidGen"
docker exec -i blockhaven-mc rcon-cli "mv modify spawn set difficulty peaceful"
docker exec -i blockhaven-mc rcon-cli "mv modify spawn set gamemode adventure"
docker exec -i blockhaven-mc rcon-cli "mv modify spawn set alias Spawn_Hub"

# Set world borders using vanilla worldborder command
echo ""
echo "Setting world borders..."
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:survival_easy run worldborder set 10000"
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:survival_hard run worldborder set 10000"
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:resource run worldborder set 5000"
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:creative_flat run worldborder set 5000"
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:creative_terrain run worldborder set 10000"
docker exec -i blockhaven-mc rcon-cli "execute in minecraft:spawn run worldborder set 500"

# List all worlds
echo ""
echo "Listing all worlds..."
docker exec -i blockhaven-mc rcon-cli "mv list"

echo ""
echo "========================================="
echo "All worlds created successfully!"
echo "========================================="
echo ""
echo "Worlds created:"
echo "  - SMP Smokey Plains (survival_easy, seed: $SEED_SURVIVAL_EASY)"
echo "  - SMP Forest Cliffs (survival_hard, seed: $SEED_SURVIVAL_HARD)"
echo "  - Creative Plots (creative_flat)"
echo "  - Creative Hills (creative_terrain, seed: $SEED_CREATIVE_TERRAIN)"
echo "  - Resource Ravine (resource, seed: $SEED_RESOURCE)"
echo "  - Spawn Hub (spawn)"
echo ""
echo "Next steps:"
echo "  1. Delete unwanted nether/end: /mv delete spawn_nether, /mv delete spawn_the_end"
echo "  2. Build your spawn hub in the spawn world"
echo "  3. Set spawn point: /setworldspawn ~ ~ ~"
echo "  4. Test world teleports: /mv tp <world>"
echo ""
