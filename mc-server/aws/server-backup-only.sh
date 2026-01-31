#!/bin/bash
# BlockHaven AWS - Backup Only
# Creates a backup of world data and uploads to S3 without stopping the server
#
# Usage: ./server-backup-only.sh [options]
#   --container <name>   Container name (default: blockhaven-mc)
#   --no-stop            Don't stop the container (hot backup - may be inconsistent)
#   --force              Skip confirmation prompt
#
# Requirements:
#   - AWS CLI configured with appropriate credentials
#   - CloudFormation stack already deployed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env.aws" 2>/dev/null || true

# Export AWS credentials for CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION

# Configuration
STACK_NAME="${STACK_NAME:-blockhaven-mc}"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_PROFILE="${AWS_PROFILE:-}"
S3_BUCKET="${S3_BUCKET:-blockhaven-mc-backups}"

# Options
CONTAINER_NAME="blockhaven-mc"
STOP_CONTAINER=true
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --no-stop)
            STOP_CONTAINER=false
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--container <name>] [--no-stop] [--force]"
            echo ""
            echo "Options:"
            echo "  --container <name>   Container name (default: blockhaven-mc)"
            echo "  --no-stop            Don't stop the container (hot backup)"
            echo "  --force              Skip confirmation prompt"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# AWS CLI args
if [ -n "$AWS_PROFILE" ]; then
    AWS_ARGS="--profile $AWS_PROFILE --region $AWS_REGION"
else
    AWS_ARGS="--region $AWS_REGION"
fi

echo ""
echo "=========================================="
echo "  BlockHaven AWS - Backup Only"
echo "=========================================="
echo ""

# Get instance ID from CloudFormation
log_info "Getting instance ID from CloudFormation stack..."
INSTANCE_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query "Stacks[0].Outputs[?OutputKey=='InstanceId'].OutputValue" \
    --output text \
    $AWS_ARGS 2>/dev/null)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
    log_error "Could not find instance ID. Is the CloudFormation stack deployed?"
    exit 1
fi

log_info "Instance ID: $INSTANCE_ID"

# Check current instance state
CURRENT_STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].State.Name" \
    --output text \
    $AWS_ARGS)

log_info "Current state: $CURRENT_STATE"

if [ "$CURRENT_STATE" != "running" ]; then
    log_error "Instance is not running (state: $CURRENT_STATE)"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text \
    $AWS_ARGS)

log_info "Container: $CONTAINER_NAME"

# Confirmation
if [ "$FORCE" = false ]; then
    echo ""
    echo -e "${YELLOW}This will:${NC}"
    if [ "$STOP_CONTAINER" = true ]; then
        echo "  1. Stop the Minecraft container temporarily"
        echo "  2. Create a backup and upload to S3"
        echo "  3. Restart the Minecraft container"
    else
        echo "  1. Create a hot backup (container keeps running)"
        echo "  2. Upload to S3"
        echo -e "  ${YELLOW}Note: Hot backups may have inconsistent world data${NC}"
    fi
    echo ""
    read -r -p "Continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        log_info "Cancelled."
        exit 0
    fi
fi

# Get SSH key from stack or environment
KEY_FILE="${SSH_KEY_FILE:-}"
if [ -z "$KEY_FILE" ]; then
    log_warn "SSH_KEY_FILE not set in .env.aws"
    read -r -p "Enter path to SSH key file: " KEY_FILE
fi

if [ ! -f "$KEY_FILE" ]; then
    log_error "SSH key file not found: $KEY_FILE"
    exit 1
fi

log_info "Running backup on EC2 instance..."
echo ""

# Build the remote script with the container name and stop option
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" << REMOTESCRIPT
    set -e
    CONTAINER_NAME="$CONTAINER_NAME"
    STOP_CONTAINER="$STOP_CONTAINER"
    S3_BUCKET="$S3_BUCKET"

    cd /data/repo/mc-server
    source .env 2>/dev/null || true

    if [ "\$STOP_CONTAINER" = "true" ]; then
        echo "[INFO] Stopping Minecraft server gracefully..."
        docker exec \$CONTAINER_NAME rcon-cli "say Server pausing for backup in 30 seconds..." || true
        sleep 10
        docker exec \$CONTAINER_NAME rcon-cli "say Server pausing in 20 seconds..." || true
        sleep 10
        docker exec \$CONTAINER_NAME rcon-cli "say Server pausing in 10 seconds..." || true
        sleep 5
        docker exec \$CONTAINER_NAME rcon-cli "say Server pausing NOW for backup!" || true
        sleep 5

        # Save and stop
        docker exec \$CONTAINER_NAME rcon-cli "save-all" || true
        sleep 3
        docker stop \$CONTAINER_NAME
    else
        echo "[INFO] Creating hot backup (container still running)..."
        docker exec \$CONTAINER_NAME rcon-cli "say Creating backup..." || true
        docker exec \$CONTAINER_NAME rcon-cli "save-all" || true
        sleep 3
    fi

    # Create backup
    TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
    echo "[INFO] Creating backup: \$TIMESTAMP.tar.gz"

    cd /data/docker-volumes/blockhaven-mc-data
    tar -czf /tmp/\$TIMESTAMP.tar.gz \
        spawn* \
        survival_easy* survival_normal* survival_hard* \
        creative_flat* creative_terrain* \
        plugins/Multiverse-* plugins/EssentialsX plugins/LuckPerms \
        plugins/Vault plugins/UltimateLandClaim plugins/Jobs \
        plugins/Geyser-Spigot plugins/floodgate \
        server.properties bukkit.yml spigot.yml 2>/dev/null || true

    echo "[INFO] Uploading to S3..."
    aws s3 cp /tmp/\$TIMESTAMP.tar.gz "s3://\${S3_BUCKET}/"

    # Verify upload
    S3_SIZE=\$(aws s3api head-object --bucket "\$S3_BUCKET" --key "\$TIMESTAMP.tar.gz" --query 'ContentLength' --output text 2>/dev/null || echo "0")
    LOCAL_SIZE=\$(stat -c%s /tmp/\$TIMESTAMP.tar.gz)

    if [ "\$LOCAL_SIZE" = "\$S3_SIZE" ]; then
        echo "[INFO] Backup verified: s3://\${S3_BUCKET}/\$TIMESTAMP.tar.gz"
        rm /tmp/\$TIMESTAMP.tar.gz
    else
        echo "[ERROR] Backup verification failed!"
        # Restart container if we stopped it
        if [ "\$STOP_CONTAINER" = "true" ]; then
            docker start \$CONTAINER_NAME
        fi
        exit 1
    fi

    # Restart container if we stopped it
    if [ "\$STOP_CONTAINER" = "true" ]; then
        echo "[INFO] Restarting Minecraft server..."
        docker start \$CONTAINER_NAME
        sleep 5
        docker exec \$CONTAINER_NAME rcon-cli "say Server is back online!" || true
    else
        docker exec \$CONTAINER_NAME rcon-cli "say Backup complete!" || true
    fi
REMOTESCRIPT

if [ $? -ne 0 ]; then
    log_error "Backup failed!"
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Backup Completed!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Backup saved to: s3://${S3_BUCKET}/"
echo ""
