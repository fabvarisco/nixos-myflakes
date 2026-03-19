#!/usr/bin/env bash

# Auto-apply hyprmon profile based on connected monitors
# Detects monitors by EDID name and applies matching profile

PROFILES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmon/profiles"

# Get connected monitors EDID names
get_connected_monitors() {
    hyprctl monitors -j | jq -r '.[].name' | sort | tr '\n' '+'
}

# Find matching profile based on monitor combination
find_profile() {
    local connected="$1"
    local hostname=$(hostname)

    # Priority order: hostname-specific profiles first
    for profile_file in "$PROFILES_DIR"/*.json; do
        [[ -f "$profile_file" ]] || continue

        profile_name=$(basename "$profile_file" .json)

        # Get monitors from this profile
        profile_monitors=$(jq -r '.monitors[].Name' "$profile_file" 2>/dev/null | sort | tr '\n' '+')

        if [[ "$profile_monitors" == "$connected" ]]; then
            # Prefer hostname-specific profiles
            if [[ "$profile_name" == "$hostname"* ]]; then
                echo "$profile_name"
                return 0
            fi
            # Store as fallback
            fallback="$profile_name"
        fi
    done

    # Return fallback if found
    [[ -n "$fallback" ]] && echo "$fallback" && return 0

    return 1
}

main() {
    connected=$(get_connected_monitors)

    if profile=$(find_profile "$connected"); then
        current=$(hyprmon -active-profile 2>/dev/null || echo "")

        if [[ "$current" != "$profile" ]]; then
            echo "Applying profile: $profile"
            hyprmon -profile "$profile"
        else
            echo "Profile already active: $profile"
        fi
    else
        echo "No matching profile for monitors: $connected"
        echo "Run 'hyprmon' to create one"
    fi
}

main "$@"
