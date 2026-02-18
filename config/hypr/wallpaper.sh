#!/usr/bin/env bash

# Wallpaper selector with pywal integration
# Selects wallpaper via wofi, applies with swww, generates colors with pywal

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Function to generate menu with image previews
menu() {
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | while read -r file; do
        echo "img:${file}"
    done
}

# Function to apply wallpaper and update all themes
apply_wallpaper() {
    local selected_wallpaper="$1"

    # Apply wallpaper with swww
    swww img "$selected_wallpaper" \
        --transition-type any \
        --transition-fps 60 \
        --transition-duration 0.5

    # Generate colors with pywal
    wal -i "$selected_wallpaper" -n --cols16

    # Reload swaync styles
    swaync-client --reload-css 2>/dev/null

    # Update kitty theme if kitty is running
    if command -v kitty &>/dev/null && [ -f ~/.cache/wal/colors-kitty.conf ]; then
        cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf
        # Reload kitty config for all instances
        pkill -USR1 kitty 2>/dev/null
    fi

    # Update pywalfox (Firefox)
    if command -v pywalfox &>/dev/null; then
        pywalfox update 2>/dev/null
    fi

    # Update cava colors if cava config exists
    if [ -f "$HOME/.config/cava/config" ]; then
        source ~/.cache/wal/colors.sh
        cava_config="$HOME/.config/cava/config"
        sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '${color2}'/" "$cava_config" 2>/dev/null
        sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '${color3}'/" "$cava_config" 2>/dev/null
        pkill -USR2 cava 2>/dev/null
    fi

    # Reload waybar
    pkill -SIGUSR2 waybar 2>/dev/null

    # Save current wallpaper path
    echo "$selected_wallpaper" > "$CACHE_FILE"
    source ~/.cache/wal/colors.sh && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

    notify-send "Wallpaper Changed" "$(basename "$selected_wallpaper")"
}

# Main function
main() {
    # Show wofi menu with image previews
    choice=$(menu | wofi \
        -c ~/.config/wofi/wallpaper \
        -s ~/.config/wofi/style-wallpaper.css \
        --show dmenu \
        --prompt "Select Wallpaper:" \
        -n)

    # Check if user made a selection
    if [ -z "$choice" ]; then
        exit 0
    fi

    # Extract wallpaper path (remove img: prefix)
    selected_wallpaper=$(echo "$choice" | sed 's/^img://')

    # Check if file exists
    if [ ! -f "$selected_wallpaper" ]; then
        notify-send "Wallpaper Error" "File not found: $selected_wallpaper"
        exit 1
    fi

    # Apply wallpaper
    apply_wallpaper "$selected_wallpaper"
}

main
