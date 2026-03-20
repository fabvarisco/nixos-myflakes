#!/usr/bin/env bash

# Wallpaper selector with Vicinae - no pywal

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Show Vicinae menu with quicklook
choice=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | vicinae dmenu --placeholder "Select Wallpaper:" --quicklook)

if [ -z "$choice" ]; then
    exit 0
fi

if [ ! -f "$choice" ]; then
    notify-send "Wallpaper Error" "File not found: $choice"
    exit 1
fi

# Apply wallpaper with swww
swww img "$choice" \
    --transition-type any \
    --transition-fps 60 \
    --transition-duration 0.5

# Save current wallpaper
echo "$choice" > "$CACHE_FILE"

notify-send "Wallpaper Changed" "$(basename "$choice")"
