#!/bin/bash
# import-server-data.sh
# Run this script LOCALLY to import VPS server data into your local Docker volume
#
# Prerequisites:
#   1. Download export from VPS: scp blockhaven_vps:/tmp/blockhaven-export.tar.gz ./
#   2. Have docker-compose.local.yml ready
#
# Usage:
#   cd mc-server
#   bash scripts/import-server-data.sh blockhaven-export.tar.gz

set -e

EXPORT_FILE="${1:-blockhaven-export.tar.gz}"
CONTAINER_NAME="blockhaven-local"
VOLUME_NAME="mc-server_blockhaven-local-data"
TEMP_DIR="/tmp/blockhaven-import"

echo "=== BlockHaven Local Server Data Import ==="
echo ""

# Check if export file exists
if [ ! -f "$EXPORT_FILE" ]; then
    echo "ERROR: Export file not found: $EXPORT_FILE"
    echo ""
    echo "Usage: bash scripts/import-server-data.sh <path-to-export.tar.gz>"
    echo ""
    echo "To create an export, run on VPS:"
    echo "  ssh blockhaven_vps"
    echo "  cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server"
    echo "  bash scripts/export-server-data.sh"
    echo ""
    echo "Then download:"
    echo "  scp blockhaven_vps:/tmp/blockhaven-export.tar.gz ./"
    exit 1
fi

# Stop container if running
echo "1. Stopping local container (if running)..."
docker compose -f docker-compose.local.yml down 2>/dev/null || true

echo "2. Extracting export archive..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
tar xzf "$EXPORT_FILE" -C "$TEMP_DIR"

# Find the extracted directory (handles both nested and flat extraction)
if [ -d "$TEMP_DIR/blockhaven-export" ]; then
    IMPORT_DIR="$TEMP_DIR/blockhaven-export"
else
    IMPORT_DIR="$TEMP_DIR"
fi

echo "3. Starting temporary container to access volume..."
# Create the volume if it doesn't exist, and start a temp container
docker volume create "$VOLUME_NAME" 2>/dev/null || true

# Use a simple alpine container to copy data into the volume
docker run --rm -d \
    --name blockhaven-import-helper \
    -v "$VOLUME_NAME:/data" \
    -v "$IMPORT_DIR:/import:ro" \
    alpine:latest \
    sleep 300

echo "4. Importing world data..."
for world in spawn spawn_nether spawn_the_end creative_flat creative_terrain survival_easy survival_normal survival_hard; do
    if [ -d "$IMPORT_DIR/$world" ]; then
        echo "   - $world"
        docker exec blockhaven-import-helper sh -c "rm -rf /data/$world && cp -r /import/$world /data/"
    fi
done

echo "5. Importing plugin configurations..."
if [ -d "$IMPORT_DIR/plugins" ]; then
    docker exec blockhaven-import-helper sh -c "mkdir -p /data/plugins"
    for plugin_dir in "$IMPORT_DIR/plugins"/*/; do
        plugin_name=$(basename "$plugin_dir")
        echo "   - $plugin_name"
        docker exec blockhaven-import-helper sh -c "rm -rf /data/plugins/$plugin_name && cp -r /import/plugins/$plugin_name /data/plugins/"
    done
fi

echo "6. Importing server configs..."
for config in server.properties bukkit.yml spigot.yml paper-global.yml paper-world-defaults.yml; do
    if [ -f "$IMPORT_DIR/$config" ]; then
        echo "   - $config"
        docker exec blockhaven-import-helper sh -c "cp /import/$config /data/"
    fi
done

echo "7. Setting permissions..."
docker exec blockhaven-import-helper sh -c "chown -R 1000:1000 /data"

echo "8. Cleaning up..."
docker stop blockhaven-import-helper 2>/dev/null || true
rm -rf "$TEMP_DIR"

echo ""
echo "=== Import Complete ==="
echo ""
echo "Start your local server with:"
echo "  docker compose -f docker-compose.local.yml up -d"
echo ""
echo "View logs:"
echo "  docker logs -f blockhaven-local"
echo ""
echo "Connect via:"
echo "  - Java:    localhost:25565"
echo "  - Bedrock: localhost:19132"
echo "  - LAN/Tailscale: <your-ip>:25565"
