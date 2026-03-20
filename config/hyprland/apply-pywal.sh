#!/usr/bin/env bash

# Apply pywal colors from wallpaper
# Usage: apply-pywal.sh <wallpaper_path>

WALLPAPER="$1"
STYLE_BASE="$HOME/.config/waybar/style-base.css"
COLORS_DEFAULT="$HOME/.config/wal/colors-waybar-default.css"
GENERATED_CSS="$HOME/.cache/wal/waybar-style.css"

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

if [ -f "$COLORS_WAYBAR" ]; then
    # Combine pywal colors + base styles
    cat "$COLORS_WAYBAR" "$STYLE_BASE" > "$GENERATED_CSS"
else
    # Fallback to default colors + base styles
    cat "$COLORS_DEFAULT" "$STYLE_BASE" > "$GENERATED_CSS"
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

# Optional: reload swaync if running
if pgrep -x swaync >/dev/null; then
    swaync-client -rs 2>/dev/null
fi

# Optional: reload pywalfox if installed
if command -v pywalfox >/dev/null 2>&1; then
    pywalfox update 2>/dev/null
fi
