#!/bin/bash
# BlockHaven S3 Backup Script
# Creates a backup of world data and plugin configs, uploads to S3, then cleans up
#
# Usage: ./s3-backup.sh [options]
#   --no-stop     Don't stop the container (uses save-all instead, less safe)
#   --keep-local  Keep local tarball after upload
#   --dry-run     Show what would be done without executing
#
# Authentication (choose one):
#   - AWS_PROFILE: Use a named AWS CLI profile (default: bgrweb)
#   - AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY: Use access keys directly
#
# Requirements:
#   - AWS CLI installed and configured
#   - Docker access to the minecraft container

set -e

# Configuration
CONTAINER_NAME="${MC_CONTAINER_NAME:-blockhaven-local}"
S3_BUCKET="${S3_BUCKET:-blockhaven-mc-backups}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TARBALL_NAME="${TIMESTAMP}.tar.gz"
TARBALL_PATH="${BACKUP_DIR}/${TARBALL_NAME}"

# AWS Authentication: Use access keys if set, otherwise use profile
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    AWS_ARGS=""
    AUTH_METHOD="access keys"
else
    AWS_PROFILE="${AWS_PROFILE:-bgrweb}"
    AWS_ARGS="--profile $AWS_PROFILE"
    AUTH_METHOD="profile '$AWS_PROFILE'"
fi

# Options
STOP_CONTAINER=true
KEEP_LOCAL=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-stop)
            STOP_CONTAINER=false
            shift
            ;;
        --keep-local)
            KEEP_LOCAL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--no-stop] [--keep-local] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --no-stop     Don't stop container (uses RCON save-all instead)"
            echo "  --keep-local  Keep local tarball after S3 upload"
            echo "  --dry-run     Show what would be done without executing"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Please install it first."
        exit 1
    fi

    # Check AWS credentials
    log_info "Using AWS authentication: $AUTH_METHOD"
    if [ -n "$AWS_ARGS" ]; then
        if ! aws configure list $AWS_ARGS &> /dev/null; then
            log_error "AWS profile not configured. Run: aws configure --profile $AWS_PROFILE"
            exit 1
        fi
    fi

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found."
        exit 1
    fi

    # Check container exists and is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_error "Container '$CONTAINER_NAME' is not running."
        exit 1
    fi

    # Check S3 bucket exists
    if ! aws s3 ls "s3://${S3_BUCKET}" $AWS_ARGS &> /dev/null; then
        log_error "S3 bucket '$S3_BUCKET' not accessible."
        exit 1
    fi

    log_info "All prerequisites met."
}

# Flush world data to disk
flush_world_data() {
    log_info "Flushing world data to disk..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: docker exec $CONTAINER_NAME rcon-cli 'save-all flush'"
        echo "  [DRY-RUN] Would run: docker exec $CONTAINER_NAME rcon-cli 'save-off'"
        return
    fi

    # Save all world data
    docker exec "$CONTAINER_NAME" rcon-cli "save-all flush" || true

    # Disable auto-save during backup
    docker exec "$CONTAINER_NAME" rcon-cli "save-off" || true

    # Give it a moment to complete
    sleep 2
}

# Re-enable auto-save
enable_autosave() {
    log_info "Re-enabling auto-save..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: docker exec $CONTAINER_NAME rcon-cli 'save-on'"
        return
    fi

    docker exec "$CONTAINER_NAME" rcon-cli "save-on" || true
}

# Stop the container
stop_container() {
    log_info "Stopping container '$CONTAINER_NAME'..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: docker stop $CONTAINER_NAME"
        return
    fi

    docker stop "$CONTAINER_NAME"
    log_info "Container stopped."
}

# Start the container
start_container() {
    log_info "Starting container '$CONTAINER_NAME'..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: docker start $CONTAINER_NAME"
        return
    fi

    docker start "$CONTAINER_NAME"
    log_info "Container started."
}

# Create the backup tarball
create_backup() {
    log_info "Creating backup tarball..."

    # Ensure backup directory exists
    mkdir -p "$BACKUP_DIR"

    # Create temp directory for staging
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would copy world directories and plugin configs to temp dir"
        echo "  [DRY-RUN] Would create tarball: $TARBALL_PATH"
        return
    fi

    log_info "Copying world data..."

    # Copy all world directories (excluding cache/temp files)
    # Note: docker cp works on stopped containers, no need for docker exec checks
    for world in spawn survival_easy survival_easy_nether survival_easy_the_end \
                 survival_normal survival_normal_nether survival_normal_the_end \
                 survival_hard survival_hard_nether survival_hard_the_end \
                 creative_flat creative_terrain; do
        docker cp "$CONTAINER_NAME:/data/$world" "$TEMP_DIR/" 2>/dev/null || true
    done

    log_info "Copying plugin configs..."

    # Copy important plugin configurations
    mkdir -p "$TEMP_DIR/plugins"
    for plugin in Multiverse-Core Multiverse-NetherPortals Multiverse-Portals \
                  Multiverse-Inventories EssentialsX LuckPerms Vault \
                  UltimateLandClaim Jobs; do
        docker cp "$CONTAINER_NAME:/data/plugins/$plugin" "$TEMP_DIR/plugins/" 2>/dev/null || true
    done

    # Copy server configs
    for config in server.properties bukkit.yml spigot.yml paper-global.yml; do
        docker cp "$CONTAINER_NAME:/data/$config" "$TEMP_DIR/" 2>/dev/null || true
    done

    log_info "Creating tarball..."

    # Create the tarball
    tar -czvf "$TARBALL_PATH" -C "$TEMP_DIR" . > /dev/null

    TARBALL_SIZE=$(du -h "$TARBALL_PATH" | cut -f1)
    log_info "Backup created: $TARBALL_PATH ($TARBALL_SIZE)"
}

# Upload to S3
upload_to_s3() {
    log_info "Uploading to S3..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: aws s3 cp $TARBALL_PATH s3://$S3_BUCKET/ $AWS_ARGS"
        return
    fi

    aws s3 cp "$TARBALL_PATH" "s3://${S3_BUCKET}/" $AWS_ARGS

    log_info "Upload complete: s3://${S3_BUCKET}/${TARBALL_NAME}"
}

# Verify S3 upload
verify_upload() {
    log_info "Verifying upload..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would verify S3 object exists and check size"
        return 0
    fi

    # Get local file size
    LOCAL_SIZE=$(stat -c%s "$TARBALL_PATH" 2>/dev/null || stat -f%z "$TARBALL_PATH")

    # Get S3 file size
    S3_SIZE=$(aws s3api head-object --bucket "$S3_BUCKET" --key "$TARBALL_NAME" $AWS_ARGS --query 'ContentLength' --output text 2>/dev/null || echo "0")

    if [ "$LOCAL_SIZE" = "$S3_SIZE" ]; then
        log_info "Upload verified (size: $LOCAL_SIZE bytes)"
        return 0
    else
        log_error "Upload verification failed! Local: $LOCAL_SIZE, S3: $S3_SIZE"
        return 1
    fi
}

# Cleanup local files
cleanup_local() {
    if [ "$KEEP_LOCAL" = true ]; then
        log_info "Keeping local tarball: $TARBALL_PATH"
        return
    fi

    log_info "Cleaning up local tarball..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would delete: $TARBALL_PATH"
        return
    fi

    rm -f "$TARBALL_PATH"
    log_info "Local tarball deleted."
}

# List recent S3 backups
list_recent_backups() {
    log_info "Recent backups in S3:"
    aws s3 ls "s3://${S3_BUCKET}/" $AWS_ARGS | tail -5
}

# Main execution
main() {
    echo ""
    echo "=========================================="
    echo "  BlockHaven S3 Backup"
    echo "  $(date)"
    echo "=========================================="
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    check_prerequisites

    if [ "$STOP_CONTAINER" = true ]; then
        # Safer method: stop container completely
        stop_container
        create_backup
        start_container
    else
        # Faster method: use RCON to flush and pause saves
        flush_world_data
        create_backup
        enable_autosave
    fi

    upload_to_s3

    if verify_upload; then
        cleanup_local
        echo ""
        log_info "Backup completed successfully!"
        list_recent_backups
    else
        log_error "Backup verification failed. Local file retained."
        exit 1
    fi

    echo ""
}

main
