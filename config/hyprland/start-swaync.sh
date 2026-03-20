#!/usr/bin/env bash

# SwayNC startup script with pywal integration

LOCK_FILE="/tmp/swaync-start.lock"
GENERATED_CSS="$HOME/.cache/wal/swaync-style.css"
STYLE_BASE="$HOME/.config/swaync/style-base.css"
COLORS_DEFAULT="$HOME/.config/wal/colors-swaync-default.css"

# Prevent concurrent executions
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

# Kill existing swaync instances and wait
killall -q swaync 2>/dev/null
while pgrep -x swaync >/dev/null; do
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

# Start swaync with generated CSS if available
if [ -f "$GENERATED_CSS" ]; then
    swaync -s "$GENERATED_CSS" &
else
    swaync &
fi
disown
