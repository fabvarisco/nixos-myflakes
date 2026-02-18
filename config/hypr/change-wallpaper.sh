#!/usr/bin/env bash

# Random wallpaper selector with pywal integration

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
CACHE_DIR="$HOME/.cache/wal"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

WALLPAPERS=($(find "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper
CURRENT_WALL=""
if [ -f "$CACHE_FILE" ]; then
    CURRENT_WALL=$(cat "$CACHE_FILE")
fi

# Select random wallpaper (different from current)
RANDOM_WALL="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"
ATTEMPTS=0
while [ "$RANDOM_WALL" = "$CURRENT_WALL" ] && [ $ATTEMPTS -lt 10 ] && [ ${#WALLPAPERS[@]} -gt 1 ]; do
    RANDOM_WALL="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"
    ((ATTEMPTS++))
done

# Set the wallpaper with animation
swww img "$RANDOM_WALL" \
    --transition-type any \
    --transition-duration 0.5 \
    --transition-fps 60

# Generate colors with pywal
wal -i "$RANDOM_WALL" -n --cols16

# Reload swaync styles
swaync-client --reload-css 2>/dev/null

# Update kitty theme
if command -v kitty &>/dev/null && [ -f "$CACHE_DIR/colors-kitty.conf" ]; then
    mkdir -p ~/.cache/kitty
    cat "$CACHE_DIR/colors-kitty.conf" > ~/.cache/kitty/current-theme.conf
    pkill -USR1 kitty 2>/dev/null
fi

# Update pywalfox
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null
fi

# Update cava colors
if [ -f "$HOME/.config/cava/config" ]; then
    source "$CACHE_DIR/colors.sh"
    cava_config="$HOME/.config/cava/config"
    sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '${color2}'/" "$cava_config" 2>/dev/null
    sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '${color3}'/" "$cava_config" 2>/dev/null
    pkill -USR2 cava 2>/dev/null
fi

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

generate_css

# Restart waybar with generated CSS
pkill waybar
sleep 0.3
waybar -s "$CACHE_DIR/waybar-style.css" &

# Save current wallpaper
echo "$RANDOM_WALL" > "$CACHE_FILE"
source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

notify-send "Wallpaper Changed" "$(basename "$RANDOM_WALL")"
