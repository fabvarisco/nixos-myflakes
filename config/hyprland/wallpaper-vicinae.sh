#!/usr/bin/env bash

# Wallpaper selector using Vicinae with pywal integration

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Build list of wallpapers
WALLPAPERS=($(find -L "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Create menu with full paths (enables quicklook preview)
MENU=""
for wall in "${WALLPAPERS[@]}"; do
    MENU+="$wall\n"
done

# Show Vicinae menu with quicklook for image preview
SELECTED=$(echo -e "$MENU" | vicinae dmenu --placeholder "Select Wallpaper:")

# Handle selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

SELECTED_WALL="$SELECTED"

if [ ! -f "$SELECTED_WALL" ]; then
    notify-send "Wallpaper Error" "File not found: $SELECTED_WALL"
    exit 1
fi

# Set the wallpaper with animation
swww img "$SELECTED_WALL" \
    --transition-type grow \
    --transition-duration 1.5 \
    --transition-fps 60 \
    --transition-pos center

# Save current wallpaper
echo "$SELECTED_WALL" > "$CACHE_FILE"

# Apply pywal colors
~/.config/hypr/apply-pywal.sh "$SELECTED_WALL"

notify-send "Wallpaper Changed" "$(basename "$SELECTED_WALL")"
