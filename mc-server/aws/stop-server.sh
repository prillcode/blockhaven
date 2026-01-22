#!/bin/bash
# BlockHaven AWS - Stop Server
# Backs up world data to S3, then stops the EC2 instance
#
# Usage: ./stop-server.sh [options]
#   --no-backup   Skip backup before stopping
#   --force       Stop immediately without confirmation
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
SKIP_BACKUP=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--no-backup] [--force]"
            echo ""
            echo "Options:"
            echo "  --no-backup   Skip backup before stopping"
            echo "  --force       Stop immediately without confirmation"
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
CYAN='\033[0;36m'
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
echo "  BlockHaven AWS - Stop Server"
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

if [ "$CURRENT_STATE" = "stopped" ]; then
    log_info "Server is already stopped!"
    exit 0
fi

if [ "$CURRENT_STATE" != "running" ]; then
    log_error "Instance is in unexpected state: $CURRENT_STATE"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text \
    $AWS_ARGS)

# Confirmation
if [ "$FORCE" = false ]; then
    echo ""
    echo -e "${YELLOW}This will:${NC}"
    if [ "$SKIP_BACKUP" = false ]; then
        echo "  1. Create a backup and upload to S3"
        echo "  2. Stop the Minecraft server"
        echo "  3. Stop the EC2 instance"
    else
        echo "  1. Stop the Minecraft server (NO BACKUP)"
        echo "  2. Stop the EC2 instance"
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

# Perform backup on EC2 instance
if [ "$SKIP_BACKUP" = false ]; then
    log_info "Running backup on EC2 instance..."
    echo ""

    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" << 'REMOTESCRIPT'
        set -e
        cd /data/repo/mc-server
        source .env

        echo "[INFO] Stopping Minecraft server gracefully..."
        docker exec blockhaven-mc rcon-cli "say Server shutting down for backup in 30 seconds..." || true
        sleep 10
        docker exec blockhaven-mc rcon-cli "say Server shutting down in 20 seconds..." || true
        sleep 10
        docker exec blockhaven-mc rcon-cli "say Server shutting down in 10 seconds..." || true
        sleep 5
        docker exec blockhaven-mc rcon-cli "say Server shutting down NOW!" || true
        sleep 5

        # Save and stop
        docker exec blockhaven-mc rcon-cli "save-all" || true
        sleep 3
        docker stop blockhaven-mc

        # Create backup
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        echo "[INFO] Creating backup: $TIMESTAMP.tar.gz"

        cd /data/docker-volumes/blockhaven-mc-data
        tar -czf /tmp/$TIMESTAMP.tar.gz \
            spawn* \
            survival_easy* survival_normal* survival_hard* \
            creative_flat* creative_terrain* \
            plugins/Multiverse-* plugins/EssentialsX plugins/LuckPerms \
            plugins/Vault plugins/UltimateLandClaim plugins/Jobs \
            server.properties bukkit.yml spigot.yml 2>/dev/null || true

        echo "[INFO] Uploading to S3..."
        aws s3 cp /tmp/$TIMESTAMP.tar.gz "s3://${S3_BUCKET}/"

        # Verify upload
        S3_SIZE=$(aws s3api head-object --bucket "$S3_BUCKET" --key "$TIMESTAMP.tar.gz" --query 'ContentLength' --output text 2>/dev/null || echo "0")
        LOCAL_SIZE=$(stat -c%s /tmp/$TIMESTAMP.tar.gz)

        if [ "$LOCAL_SIZE" = "$S3_SIZE" ]; then
            echo "[INFO] Backup verified: s3://${S3_BUCKET}/$TIMESTAMP.tar.gz"
            rm /tmp/$TIMESTAMP.tar.gz
        else
            echo "[ERROR] Backup verification failed!"
            exit 1
        fi
REMOTESCRIPT

    if [ $? -ne 0 ]; then
        log_error "Backup failed! Server NOT stopped."
        log_error "You can force stop with: ./stop-server.sh --no-backup --force"
        exit 1
    fi

    echo ""
    log_info "Backup completed successfully!"
else
    # Just stop the container without backup
    log_warn "Skipping backup as requested"
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" \
        "docker stop blockhaven-mc 2>/dev/null || true"
fi

# Stop EC2 instance
log_info "Stopping EC2 instance..."
aws ec2 stop-instances --instance-ids "$INSTANCE_ID" $AWS_ARGS > /dev/null

log_info "Waiting for instance to stop..."
aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID" $AWS_ARGS

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Server Stopped!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
if [ "$SKIP_BACKUP" = false ]; then
    echo "Backup saved to: s3://${S3_BUCKET}/"
fi
echo ""
echo "To start the server again:"
echo "  ./start-server.sh --wait"
echo ""

# Show cost savings tip
echo -e "${CYAN}Cost Savings:${NC}"
echo "  - Instance stopped = No compute charges"
echo "  - You'll still pay for:"
echo "    * EBS volume (~\$4/month for 50GB gp3)"
echo "    * Elastic IP while not attached (~\$3.60/month)"
echo ""
