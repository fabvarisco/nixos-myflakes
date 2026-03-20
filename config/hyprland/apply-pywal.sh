#!/usr/bin/env bash

# Apply pywal colors from wallpaper
# Usage: apply-pywal.sh <wallpaper_path>

WALLPAPER="$1"

# Waybar paths
WAYBAR_STYLE_BASE="$HOME/.config/waybar/style-base.css"
WAYBAR_COLORS_DEFAULT="$HOME/.config/wal/colors-waybar-default.css"
WAYBAR_GENERATED_CSS="$HOME/.cache/wal/waybar-style.css"

# SwayNC paths
SWAYNC_STYLE_BASE="$HOME/.config/swaync/style-base.css"
SWAYNC_COLORS_DEFAULT="$HOME/.config/wal/colors-swaync-default.css"
SWAYNC_GENERATED_CSS="$HOME/.cache/wal/swaync-style.css"

# Ensure cache directory exists
mkdir -p "$HOME/.cache/wal"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper not found: $WALLPAPER"
    exit 1
fi

# Generate colors with pywal (no terminal reload)
wal -i "$WALLPAPER" -n -q

# Check if pywal generated colors
COLORS_WAYBAR="$HOME/.cache/wal/colors-waybar.css"
COLORS_SWAYNC="$HOME/.cache/wal/colors-swaync.css"

# Generate Waybar CSS
if [ -f "$COLORS_WAYBAR" ]; then
    cat "$COLORS_WAYBAR" "$WAYBAR_STYLE_BASE" > "$WAYBAR_GENERATED_CSS"
else
    cat "$WAYBAR_COLORS_DEFAULT" "$WAYBAR_STYLE_BASE" > "$WAYBAR_GENERATED_CSS"
fi

# Generate SwayNC CSS
if [ -f "$COLORS_SWAYNC" ]; then
    cat "$COLORS_SWAYNC" "$SWAYNC_STYLE_BASE" > "$SWAYNC_GENERATED_CSS"
else
    cat "$SWAYNC_COLORS_DEFAULT" "$SWAYNC_STYLE_BASE" > "$SWAYNC_GENERATED_CSS"
fi

# Reload waybar
~/.config/hypr/start-waybar.sh

# Reload kitty colors
KITTY_COLORS="$HOME/.cache/wal/colors-kitty.conf"
KITTY_THEME="$HOME/.cache/kitty/current-theme.conf"
if [ -f "$KITTY_COLORS" ]; then
    mkdir -p "$HOME/.cache/kitty"
    cp "$KITTY_COLORS" "$KITTY_THEME"
    # Send SIGUSR1 to all kitty instances to reload config
    pkill -SIGUSR1 kitty 2>/dev/null
fi

# Reload swaync with new colors
~/.config/hypr/start-swaync.sh

# Optional: reload pywalfox if installed
if command -v pywalfox >/dev/null 2>&1; then
    pywalfox update 2>/dev/null
fi
