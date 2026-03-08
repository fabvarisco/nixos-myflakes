#!/usr/bin/env bash

# Audio visualizer for waybar using cava
# Shows real-time audio visualization

CONFIG_FILE="$HOME/.config/waybar/cava-config"

# Bar characters (from lowest to highest)
BARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# Read one line from cava and convert to unicode bars
cava -p "$CONFIG_FILE" 2>/dev/null | while IFS= read -r line; do
    output=""
    for value in $line; do
        # Clamp value between 0-7
        [[ $value -gt 7 ]] && value=7
        [[ $value -lt 0 ]] && value=0
        output+="${BARS[$value]}"
    done
    echo "$output"
done
