#!/bin/bash
# Run Multiverse world creation commands via RCON
# Update seeds before running!

# Load RCON password from .env
source ../mc-server/.env

# Survival Easy - Normal terrain, village-heavy
docker exec -i blockhaven-mc rcon-cli "mv create survival_easy normal -s YOUR_SEED_HERE"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty normal survival_easy"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode survival survival_easy"

# Survival Hard - Amplified/mountainous
docker exec -i blockhaven-mc rcon-cli "mv create survival_hard normal -t AMPLIFIED -s YOUR_SEED_HERE"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty hard survival_hard"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode survival survival_hard"

# Creative Flat - Superflat for plots
docker exec -i blockhaven-mc rcon-cli "mv create creative_flat normal -t FLAT"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty peaceful creative_flat"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode creative creative_flat"

# Creative Terrain - Normal generation
docker exec -i blockhaven-mc rcon-cli "mv create creative_terrain normal -s YOUR_SEED_HERE"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty peaceful creative_terrain"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode creative creative_terrain"

# Resource World - Normal, will be reset monthly
docker exec -i blockhaven-mc rcon-cli "mv create resource normal -s YOUR_SEED_HERE"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty normal resource"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode survival resource"
docker exec -i blockhaven-mc rcon-cli "mvm set gamerule keepInventory true resource"

# Spawn Hub - Void world
docker exec -i blockhaven-mc rcon-cli "mv create spawn normal -g VoidGen"
docker exec -i blockhaven-mc rcon-cli "mv modify set difficulty peaceful spawn"
docker exec -i blockhaven-mc rcon-cli "mv modify set gamemode adventure spawn"

# Set spawn world
docker exec -i blockhaven-mc rcon-cli "mv set spawn spawn"

# List all worlds
docker exec -i blockhaven-mc rcon-cli "mv list"

echo ""
echo "Worlds created! Check docker logs for confirmation:"
echo "docker-compose logs -f minecraft"
