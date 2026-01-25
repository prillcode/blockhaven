#!/bin/bash
# Pull plugin configs from the remote server to the local repo
#
# Usage: ./scripts/pull-plugin-configs.sh [ssh-host]
# Default SSH host: blockhaven_aws

set -e

SSH_HOST="${1:-blockhaven_aws}"
CONTAINER_NAME="blockhaven-mc"
LOCAL_CONFIGS_DIR="$(dirname "$0")/../plugins/configs"
REMOTE_TMP="/tmp/plugin-configs-export"

# Plugins to track
PLUGINS=(
    "Essentials"
    "Jobs"
    "LuckPerms"
    "Multiverse-Core"
    "Multiverse-Inventories"
    "Multiverse-Portals"
    "StackMob"
    "UltimateLandClaim"
    "WorldGuard"
)

echo "=== Pulling plugin configs from $SSH_HOST ==="
echo ""

# Create local directories
echo "[1/3] Creating local directories..."
for plugin in "${PLUGINS[@]}"; do
    mkdir -p "$LOCAL_CONFIGS_DIR/$plugin"
done

# Copy configs from container to temp dir on remote
echo "[2/3] Extracting configs from container on remote server..."
PLUGINS_CSV=$(IFS=,; echo "${PLUGINS[*]}")
ssh "$SSH_HOST" bash -s "$CONTAINER_NAME" "$REMOTE_TMP" "$PLUGINS_CSV" << 'REMOTE_SCRIPT'
CONTAINER_NAME="$1"
REMOTE_TMP="$2"
PLUGINS_CSV="$3"

IFS=',' read -ra PLUGINS <<< "$PLUGINS_CSV"

rm -rf "$REMOTE_TMP"
mkdir -p "$REMOTE_TMP"

for plugin in "${PLUGINS[@]}"; do
    echo "  Copying $plugin..."
    mkdir -p "$REMOTE_TMP/$plugin"
    docker cp "$CONTAINER_NAME:/data/plugins/$plugin/." "$REMOTE_TMP/$plugin/" 2>/dev/null || echo "    Warning: Could not copy $plugin"
done

echo "  Done extracting to $REMOTE_TMP"
REMOTE_SCRIPT

# Rsync configs down to local
echo "[3/3] Syncing configs to local repo..."
rsync -av \
    --exclude='userdata/' \
    --exclude='userdata-*/' \
    --exclude='playerdata/' \
    --exclude='data/' \
    --exclude='cache/' \
    --exclude='*.db' \
    --exclude='*.sqlite' \
    --include='*/' \
    --include='*.yml' \
    --include='*.yaml' \
    --include='*.conf' \
    --exclude='*' \
    --prune-empty-dirs \
    "$SSH_HOST:$REMOTE_TMP/" "$LOCAL_CONFIGS_DIR/"

# Cleanup remote temp
echo ""
echo "Cleaning up remote temp files..."
ssh "$SSH_HOST" "rm -rf $REMOTE_TMP"

echo ""
echo "=== Done! Configs saved to $LOCAL_CONFIGS_DIR ==="
echo ""
echo "Next steps:"
echo "  1. Review the configs: ls -la $LOCAL_CONFIGS_DIR/*"
echo "  2. Commit them: git add $LOCAL_CONFIGS_DIR && git commit -m 'feat: add plugin configs'"
