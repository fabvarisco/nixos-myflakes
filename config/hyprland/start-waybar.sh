#!/usr/bin/env bash

# Waybar startup script with pywal integration

LOCK_FILE="/tmp/waybar-start.lock"
PID_FILE="/tmp/waybar.pid"
GENERATED_CSS="$HOME/.cache/wal/waybar-style.css"
STYLE_BASE="$HOME/.config/waybar/style-base.css"
COLORS_DEFAULT="$HOME/.config/wal/colors-waybar-default.css"

# Prevent concurrent executions within the same session
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

# NixOS wraps waybar: the binary is .waybar-wrapped but argv[0] is "waybar".
# comm (kernel process name) is ".waybar-wrapped", so kill by comm with -x.
pkill -x waybar 2>/dev/null
pkill -x '.waybar-wrapped' 2>/dev/null
# Wait for them to actually die before spawning a new instance
while pgrep -x waybar >/dev/null 2>&1 || pgrep -x '.waybar-wrapped' >/dev/null 2>&1; do
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

# Start waybar with generated CSS if available.
# Close fd 200 in the subshell so waybar doesn't inherit the lock fd.
if [ -f "$GENERATED_CSS" ]; then
    (exec 200>&-; exec waybar -s "$GENERATED_CSS") &
else
    (exec 200>&-; exec waybar) &
fi
WAYBAR_PID=$!
echo "$WAYBAR_PID" > "$PID_FILE"
disown
