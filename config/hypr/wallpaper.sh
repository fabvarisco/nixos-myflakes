#!/usr/bin/env bash

# Wallpaper selector with pywal integration
# Selects wallpaper via wofi, applies with swww, generates colors with pywal

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
CACHE_DIR="$HOME/.cache/wal"

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

# Generate complete CSS files for waybar and wofi (GTK CSS doesn't support @import)
generate_css() {
    local colors_file="$CACHE_DIR/colors-waybar.css"
    local waybar_base="$HOME/.config/waybar/style.css"
    local wofi_base="$HOME/.config/wofi/style.css"
    local wofi_wallpaper_base="$HOME/.config/wofi/style-wallpaper.css"

    mkdir -p "$CACHE_DIR"

    if [ -f "$colors_file" ]; then
        # Generate waybar CSS (colors + styles without @import line)
        if [ -f "$waybar_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/waybar-style.css"
            tail -n +2 "$waybar_base" >> "$CACHE_DIR/waybar-style.css"
        fi

        # Generate wofi CSS (colors + styles without @import line)
        if [ -f "$wofi_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/wofi-style.css"
            tail -n +2 "$wofi_base" >> "$CACHE_DIR/wofi-style.css"
        fi

        # Generate wofi wallpaper selector CSS
        if [ -f "$wofi_wallpaper_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/wofi-style-wallpaper.css"
            tail -n +2 "$wofi_wallpaper_base" >> "$CACHE_DIR/wofi-style-wallpaper.css"
        fi
    fi
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
    if command -v kitty &>/dev/null && [ -f "$CACHE_DIR/colors-kitty.conf" ]; then
        mkdir -p ~/.cache/kitty
        cat "$CACHE_DIR/colors-kitty.conf" > ~/.cache/kitty/current-theme.conf
        # Reload kitty config for all instances
        pkill -USR1 kitty 2>/dev/null
    fi

    # Update pywalfox (Firefox)
    if command -v pywalfox &>/dev/null; then
        pywalfox update 2>/dev/null
    fi

    # Update cava colors if cava config exists
    if [ -f "$HOME/.config/cava/config" ]; then
        source "$CACHE_DIR/colors.sh"
        cava_config="$HOME/.config/cava/config"
        sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '${color2}'/" "$cava_config" 2>/dev/null
        sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '${color3}'/" "$cava_config" 2>/dev/null
        pkill -USR2 cava 2>/dev/null
    fi

    # Generate complete CSS files
    generate_css

    # Restart waybar with generated CSS
    pkill waybar
    sleep 0.3
    waybar -s "$CACHE_DIR/waybar-style.css" &

    # Save current wallpaper path
    echo "$selected_wallpaper" > "$CACHE_FILE"
    source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

    notify-send "Wallpaper Changed" "$(basename "$selected_wallpaper")"
}

# Main function
main() {
    # Determine wofi style file (use cached if available, fallback to config)
    local wofi_style="$CACHE_DIR/wofi-style-wallpaper.css"
    if [ ! -f "$wofi_style" ]; then
        wofi_style="$HOME/.config/wofi/style-wallpaper.css"
    fi

    # Show wofi menu with image previews
    choice=$(menu | wofi \
        -c ~/.config/wofi/wallpaper \
        -s "$wofi_style" \
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
