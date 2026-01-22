#!/bin/bash
# BlockHaven AWS - Deploy CloudFormation Stack
# Creates or updates the Minecraft server infrastructure
#
# Usage: ./deploy.sh [options]
#   --update    Update existing stack instead of create
#   --delete    Delete the stack (WARNING: keeps EBS volume)
#   --dry-run   Show what would be deployed without executing
#
# Requirements:
#   - AWS CLI configured with appropriate credentials
#   - .env.aws file configured with your settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
if [ ! -f "$SCRIPT_DIR/.env.aws" ]; then
    echo "ERROR: .env.aws not found!"
    echo ""
    echo "To get started:"
    echo "  1. Copy the example: cp .env.aws.example .env.aws"
    echo "  2. Edit .env.aws with your settings"
    echo "  3. Run this script again"
    exit 1
fi

source "$SCRIPT_DIR/.env.aws"

# Export AWS credentials for CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION

# Validate required variables
REQUIRED_VARS="AWS_REGION STACK_NAME S3_BUCKET KEY_PAIR_NAME RCON_PASSWORD"
for var in $REQUIRED_VARS; do
    if [ -z "${!var}" ]; then
        echo "ERROR: $var not set in .env.aws"
        exit 1
    fi
done

# Options
UPDATE_MODE=false
DELETE_MODE=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --delete)
            DELETE_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--update] [--delete] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --update    Update existing stack"
            echo "  --delete    Delete the stack (EBS volume retained)"
            echo "  --dry-run   Show what would be deployed"
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
echo "═══════════════════════════════════════════════════════════════"
echo "  BlockHaven AWS - CloudFormation Deployment"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Delete mode
if [ "$DELETE_MODE" = true ]; then
    log_warn "This will DELETE the CloudFormation stack: $STACK_NAME"
    log_warn "The EBS data volume will be RETAINED (not deleted)"
    echo ""
    read -r -p "Are you sure? Type 'delete' to confirm: " CONFIRM
    if [ "$CONFIRM" != "delete" ]; then
        log_info "Cancelled."
        exit 0
    fi

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would delete stack: $STACK_NAME"
        exit 0
    fi

    log_info "Deleting stack..."
    aws cloudformation delete-stack --stack-name "$STACK_NAME" $AWS_ARGS

    log_info "Waiting for deletion..."
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" $AWS_ARGS

    log_info "Stack deleted!"
    echo ""
    echo "Note: The EBS volume was retained. To delete it manually:"
    echo "  aws ec2 delete-volume --volume-id <volume-id> $AWS_ARGS"
    exit 0
fi

# Show configuration
echo -e "${CYAN}Configuration:${NC}"
echo "  Stack Name:      $STACK_NAME"
echo "  Region:          $AWS_REGION"
echo "  Instance Type:   ${INSTANCE_TYPE:-t3a.large}"
echo "  Volume Size:     ${VOLUME_SIZE:-50}GB"
echo "  S3 Bucket:       $S3_BUCKET"
echo "  Key Pair:        $KEY_PAIR_NAME"
echo "  Elastic IP:      ${USE_ELASTIC_IP:-true}"
echo "  Spot Instance:   ${USE_SPOT_INSTANCE:-false}"
echo "  SSH CIDR:        ${ALLOWED_SSH_CIDR:-0.0.0.0/0}"
echo "  Git Repo:        ${GIT_REPO_URL:-https://github.com/prillcode/blockhaven.git}"
echo "  Git Branch:      ${GIT_BRANCH:-main}"
echo ""

# Check if stack exists
STACK_EXISTS=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query "Stacks[0].StackStatus" \
    --output text \
    $AWS_ARGS 2>/dev/null || echo "NOT_EXISTS")

if [ "$STACK_EXISTS" != "NOT_EXISTS" ]; then
    if [ "$UPDATE_MODE" = false ]; then
        log_warn "Stack '$STACK_NAME' already exists (status: $STACK_EXISTS)"
        log_warn "Use --update to update, or --delete to remove first"
        exit 1
    fi
    OPERATION="update-stack"
    WAIT_COMMAND="stack-update-complete"
    log_info "Updating existing stack..."
else
    OPERATION="create-stack"
    WAIT_COMMAND="stack-create-complete"
    log_info "Creating new stack..."
fi

# Build parameters
PARAMS="ParameterKey=InstanceType,ParameterValue=${INSTANCE_TYPE:-t3a.large}"
PARAMS="$PARAMS ParameterKey=KeyPairName,ParameterValue=$KEY_PAIR_NAME"
PARAMS="$PARAMS ParameterKey=S3BucketName,ParameterValue=$S3_BUCKET"
PARAMS="$PARAMS ParameterKey=VolumeSize,ParameterValue=${VOLUME_SIZE:-50}"
PARAMS="$PARAMS ParameterKey=UseElasticIP,ParameterValue=${USE_ELASTIC_IP:-true}"
PARAMS="$PARAMS ParameterKey=UseSpotInstance,ParameterValue=${USE_SPOT_INSTANCE:-false}"
PARAMS="$PARAMS ParameterKey=RconPassword,ParameterValue=$RCON_PASSWORD"
PARAMS="$PARAMS ParameterKey=ServerOps,ParameterValue=${SERVER_OPS:-PRLLAGER207}"
PARAMS="$PARAMS ParameterKey=AllowedSSHCidr,ParameterValue=${ALLOWED_SSH_CIDR:-0.0.0.0/0}"
PARAMS="$PARAMS ParameterKey=GitRepoUrl,ParameterValue=${GIT_REPO_URL:-https://github.com/prillcode/blockhaven.git}"
PARAMS="$PARAMS ParameterKey=GitBranch,ParameterValue=${GIT_BRANCH:-main}"

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "[DRY-RUN] Would run:"
    echo "  aws cloudformation $OPERATION \\"
    echo "    --stack-name $STACK_NAME \\"
    echo "    --template-body file://$SCRIPT_DIR/cloudformation.yaml \\"
    echo "    --parameters $PARAMS \\"
    echo "    --capabilities CAPABILITY_NAMED_IAM"
    exit 0
fi

# Deploy
log_info "Deploying CloudFormation stack..."
echo ""

aws cloudformation $OPERATION \
    --stack-name "$STACK_NAME" \
    --template-body "file://$SCRIPT_DIR/cloudformation.yaml" \
    --parameters $PARAMS \
    --capabilities CAPABILITY_NAMED_IAM \
    $AWS_ARGS

log_info "Waiting for deployment to complete..."
log_info "(This may take 5-10 minutes)"
echo ""

# Monitor progress
aws cloudformation wait $WAIT_COMMAND --stack-name "$STACK_NAME" $AWS_ARGS &
WAIT_PID=$!

# Show events while waiting
while kill -0 $WAIT_PID 2>/dev/null; do
    LATEST_EVENT=$(aws cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --query "StackEvents[0].[ResourceStatus, ResourceType, LogicalResourceId]" \
        --output text \
        $AWS_ARGS 2>/dev/null | head -1)
    echo -e "  ${YELLOW}$LATEST_EVENT${NC}"
    sleep 10
done

wait $WAIT_PID
DEPLOY_RESULT=$?

if [ $DEPLOY_RESULT -ne 0 ]; then
    log_error "Deployment failed!"
    echo ""
    echo "Check events with:"
    echo "  aws cloudformation describe-stack-events --stack-name $STACK_NAME $AWS_ARGS"
    exit 1
fi

# Get outputs
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

OUTPUTS=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query "Stacks[0].Outputs" \
    $AWS_ARGS)

INSTANCE_ID=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="InstanceId") | .OutputValue')
PUBLIC_IP=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="PublicIP") | .OutputValue')

echo -e "${CYAN}Instance Info:${NC}"
echo "  Instance ID:   $INSTANCE_ID"
echo "  Public IP:     $PUBLIC_IP"
echo ""

echo -e "${CYAN}Connection Info:${NC}"
echo "  Java Edition:    $PUBLIC_IP:25565"
echo "  Bedrock Edition: $PUBLIC_IP:19132"
echo "  SSH:             ssh -i ~/.ssh/blockhaven-key.pem ubuntu@$PUBLIC_IP"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo "  1. Wait 2-3 minutes for the Minecraft server to start"
echo "  2. Check status:  ./status.sh"
echo "  3. View logs:     ssh ubuntu@$PUBLIC_IP 'docker logs -f blockhaven-mc'"
echo ""

echo -e "${YELLOW}Cost Reminder:${NC}"
echo "  Running t3a.large costs ~\$0.0752/hour (~\$1.80/day)"
echo "  Stop when not playing: ./stop-server.sh"
echo ""
