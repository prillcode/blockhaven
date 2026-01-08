#!/bin/bash
# BlockHaven - Install Missing Plugins (Phase 1)
# Updated: January 2026 for Paper 1.21.11
# Run from mc-server directory

cd "$(dirname "$0")"

echo "Installing Phase 1 plugins to data/plugins/..."
echo ""

# Create plugins directory if it doesn't exist
mkdir -p data/plugins

# EssentialsX v2.21.2 (Latest stable - supports up to 1.21.8)
echo "Downloading EssentialsX..."
wget -q --show-progress -O data/plugins/EssentialsX.jar \
  "https://github.com/EssentialsX/Essentials/releases/download/2.21.2/EssentialsX-2.21.2.jar" \
  && echo "✓ EssentialsX v2.21.2" || echo "✗ EssentialsX download failed"

# Vault v1.7.3 (Economy API)
echo "Downloading Vault..."
wget -q --show-progress -O data/plugins/Vault.jar \
  "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar" \
  && echo "✓ Vault v1.7.3" || echo "✗ Vault download failed"

# CMILib v1.5.8.1 (Required dependency for Jobs Reborn)
echo "Downloading CMILib (Jobs dependency)..."
wget -q --show-progress -O data/plugins/CMILib.jar \
  "https://github.com/Zrips/CMILib/releases/download/1.5.8.1/CMILib1.5.8.1.jar" \
  && echo "✓ CMILib v1.5.8.1" || echo "✗ CMILib download failed"

# Jobs Reborn v5.2.6.3 (Latest stable)
echo "Downloading Jobs Reborn..."
wget -q --show-progress -O data/plugins/Jobs.jar \
  "https://github.com/Zrips/Jobs/releases/download/v5.2.6.3/Jobs5.2.6.3.jar" \
  && echo "✓ Jobs Reborn v5.2.6.3" || echo "✗ Jobs Reborn download failed"

# PlotSquared v7.5.11 (Latest - supports 1.21.8)
# Note: Will be auto-downloaded via docker-compose MODRINTH_PROJECTS
echo "✓ PlotSquared v7.5.11 (auto-downloaded via Modrinth)"

# LuckPerms v5.5.22 (Latest - supports 1.21.x)
echo "Downloading LuckPerms..."
wget -q --show-progress -O data/plugins/LuckPerms-Bukkit.jar \
  "https://ci.lucko.me/job/LuckPerms/lastSuccessfulBuild/artifact/bukkit/loader/build/libs/LuckPerms-Bukkit-5.5.22.jar" \
  && echo "✓ LuckPerms v5.5.22" || echo "✗ LuckPerms download failed"

echo ""
echo "========================================="
echo "Phase 1 plugins installed!"
echo "========================================="
echo ""
echo "Installed:"
echo "  ✓ EssentialsX v2.21.2"
echo "  ✓ Vault v1.7.3"
echo "  ✓ CMILib v1.5.8.1 (Jobs dependency)"
echo "  ✓ Jobs Reborn v5.2.6.3"
echo "  ✓ LuckPerms v5.5.22"
echo ""
echo "Already auto-installed via docker-compose (Modrinth):"
echo "  ✓ Geyser (Bedrock support)"
echo "  ✓ Floodgate (Bedrock auth)"
echo "  ✓ ViaVersion (Protocol support)"
echo "  ✓ PlotSquared v7.5.11"
echo ""
echo "Next steps:"
echo "  1. Restart the server:"
echo "     docker compose restart minecraft"
echo "  2. Check logs:"
echo "     docker logs blockhaven-mc -f"
echo "  3. Verify plugins loaded:"
echo "     docker exec -i blockhaven-mc rcon-cli"
echo "     Then type: plugins"
echo ""
