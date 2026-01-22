#!/bin/bash
# Load and export environment variables from .env.aws
# Usage: source ./load-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env.aws"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env.aws not found at $ENV_FILE"
    return 1
fi

# Export all non-comment, non-empty lines
export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)

echo "✅ Environment variables loaded from .env.aws"
echo "   AWS_REGION: $AWS_REGION"
echo "   AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:10}..."
echo "   STACK_NAME: $STACK_NAME"
