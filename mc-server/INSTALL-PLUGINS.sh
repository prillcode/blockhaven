#!/bin/bash
# BlockHaven - Install Missing Plugins
# Run from mc-server directory

cd "$(dirname "$0")"

echo "Installing missing plugins to data/plugins/..."

# EssentialsX (Core only - Multiverse handles spawn)
wget -q -O data/plugins/EssentialsX.jar \
  "https://github.com/EssentialsX/Essentials/releases/download/2.21.2/EssentialsX-2.21.2.jar"
echo "✓ EssentialsX"

# Vault (Economy API)
wget -q -O data/plugins/Vault.jar \
  "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar"
echo "✓ Vault"

# Jobs Reborn
wget -q -O data/plugins/Jobs.jar \
  "https://github.com/Zrips/Jobs/releases/download/v5.3.2.2/Jobs5.3.2.2.jar"
echo "✓ Jobs Reborn"

# PlotSquared (Creative Plots)
wget -q -O data/plugins/PlotSquared-Bukkit.jar \
  "https://download.intellectualsites.com/downloads/plotsquared/PlotSquared-Bukkit-7.4.6.jar"
echo "✓ PlotSquared"

echo ""
echo "Done! Restart the server to load new plugins:"
echo "  docker compose restart minecraft"
