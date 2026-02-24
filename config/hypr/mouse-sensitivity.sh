#!/usr/bin/env bash

# Get current sensitivity from hyprctl
current=$(hyprctl getoption input:sensitivity -j | jq -r '.float')

# Convert from -1.0 to 1.0 range to 0-200 for zenity (with 100 being 0)
current_scaled=$(echo "scale=0; ($current + 1) * 100" | bc)

# Show zenity slider
new_value=$(zenity --scale \
    --title="Mouse Sensitivity" \
    --text="Adjust mouse sensitivity:" \
    --min-value=0 \
    --max-value=200 \
    --value="$current_scaled" \
    --step=5 \
    2>/dev/null)

# Check if user cancelled
if [ -z "$new_value" ]; then
    exit 0
fi

# Convert back to -1.0 to 1.0 range
sensitivity=$(echo "scale=2; ($new_value / 100) - 1" | bc)

# Apply sensitivity
hyprctl keyword input:sensitivity "$sensitivity"

# Show notification
notify-send "Mouse Sensitivity" "Set to $sensitivity" -t 2000
