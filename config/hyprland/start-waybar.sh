#!/usr/bin/env bash

# Waybar startup script - simplified (no pywal)

LOCK_FILE="/tmp/waybar-start.lock"

# Prevent concurrent executions
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

# Kill ALL waybar instances and wait for them to die
killall -q waybar 2>/dev/null
while pgrep -x waybar >/dev/null; do
    sleep 0.05
done

# Start waybar
waybar &
disown
