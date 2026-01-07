#!/bin/bash
# BlockHaven Plugin Download Script
# Manual fallback to download plugins (normally handled by Docker image)

set -e

echo "📥 Downloading plugins manually..."
echo "⚠️  Note: This is normally handled automatically by the itzg/minecraft-server image"
echo ""

PLUGINS_DIR="./data/plugins"
mkdir -p "$PLUGINS_DIR"

echo "This script is a placeholder for manual plugin downloads."
echo "Plugins are automatically downloaded via:"
echo "  - SPIGET_RESOURCES (SpigotMC)"
echo "  - MODRINTH_PROJECTS (Modrinth)"
echo "  - MODS_FILE (extras/plugins.txt)"
echo ""
echo "To manually download plugins:"
echo "  1. Download .jar files from official sources"
echo "  2. Place them in: $PLUGINS_DIR"
echo "  3. Restart the server: docker-compose restart minecraft"
echo ""
echo "✅ See extras/plugins.txt for download URLs"
