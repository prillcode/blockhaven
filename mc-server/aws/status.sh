#!/bin/bash
# BlockHaven AWS - Server Status
# Shows current status of the Minecraft server infrastructure
#
# Usage: ./status.sh [options]
#   --json    Output in JSON format
#   --watch   Continuously monitor (refresh every 30s)
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
JSON_OUTPUT=false
WATCH_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --watch)
            WATCH_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--json] [--watch]"
            echo ""
            echo "Options:"
            echo "  --json    Output in JSON format"
            echo "  --watch   Continuously monitor (refresh every 30s)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors (disabled for JSON output)
if [ "$JSON_OUTPUT" = true ]; then
    RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
fi

# AWS CLI args
if [ -n "$AWS_PROFILE" ]; then
    AWS_ARGS="--profile $AWS_PROFILE --region $AWS_REGION"
else
    AWS_ARGS="--region $AWS_REGION"
fi

show_status() {
    # Check if stack exists
    STACK_STATUS=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].StackStatus" \
        --output text \
        $AWS_ARGS 2>/dev/null || echo "NOT_FOUND")

    if [ "$STACK_STATUS" = "NOT_FOUND" ]; then
        if [ "$JSON_OUTPUT" = true ]; then
            echo '{"status": "not_deployed", "message": "CloudFormation stack not found"}'
        else
            echo -e "${RED}CloudFormation stack '$STACK_NAME' not found.${NC}"
            echo ""
            echo "To deploy, run: ./deploy.sh"
        fi
        return 1
    fi

    # Get instance details
    INSTANCE_ID=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].Outputs[?OutputKey=='InstanceId'].OutputValue" \
        --output text \
        $AWS_ARGS)

    INSTANCE_INFO=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query "Reservations[0].Instances[0]" \
        $AWS_ARGS)

    INSTANCE_STATE=$(echo "$INSTANCE_INFO" | jq -r '.State.Name')
    INSTANCE_TYPE=$(echo "$INSTANCE_INFO" | jq -r '.InstanceType')
    PUBLIC_IP=$(echo "$INSTANCE_INFO" | jq -r '.PublicIpAddress // "N/A"')
    LAUNCH_TIME=$(echo "$INSTANCE_INFO" | jq -r '.LaunchTime // "N/A"')

    # Get EBS volume info
    VOLUME_ID=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].Outputs[?OutputKey=='VolumeId'].OutputValue" \
        --output text \
        $AWS_ARGS 2>/dev/null || echo "N/A")

    if [ "$VOLUME_ID" != "N/A" ]; then
        VOLUME_SIZE=$(aws ec2 describe-volumes \
            --volume-ids "$VOLUME_ID" \
            --query "Volumes[0].Size" \
            --output text \
            $AWS_ARGS 2>/dev/null || echo "N/A")
    else
        VOLUME_SIZE="N/A"
    fi

    # Get Elastic IP if exists
    ELASTIC_IP=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].Outputs[?OutputKey=='ElasticIP'].OutputValue" \
        --output text \
        $AWS_ARGS 2>/dev/null || echo "N/A")

    # Check Minecraft port if running
    MC_STATUS="unknown"
    if [ "$INSTANCE_STATE" = "running" ] && [ "$PUBLIC_IP" != "N/A" ] && [ "$PUBLIC_IP" != "null" ]; then
        if nc -z -w2 "$PUBLIC_IP" 25565 2>/dev/null; then
            MC_STATUS="online"
        else
            MC_STATUS="starting"
        fi
    elif [ "$INSTANCE_STATE" = "stopped" ]; then
        MC_STATUS="offline"
    fi

    # Get latest backup info
    LATEST_BACKUP=$(aws s3 ls "s3://${S3_BUCKET}/" $AWS_ARGS 2>/dev/null | grep '\.tar\.gz$' | sort -r | head -1 || echo "")
    if [ -n "$LATEST_BACKUP" ]; then
        BACKUP_DATE=$(echo "$LATEST_BACKUP" | awk '{print $1 " " $2}')
        BACKUP_SIZE=$(echo "$LATEST_BACKUP" | awk '{print $3}')
        BACKUP_FILE=$(echo "$LATEST_BACKUP" | awk '{print $4}')
    else
        BACKUP_DATE="No backups"
        BACKUP_SIZE="0"
        BACKUP_FILE="N/A"
    fi

    # Calculate running time
    if [ "$INSTANCE_STATE" = "running" ] && [ "$LAUNCH_TIME" != "N/A" ]; then
        LAUNCH_EPOCH=$(date -d "$LAUNCH_TIME" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$LAUNCH_TIME" +%s 2>/dev/null || echo "0")
        NOW_EPOCH=$(date +%s)
        RUNNING_SECONDS=$((NOW_EPOCH - LAUNCH_EPOCH))
        RUNNING_HOURS=$((RUNNING_SECONDS / 3600))
        RUNNING_MINS=$(((RUNNING_SECONDS % 3600) / 60))
        UPTIME="${RUNNING_HOURS}h ${RUNNING_MINS}m"
    else
        UPTIME="N/A"
    fi

    # JSON Output
    if [ "$JSON_OUTPUT" = true ]; then
        cat << EOF
{
  "stack_name": "$STACK_NAME",
  "stack_status": "$STACK_STATUS",
  "instance": {
    "id": "$INSTANCE_ID",
    "state": "$INSTANCE_STATE",
    "type": "$INSTANCE_TYPE",
    "public_ip": "$PUBLIC_IP",
    "elastic_ip": "$ELASTIC_IP",
    "launch_time": "$LAUNCH_TIME",
    "uptime": "$UPTIME"
  },
  "minecraft": {
    "status": "$MC_STATUS",
    "java_address": "${PUBLIC_IP}:25565",
    "bedrock_address": "${PUBLIC_IP}:19132"
  },
  "storage": {
    "volume_id": "$VOLUME_ID",
    "size_gb": $VOLUME_SIZE
  },
  "backup": {
    "latest_date": "$BACKUP_DATE",
    "latest_file": "$BACKUP_FILE",
    "size_bytes": $BACKUP_SIZE
  }
}
EOF
        return
    fi

    # Human-readable output
    clear 2>/dev/null || true
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "  ${BOLD}BlockHaven Minecraft Server - Status${NC}"
    echo "  $(date)"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Instance Status
    echo -e "${CYAN}EC2 Instance:${NC}"
    echo "  Instance ID:   $INSTANCE_ID"
    echo "  Type:          $INSTANCE_TYPE"

    case "$INSTANCE_STATE" in
        running)
            echo -e "  State:         ${GREEN}● running${NC}"
            echo "  Uptime:        $UPTIME"
            ;;
        stopped)
            echo -e "  State:         ${RED}○ stopped${NC}"
            ;;
        pending|stopping)
            echo -e "  State:         ${YELLOW}◐ $INSTANCE_STATE${NC}"
            ;;
        *)
            echo -e "  State:         ${RED}? $INSTANCE_STATE${NC}"
            ;;
    esac

    echo ""

    # Network
    echo -e "${CYAN}Network:${NC}"
    if [ "$ELASTIC_IP" != "N/A" ] && [ "$ELASTIC_IP" != "None" ]; then
        echo "  Elastic IP:    $ELASTIC_IP (static)"
    fi
    if [ "$PUBLIC_IP" != "N/A" ] && [ "$PUBLIC_IP" != "null" ]; then
        echo "  Public IP:     $PUBLIC_IP"
    else
        echo "  Public IP:     (none - instance stopped)"
    fi

    echo ""

    # Minecraft Status
    echo -e "${CYAN}Minecraft Server:${NC}"
    case "$MC_STATUS" in
        online)
            echo -e "  Status:        ${GREEN}● ONLINE${NC}"
            echo "  Java:          $PUBLIC_IP:25565"
            echo "  Bedrock:       $PUBLIC_IP:19132"
            ;;
        starting)
            echo -e "  Status:        ${YELLOW}◐ STARTING${NC}"
            echo "  (Server is booting, wait 1-2 minutes)"
            ;;
        offline)
            echo -e "  Status:        ${RED}○ OFFLINE${NC}"
            ;;
        *)
            echo -e "  Status:        ${YELLOW}? Unknown${NC}"
            ;;
    esac

    echo ""

    # Storage
    echo -e "${CYAN}Storage:${NC}"
    echo "  Data Volume:   $VOLUME_ID"
    echo "  Size:          ${VOLUME_SIZE}GB gp3"

    echo ""

    # Backups
    echo -e "${CYAN}Latest Backup:${NC}"
    if [ "$BACKUP_FILE" != "N/A" ]; then
        # Convert bytes to human readable
        if [ "$BACKUP_SIZE" -ge 1073741824 ]; then
            BACKUP_SIZE_H=$(echo "scale=1; $BACKUP_SIZE/1073741824" | bc)GB
        elif [ "$BACKUP_SIZE" -ge 1048576 ]; then
            BACKUP_SIZE_H=$(echo "scale=1; $BACKUP_SIZE/1048576" | bc)MB
        else
            BACKUP_SIZE_H="${BACKUP_SIZE}B"
        fi
        echo "  File:          $BACKUP_FILE"
        echo "  Date:          $BACKUP_DATE"
        echo "  Size:          $BACKUP_SIZE_H"
    else
        echo "  No backups found in s3://${S3_BUCKET}/"
    fi

    echo ""

    # Cost estimate (if running)
    if [ "$INSTANCE_STATE" = "running" ]; then
        echo -e "${CYAN}Current Costs (estimated):${NC}"
        case "$INSTANCE_TYPE" in
            t3a.large)
                HOURLY="0.0752"
                ;;
            t3.large)
                HOURLY="0.0832"
                ;;
            *)
                HOURLY="0.08"
                ;;
        esac
        if [ "$RUNNING_HOURS" -gt 0 ]; then
            SESSION_COST=$(echo "scale=2; $RUNNING_HOURS * $HOURLY" | bc)
            echo "  Hourly rate:   \$$HOURLY/hr"
            echo "  This session:  ~\$$SESSION_COST ($UPTIME)"
        fi
        echo ""
    fi

    # Quick commands
    echo -e "${CYAN}Quick Commands:${NC}"
    if [ "$INSTANCE_STATE" = "running" ]; then
        echo "  Stop server:   ./stop-server.sh"
        echo "  SSH access:    ssh -i <key>.pem ubuntu@$PUBLIC_IP"
        echo "  View logs:     ssh ubuntu@$PUBLIC_IP 'docker logs -f blockhaven-mc'"
    else
        echo "  Start server:  ./start-server.sh --wait"
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Main
if [ "$WATCH_MODE" = true ]; then
    while true; do
        show_status
        echo ""
        echo -e "${YELLOW}Refreshing in 30 seconds... (Ctrl+C to exit)${NC}"
        sleep 30
    done
else
    show_status
fi
