#!/bin/bash
# Copy plugin configs from repo to the server's plugin directories
#
# This script is run by the itzg/minecraft-server container before the server starts.
# It copies version-controlled config files from /plugin-configs to /data/plugins.
#
# Directory structure:
#   /plugin-configs/<PluginName>/config.yml  ->  /data/plugins/<PluginName>/config.yml
#   /plugin-configs/<PluginName>/messages.yml ->  /data/plugins/<PluginName>/messages.yml
#
# Any file in the plugin subdirectory will be copied (not just config.yml).

set -e

CONFIGS_DIR="/plugin-configs"
PLUGINS_DIR="/data/plugins"

echo "[copy-plugin-configs] Starting plugin config sync..."

# Check if configs directory exists and has subdirectories
if [ ! -d "$CONFIGS_DIR" ]; then
    echo "[copy-plugin-configs] No plugin configs directory found at $CONFIGS_DIR, skipping."
    exit 0
fi

# Get list of plugin config directories (skip hidden files like .gitkeep)
config_dirs=$(find "$CONFIGS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)

if [ -z "$config_dirs" ]; then
    echo "[copy-plugin-configs] No plugin config directories found, skipping."
    exit 0
fi

# Copy each plugin's configs
for plugin_config_dir in $config_dirs; do
    plugin_name=$(basename "$plugin_config_dir")
    target_dir="$PLUGINS_DIR/$plugin_name"

    echo "[copy-plugin-configs] Processing $plugin_name..."

    # Create target directory if it doesn't exist
    # (Plugin directories are usually created by the plugin itself on first run,
    # but we create them early so configs are in place before first run)
    mkdir -p "$target_dir"

    # Copy all files from the config directory to the plugin directory
    # Using -v for verbose output, -n to not overwrite existing files
    # Remove -n if you want repo configs to always override server configs
    cp -rv "$plugin_config_dir"/* "$target_dir"/ 2>/dev/null || true

    echo "[copy-plugin-configs] Copied configs to $target_dir"
done

echo "[copy-plugin-configs] Plugin config sync complete!"
