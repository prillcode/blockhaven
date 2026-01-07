#!/bin/bash
# BlockHaven Backup Restore Script
# Restores from a backup file

set -e

if [ $# -eq 0 ]; then
    echo "❌ Error: No backup file specified"
    echo ""
    echo "Usage: $0 <backup-file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -1 backups/*.tar.gz 2>/dev/null || echo "  No backups found"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  WARNING: This will stop the server and replace current data!"
echo "📦 Restore from: $BACKUP_FILE"
echo ""
read -p "Are you sure? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo ""
echo "🛑 Stopping Minecraft server..."
docker-compose stop minecraft

echo "📥 Extracting backup..."
tar -xzf "$BACKUP_FILE" -C data/

echo "✅ Backup restored successfully!"
echo ""
echo "▶️  Starting server..."
docker-compose start minecraft

echo ""
echo "✅ Server restarted! Check logs:"
echo "   docker-compose logs -f minecraft"
