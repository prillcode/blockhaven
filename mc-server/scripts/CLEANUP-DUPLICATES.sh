#!/bin/bash
# Remove duplicate/old plugin versions

cd "$(dirname "$0")"

echo "Removing duplicate plugin versions..."

# Keep newest versions only
rm -f data/plugins/bluemap-5.14-paper.jar
rm -f data/plugins/multiverse-inventories-5.3.0.jar
rm -f data/plugins/multiverse-portals-5.1.1.jar
rm -f data/plugins/worldedit-bukkit-7.3.10-beta-01.jar
rm -f data/plugins/worldedit-bukkit-7.3.18.jar
rm -f data/plugins/worldguard-bukkit-7.0.12-dist.jar
rm -f data/plugins/worldguard-bukkit-7.0.15.jar

echo "✓ Cleaned up old plugin versions"
echo ""
echo "Restart server to apply changes:"
echo "  docker compose restart minecraft"
