#!/bin/bash
# export-server-data.sh
# Run this script ON THE VPS to export server data for local use
#
# Usage (on VPS):
#   cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server
#   bash scripts/export-server-data.sh
#
# Then download the export:
#   scp blockhaven_vps:/tmp/blockhaven-export.tar.gz ./

set -e

EXPORT_DIR="/tmp/blockhaven-export"
EXPORT_FILE="/tmp/blockhaven-export.tar.gz"
CONTAINER_NAME="blockhaven-mc"

echo "=== BlockHaven Server Data Export ==="
echo ""

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "ERROR: Container ${CONTAINER_NAME} is not running!"
    exit 1
fi

# Clean up any previous export
rm -rf "$EXPORT_DIR"
rm -f "$EXPORT_FILE"
mkdir -p "$EXPORT_DIR"

echo "1. Saving server state..."
docker exec -i "$CONTAINER_NAME" rcon-cli save-all || echo "   (save-all warning - continuing)"
sleep 2

echo "2. Exporting world data..."
# Export all world directories
for world in spawn spawn_nether spawn_the_end creative_flat creative_terrain survival_easy survival_normal survival_hard; do
    echo "   - $world"
    docker cp "$CONTAINER_NAME:/data/$world" "$EXPORT_DIR/" 2>/dev/null || echo "     (skipped - not found)"
done

echo "3. Exporting plugin configurations..."
mkdir -p "$EXPORT_DIR/plugins"

# Core plugin configs to preserve
PLUGIN_CONFIGS=(
    "Multiverse-Core"
    "Multiverse-Portals"
    "Multiverse-NetherPortals"
    "Multiverse-Inventories"
    "Essentials"
    "LuckPerms"
    "WorldGuard"
    "Geyser-Spigot"
    "floodgate"
)

for config in "${PLUGIN_CONFIGS[@]}"; do
    echo "   - $config"
    docker cp "$CONTAINER_NAME:/data/plugins/$config" "$EXPORT_DIR/plugins/" 2>/dev/null || echo "     (skipped - not found)"
done

echo "4. Exporting server configs..."
docker cp "$CONTAINER_NAME:/data/server.properties" "$EXPORT_DIR/" 2>/dev/null || true
docker cp "$CONTAINER_NAME:/data/bukkit.yml" "$EXPORT_DIR/" 2>/dev/null || true
docker cp "$CONTAINER_NAME:/data/spigot.yml" "$EXPORT_DIR/" 2>/dev/null || true
docker cp "$CONTAINER_NAME:/data/paper-global.yml" "$EXPORT_DIR/" 2>/dev/null || true
docker cp "$CONTAINER_NAME:/data/paper-world-defaults.yml" "$EXPORT_DIR/" 2>/dev/null || true

echo "5. Creating archive..."
cd /tmp
tar czvf blockhaven-export.tar.gz blockhaven-export/

# Calculate size
SIZE=$(du -h "$EXPORT_FILE" | cut -f1)
echo ""
echo "=== Export Complete ==="
echo "File: $EXPORT_FILE"
echo "Size: $SIZE"
echo ""
echo "Download with:"
echo "  scp blockhaven_vps:$EXPORT_FILE ./"
echo ""
echo "Then import locally with:"
echo "  bash scripts/import-server-data.sh blockhaven-export.tar.gz"
