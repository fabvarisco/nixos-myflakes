#!/usr/bin/env bash

# Apply matugen colors from wallpaper
# Usage: apply-theme.sh <wallpaper_path>

WALLPAPER="$1"

# Ensure cache directory exists
mkdir -p "$HOME/.cache/matugen"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper not found: $WALLPAPER"
    exit 1
fi

# Store current wallpaper path
echo "$WALLPAPER" > "$HOME/.cache/current_wallpaper"

# Generate colors with matugen (this also reloads AGS via config.toml)
matugen image "$WALLPAPER"

# Reload kitty colors if available
KITTY_COLORS="$HOME/.cache/matugen/kitty-colors.conf"
KITTY_THEME="$HOME/.cache/kitty/current-theme.conf"
if [ -f "$KITTY_COLORS" ]; then
    mkdir -p "$HOME/.cache/kitty"
    cp "$KITTY_COLORS" "$KITTY_THEME"
    # Send SIGUSR1 to all kitty instances to reload config
    pkill -SIGUSR1 kitty 2>/dev/null
fi

echo "Theme applied from: $WALLPAPER"
