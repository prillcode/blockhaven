#!/bin/bash
# BlockHaven World Creation Script
# Run these commands via RCON or in-game console

echo "Creating BlockHaven worlds..."
echo "NOTE: Run these commands in-game as OP or via RCON"
echo "Replace -s <seed> with your desired seeds before running"
echo ""

cat << 'EOF'
# Survival Easy - Normal terrain, village-heavy (find a seed with lots of villages)
/mv create survival_easy normal -s YOUR_SEED_HERE
/mv modify set difficulty normal survival_easy
/mv modify set gamemode survival survival_easy

# Survival Hard - Amplified/mountainous
/mv create survival_hard normal -t AMPLIFIED -s YOUR_SEED_HERE
/mv modify set difficulty hard survival_hard
/mv modify set gamemode survival survival_hard

# Creative Flat - Superflat for plots (seed doesn't matter for flat worlds)
/mv create creative_flat normal -t FLAT
/mv modify set difficulty peaceful creative_flat
/mv modify set gamemode creative creative_flat

# Creative Terrain - Normal generation
/mv create creative_terrain normal -s YOUR_SEED_HERE
/mv modify set difficulty peaceful creative_terrain
/mv modify set gamemode creative creative_terrain

# Resource World - Normal, will be reset monthly (seed will change on reset)
/mv create resource normal -s YOUR_SEED_HERE
/mv modify set difficulty normal resource
/mv modify set gamemode survival resource
/mvm set gamerule keepInventory true resource

# Spawn Hub - Void world (seed doesn't matter for void generation)
/mv create spawn normal -g VoidGen
/mv modify set difficulty peaceful spawn
/mv modify set gamemode adventure spawn

# Set spawn world
/mv set spawn spawn

# List all worlds
/mv list
EOF
