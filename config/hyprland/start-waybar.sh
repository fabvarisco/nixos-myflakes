#!/usr/bin/env bash

# Waybar startup script with pywal integration

LOCK_FILE="/tmp/waybar-start.lock"
PID_FILE="/tmp/waybar.pid"
GENERATED_CSS="$HOME/.cache/wal/waybar-style.css"
STYLE_BASE="$HOME/.config/waybar/style-base.css"
COLORS_DEFAULT="$HOME/.config/wal/colors-waybar-default.css"

# Prevent concurrent executions
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

# Check if waybar is already running with a valid PID
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        # Waybar is running, just reload it via SIGUSR2 (reloads style)
        # If CSS changed, we need to restart
        kill "$OLD_PID" 2>/dev/null
        sleep 0.1
    fi
fi

# Kill any remaining waybar instances
# NixOS wraps waybar as .waybar-wrapped
killall -9 .waybar-wrapped waybar 2>/dev/null
sleep 0.1

# Ensure cache directory exists
mkdir -p "$HOME/.cache/wal"

# If generated CSS doesn't exist, create with default colors
if [ ! -f "$GENERATED_CSS" ]; then
    if [ -f "$COLORS_DEFAULT" ] && [ -f "$STYLE_BASE" ]; then
        cat "$COLORS_DEFAULT" "$STYLE_BASE" > "$GENERATED_CSS"
    fi
fi

# Start waybar with generated CSS if available
# Use subshell with closed FD 200 to prevent waybar from inheriting the lock
if [ -f "$GENERATED_CSS" ]; then
    (exec 200>&-; exec waybar -s "$GENERATED_CSS") &
else
    (exec 200>&-; exec waybar) &
fi
WAYBAR_PID=$!
echo "$WAYBAR_PID" > "$PID_FILE"
disown
