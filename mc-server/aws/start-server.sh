#!/bin/bash
# BlockHaven AWS - Start Server
# Starts the EC2 instance running the Minecraft server
#
# Usage: ./start-server.sh [options]
#   --wait      Wait for server to be fully running
#   --connect   Show connection info after starting
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

# Options
WAIT_FOR_READY=false
SHOW_CONNECT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --wait)
            WAIT_FOR_READY=true
            shift
            ;;
        --connect)
            SHOW_CONNECT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--wait] [--connect]"
            echo ""
            echo "Options:"
            echo "  --wait      Wait for server to be fully running"
            echo "  --connect   Show connection info after starting"
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
echo "  BlockHaven AWS - Start Server"
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
    log_error "Stack name: $STACK_NAME"
    echo ""
    echo "To deploy the stack, run:"
    echo "  ./deploy.sh"
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

if [ "$CURRENT_STATE" = "running" ]; then
    log_info "Server is already running!"
elif [ "$CURRENT_STATE" = "stopped" ]; then
    log_info "Starting instance..."
    aws ec2 start-instances --instance-ids "$INSTANCE_ID" $AWS_ARGS > /dev/null
    log_info "Start command sent."
elif [ "$CURRENT_STATE" = "pending" ]; then
    log_info "Instance is already starting..."
else
    log_error "Instance is in unexpected state: $CURRENT_STATE"
    exit 1
fi

# Wait for running state
if [ "$WAIT_FOR_READY" = true ] || [ "$SHOW_CONNECT" = true ]; then
    log_info "Waiting for instance to be running..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" $AWS_ARGS
    log_info "Instance is running!"

    # Get public IP
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text \
        $AWS_ARGS)

    if [ "$WAIT_FOR_READY" = true ]; then
        log_info "Waiting for Minecraft server to be ready..."
        echo "  (This may take 2-3 minutes on first boot)"

        # Try to connect to Minecraft port
        ATTEMPTS=0
        MAX_ATTEMPTS=60
        while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
            if nc -z -w2 "$PUBLIC_IP" 25565 2>/dev/null; then
                echo ""
                log_info "Minecraft server is ready!"
                break
            fi
            ATTEMPTS=$((ATTEMPTS + 1))
            printf "."
            sleep 5
        done

        if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
            echo ""
            log_warn "Timeout waiting for Minecraft port. Server may still be starting."
            log_warn "Check with: ssh ubuntu@$PUBLIC_IP 'docker logs blockhaven-mc'"
        fi
    fi
fi

# Get public IP for display
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text \
    $AWS_ARGS)

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Server Started!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$SHOW_CONNECT" = true ] || [ "$WAIT_FOR_READY" = true ]; then
    echo -e "${CYAN}Connection Info:${NC}"
    echo "  Java Edition:    $PUBLIC_IP:25565"
    echo "  Bedrock Edition: $PUBLIC_IP:19132"
    echo ""
    echo -e "${CYAN}SSH Access:${NC}"
    echo "  ssh -i <your-key>.pem ubuntu@$PUBLIC_IP"
    echo ""
    echo -e "${CYAN}Server Logs:${NC}"
    echo "  ssh ubuntu@$PUBLIC_IP 'docker logs -f blockhaven-mc'"
    echo ""
fi

echo -e "${YELLOW}Remember:${NC} Stop the server when not playing to save costs!"
echo "  ./stop-server.sh"
echo ""
