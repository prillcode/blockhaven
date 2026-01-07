#!/bin/bash
# BlockHaven Manual Backup Script
# Triggers a manual backup using the mc-backup container

set -e

echo "🔄 Triggering manual backup..."
docker exec blockhaven-backup backup now

echo "✅ Backup triggered successfully!"
echo ""
echo "📦 Recent backups:"
ls -lh backups/ | tail -5
