#!/bin/bash
# Setup 50GB data volume and restore from S3
# Run this on the EC2 instance as: sudo bash setup-data-volume.sh

set -e

echo "=========================================="
echo "BlockHaven 50GB Volume Setup"
echo "=========================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run with sudo"
    exit 1
fi

echo "Step 1: Detecting 50GB volume..."
echo "-------------------------------------------"
# Wait a moment for volume to fully attach
sleep 5

# Find the 50GB volume (should be nvme2n1)
DEVICE=""
for dev in /dev/nvme2n1 /dev/nvme1n1 /dev/xvdf; do
    if [ -b "$dev" ]; then
        SIZE=$(lsblk -b -d -o SIZE -n $dev 2>/dev/null | numfmt --to=iec-i 2>/dev/null || echo "0")
        echo "Checking $dev: $SIZE"
        if [[ "$SIZE" == "50"* ]]; then
            DEVICE=$dev
            break
        fi
    fi
done

if [ -z "$DEVICE" ]; then
    echo "✗ ERROR: 50GB volume not found!"
    echo "Current block devices:"
    lsblk
    exit 1
fi

echo "✓ Found 50GB volume: $DEVICE"

echo ""
echo "Step 2: Formatting as XFS..."
echo "-------------------------------------------"
mkfs -t xfs -f $DEVICE
echo "✓ Formatted"

echo ""
echo "Step 3: Mounting to /data..."
echo "-------------------------------------------"
# Stop any running container first
if docker ps -q -f name=blockhaven-mc &>/dev/null; then
    echo "Stopping Minecraft container..."
    docker stop blockhaven-mc || true
fi

# Unmount old /data if mounted
if mountpoint -q /data; then
    umount /data
fi

# Mount new volume
mkdir -p /data
mount $DEVICE /data
echo "✓ Mounted"

# Update fstab
if grep -q "/data" /etc/fstab; then
    sed -i '/\/data/d' /etc/fstab
fi
echo "$DEVICE /data xfs defaults,nofail 0 2" >> /etc/fstab
echo "✓ Added to fstab"

echo ""
echo "Step 4: Creating directory structure..."
echo "-------------------------------------------"
mkdir -p /data/docker-volumes/blockhaven-mc-data
mkdir -p /data/repo
chown -R ubuntu:ubuntu /data
echo "✓ Directories created"

echo ""
echo "Step 5: Restoring from S3..."
echo "-------------------------------------------"
cd /data
sudo -u ubuntu aws s3 ls s3://blockhaven-mc-backups/ | tail -5
echo ""
read -p "Enter backup filename to restore (or press Enter for latest): " BACKUP

if [ -z "$BACKUP" ]; then
    BACKUP=$(aws s3 ls s3://blockhaven-mc-backups/ | grep '\.tar\.gz$' | sort -r | head -1 | awk '{print $4}')
    echo "Using latest backup: $BACKUP"
fi

echo "Downloading backup..."
aws s3 cp "s3://blockhaven-mc-backups/$BACKUP" /tmp/backup.tar.gz

echo "Extracting..."
cd /data/docker-volumes/blockhaven-mc-data
tar -xzf /tmp/backup.tar.gz --strip-components=0
rm /tmp/backup.tar.gz

echo "Fixing ownership..."
chown -R 1000:1000 /data/docker-volumes/blockhaven-mc-data
echo "✓ Restore complete"

echo ""
echo "Step 6: Cloning repository..."
echo "-------------------------------------------"
cd /data
if [ ! -d "/data/repo/.git" ]; then
    sudo -u ubuntu git clone https://github.com/prillcode/blockhaven.git repo
else
    echo "Repository already exists"
fi
cd /data/repo
sudo -u ubuntu git pull origin main
chown -R ubuntu:ubuntu /data/repo
echo "✓ Repository ready"

echo ""
echo "Step 7: Creating docker-compose override..."
echo "-------------------------------------------"
cat > /data/repo/mc-server/docker-compose.override.yml << 'EOF'
services:
  minecraft:
    volumes:
      - /data/docker-volumes/blockhaven-mc-data:/data
      - ./plugins/downloaded_installers:/plugins-local:ro
      - ./extras:/extras:ro
EOF
chown ubuntu:ubuntu /data/repo/mc-server/docker-compose.override.yml
echo "✓ Override created"

echo ""
echo "Step 8: Starting Minecraft server..."
echo "-------------------------------------------"
cd /data/repo/mc-server
sudo -u ubuntu docker compose up -d
echo "✓ Server starting"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Monitor server startup:"
echo "  docker logs -f blockhaven-mc"
echo ""
echo "Check memory usage:"
echo "  docker stats blockhaven-mc"
echo ""
echo "Server should be available at:"
echo "  Java: 100.50.139.37:25565"
echo "  Bedrock: 100.50.139.37:19132"
echo ""
