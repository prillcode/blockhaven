#!/bin/bash
# BlockHaven S3 Restore Script
# Lists available backups from S3 and restores selected backup to the server
#
# Usage: ./s3-restore.sh [options]
#   --list        List available backups without restoring
#   --backup NUM  Restore backup number NUM from the list (1 = most recent)
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
CONTAINER_NAME="${MC_CONTAINER_NAME:-blockhaven-mc}"
S3_BUCKET="${S3_BUCKET:-blockhaven-mc-backups}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTORE_DIR="${SCRIPT_DIR}/../restore-temp"

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
LIST_ONLY=false
BACKUP_NUM=""
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --list)
            LIST_ONLY=true
            shift
            ;;
        --backup)
            BACKUP_NUM="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--list] [--backup NUM] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --list        List available backups without restoring"
            echo "  --backup NUM  Restore backup number NUM (1 = most recent)"
            echo "  --dry-run     Show what would be done without executing"
            echo ""
            echo "Environment variables:"
            echo "  MC_CONTAINER_NAME  Container name (default: blockhaven-local)"
            echo "  AWS_PROFILE        AWS profile (default: bgrweb)"
            echo "  S3_BUCKET          S3 bucket (default: blockhaven-mc-backups)"
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
CYAN='\033[0;36m'
BOLD='\033[1m'
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

    # Check S3 bucket exists
    if ! aws s3 ls "s3://${S3_BUCKET}" $AWS_ARGS &> /dev/null; then
        log_error "S3 bucket '$S3_BUCKET' not accessible."
        exit 1
    fi

    # Check Docker (only if not list-only)
    if [ "$LIST_ONLY" = false ]; then
        if ! command -v docker &> /dev/null; then
            log_error "Docker not found."
            exit 1
        fi
    fi

    log_info "All prerequisites met."
}

# Fetch and display available backups
list_backups() {
    log_info "Fetching available backups from S3..."
    echo ""

    # Get list of backups, sorted newest first
    BACKUP_LIST=$(aws s3 ls "s3://${S3_BUCKET}/" $AWS_ARGS 2>/dev/null | grep '\.tar\.gz$' | sort -r)

    if [ -z "$BACKUP_LIST" ]; then
        log_error "No backups found in s3://${S3_BUCKET}/"
        exit 1
    fi

    echo -e "${BOLD}Available Backups:${NC}"
    echo "─────────────────────────────────────────────────────────────"
    printf "${BOLD}%-4s %-12s %-10s %s${NC}\n" "#" "Date" "Size" "Filename"
    echo "─────────────────────────────────────────────────────────────"

    COUNT=1
    while IFS= read -r line; do
        # Parse the S3 ls output: 2026-01-21 21:43:30  121456789 filename.tar.gz
        DATE=$(echo "$line" | awk '{print $1}')
        TIME=$(echo "$line" | awk '{print $2}')
        SIZE_BYTES=$(echo "$line" | awk '{print $3}')
        FILENAME=$(echo "$line" | awk '{print $4}')

        # Convert bytes to human readable
        if [ "$SIZE_BYTES" -ge 1073741824 ]; then
            SIZE=$(echo "scale=1; $SIZE_BYTES/1073741824" | bc)GB
        elif [ "$SIZE_BYTES" -ge 1048576 ]; then
            SIZE=$(echo "scale=1; $SIZE_BYTES/1048576" | bc)MB
        else
            SIZE=$(echo "scale=1; $SIZE_BYTES/1024" | bc)KB
        fi

        # Format date from filename if possible (YYYYMMDD_HHMMSS.tar.gz)
        if [[ "$FILENAME" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\.tar\.gz$ ]]; then
            DISPLAY_DATE="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}"
        else
            DISPLAY_DATE="$DATE $TIME"
        fi

        printf "%-4s %-12s %-10s %s\n" "[$COUNT]" "$DISPLAY_DATE" "$SIZE" "$FILENAME"

        # Store in array for selection
        BACKUP_FILES[$COUNT]="$FILENAME"
        COUNT=$((COUNT + 1))
    done <<< "$BACKUP_LIST"

    echo "─────────────────────────────────────────────────────────────"
    TOTAL_BACKUPS=$((COUNT - 1))
    echo -e "Total: ${BOLD}$TOTAL_BACKUPS${NC} backups"
    echo ""
}

# Prompt user to select a backup
select_backup() {
    if [ -n "$BACKUP_NUM" ]; then
        # Backup number provided via argument
        if [ "$BACKUP_NUM" -lt 1 ] || [ "$BACKUP_NUM" -gt "$TOTAL_BACKUPS" ]; then
            log_error "Invalid backup number: $BACKUP_NUM (valid: 1-$TOTAL_BACKUPS)"
            exit 1
        fi
        SELECTED_BACKUP="${BACKUP_FILES[$BACKUP_NUM]}"
        log_info "Selected backup #$BACKUP_NUM: $SELECTED_BACKUP"
    else
        # Interactive selection
        echo -e "${CYAN}Enter backup number to restore (1-$TOTAL_BACKUPS), or 'q' to quit:${NC}"
        read -r -p "> " SELECTION

        if [ "$SELECTION" = "q" ] || [ "$SELECTION" = "Q" ]; then
            log_info "Restore cancelled."
            exit 0
        fi

        if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$TOTAL_BACKUPS" ]; then
            log_error "Invalid selection: $SELECTION"
            exit 1
        fi

        SELECTED_BACKUP="${BACKUP_FILES[$SELECTION]}"
        echo ""
        log_info "Selected: $SELECTED_BACKUP"
    fi
}

# Confirm restore action
confirm_restore() {
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ${RED}WARNING: This will overwrite existing server data!${YELLOW}         ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "This will:"
    echo "  1. Stop the Minecraft server"
    echo "  2. Download backup: $SELECTED_BACKUP"
    echo "  3. Replace world data and plugin configs"
    echo "  4. Restart the server"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_warn "DRY RUN MODE - No changes will be made"
        return 0
    fi

    read -r -p "Are you sure you want to continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        log_info "Restore cancelled."
        exit 0
    fi
}

# Stop the container
stop_container() {
    log_info "Stopping container '$CONTAINER_NAME'..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: docker stop $CONTAINER_NAME"
        return
    fi

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker stop "$CONTAINER_NAME"
        log_info "Container stopped."
    else
        log_warn "Container not running, skipping stop."
    fi
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

# Download backup from S3
download_backup() {
    log_info "Downloading backup from S3..."

    mkdir -p "$RESTORE_DIR"
    LOCAL_TARBALL="${RESTORE_DIR}/${SELECTED_BACKUP}"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would run: aws s3 cp s3://$S3_BUCKET/$SELECTED_BACKUP $LOCAL_TARBALL $AWS_ARGS"
        return
    fi

    aws s3 cp "s3://${S3_BUCKET}/${SELECTED_BACKUP}" "$LOCAL_TARBALL" $AWS_ARGS

    log_info "Downloaded to: $LOCAL_TARBALL"
}

# Restore backup to container
restore_backup() {
    log_info "Restoring backup to container..."

    LOCAL_TARBALL="${RESTORE_DIR}/${SELECTED_BACKUP}"
    EXTRACT_DIR="${RESTORE_DIR}/extracted"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would extract tarball to $EXTRACT_DIR"
        echo "  [DRY-RUN] Would copy world directories to container"
        echo "  [DRY-RUN] Would copy plugin configs to container"
        return
    fi

    # Extract tarball
    log_info "Extracting backup..."
    rm -rf "$EXTRACT_DIR"
    mkdir -p "$EXTRACT_DIR"
    tar -xzf "$LOCAL_TARBALL" -C "$EXTRACT_DIR"

    # Copy world directories
    log_info "Restoring world data..."
    for world in "$EXTRACT_DIR"/*; do
        if [ -d "$world" ] && [ "$(basename "$world")" != "plugins" ]; then
            WORLD_NAME=$(basename "$world")
            log_info "  Restoring world: $WORLD_NAME"
            # Remove existing world in container
            docker exec "$CONTAINER_NAME" rm -rf "/data/$WORLD_NAME" 2>/dev/null || true
            # Copy new world data
            docker cp "$world" "$CONTAINER_NAME:/data/"
        fi
    done

    # Copy plugin configs
    if [ -d "$EXTRACT_DIR/plugins" ]; then
        log_info "Restoring plugin configs..."
        for plugin in "$EXTRACT_DIR/plugins"/*; do
            if [ -d "$plugin" ]; then
                PLUGIN_NAME=$(basename "$plugin")
                log_info "  Restoring plugin config: $PLUGIN_NAME"
                # Remove existing plugin config in container
                docker exec "$CONTAINER_NAME" rm -rf "/data/plugins/$PLUGIN_NAME" 2>/dev/null || true
                # Copy new plugin config
                docker cp "$plugin" "$CONTAINER_NAME:/data/plugins/"
            fi
        done
    fi

    # Copy server configs
    for config in server.properties bukkit.yml spigot.yml paper-global.yml; do
        if [ -f "$EXTRACT_DIR/$config" ]; then
            log_info "  Restoring config: $config"
            docker cp "$EXTRACT_DIR/$config" "$CONTAINER_NAME:/data/"
        fi
    done

    log_info "Restore complete."
}

# Cleanup temporary files
cleanup() {
    log_info "Cleaning up temporary files..."

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] Would delete: $RESTORE_DIR"
        return
    fi

    rm -rf "$RESTORE_DIR"
    log_info "Cleanup complete."
}

# Main execution
main() {
    echo ""
    echo "=========================================="
    echo "  BlockHaven S3 Restore"
    echo "  $(date)"
    echo "=========================================="
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    check_prerequisites
    list_backups

    if [ "$LIST_ONLY" = true ]; then
        exit 0
    fi

    select_backup
    confirm_restore
    stop_container
    download_backup
    restore_backup
    start_container
    cleanup

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Restore completed successfully!${NC}"
    echo -e "${GREEN}  Backup: $SELECTED_BACKUP${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    log_info "The server is starting up. It may take a minute to fully initialize."
    log_info "Check logs with: docker logs -f $CONTAINER_NAME"
    echo ""
}

main
