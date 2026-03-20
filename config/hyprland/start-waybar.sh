#!/usr/bin/env bash

# Waybar startup script with pywal integration

LOCK_FILE="/tmp/waybar-start.lock"
GENERATED_CSS="$HOME/.cache/wal/waybar-style.css"
STYLE_BASE="$HOME/.config/waybar/style-base.css"
COLORS_DEFAULT="$HOME/.config/wal/colors-waybar-default.css"

# Prevent concurrent executions
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

# Kill ALL waybar instances and wait for them to die
killall -q waybar 2>/dev/null
while pgrep -x waybar >/dev/null; do
    sleep 0.05
done

# Ensure cache directory exists
mkdir -p "$HOME/.cache/wal"

# If generated CSS doesn't exist, create with default colors
if [ ! -f "$GENERATED_CSS" ]; then
    if [ -f "$COLORS_DEFAULT" ] && [ -f "$STYLE_BASE" ]; then
        cat "$COLORS_DEFAULT" "$STYLE_BASE" > "$GENERATED_CSS"
    fi
fi

# Start waybar with generated CSS if available
if [ -f "$GENERATED_CSS" ]; then
    waybar -s "$GENERATED_CSS" &
else
    waybar &
fi
disown
