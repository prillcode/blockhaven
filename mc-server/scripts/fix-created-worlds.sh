#!/bin/bash
# Fix world settings after initial creation
# Run from mc-server directory: bash scripts/fix-created-worlds.sh

echo "Applying world settings..."
echo ""

# Survival Easy settings
echo "Configuring survival_easy..."
docker exec -i blockhaven-mc rcon-cli "mv modify survival_easy set difficulty normal"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_easy set gamemode survival"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_easy set alias SMP_Smokey_Plains"

# Survival Hard settings
echo "Configuring survival_hard..."
docker exec -i blockhaven-mc rcon-cli "mv modify survival_hard set difficulty hard"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_hard set gamemode survival"
docker exec -i blockhaven-mc rcon-cli "mv modify survival_hard set alias SMP_Forest_Cliffs"

# Creative Flat settings
echo "Configuring creative_flat..."
docker exec -i blockhaven-mc rcon-cli "mv modify creative_flat set difficulty peaceful"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_flat set gamemode creative"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_flat set alias Creative_Plots"

# Creative Terrain settings
echo "Configuring creative_terrain..."
docker exec -i blockhaven-mc rcon-cli "mv modify creative_terrain set difficulty peaceful"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_terrain set gamemode creative"
docker exec -i blockhaven-mc rcon-cli "mv modify creative_terrain set alias Creative_Hills"

# Resource settings
echo "Configuring resource..."
docker exec -i blockhaven-mc rcon-cli "mv modify resource set difficulty normal"
docker exec -i blockhaven-mc rcon-cli "mv modify resource set gamemode survival"
docker exec -i blockhaven-mc rcon-cli "mv modify resource set alias Resource_Ravine"

# Spawn settings
echo "Configuring spawn..."
docker exec -i blockhaven-mc rcon-cli "mv modify spawn set difficulty peaceful"
docker exec -i blockhaven-mc rcon-cli "mv modify spawn set gamemode adventure"
docker exec -i blockhaven-mc rcon-cli "mv modify spawn set alias Spawn_Hub"

# Delete unwanted nether/end worlds
echo ""
echo "Deleting unwanted spawn_nether and spawn_the_end..."
docker exec -i blockhaven-mc rcon-cli "mv delete spawn_nether"
sleep 1
docker exec -i blockhaven-mc rcon-cli "mv confirm"
sleep 1
docker exec -i blockhaven-mc rcon-cli "mv delete spawn_the_end"
sleep 1
docker exec -i blockhaven-mc rcon-cli "mv confirm"

# List all worlds
echo ""
echo "Final world list:"
docker exec -i blockhaven-mc rcon-cli "mv list"

echo ""
echo "========================================="
echo "World settings applied!"
echo "========================================="
