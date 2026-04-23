#!/usr/bin/env bash

# Random wallpaper selector with pywal integration

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

WALLPAPERS=($(find -L "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

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
awww img "$RANDOM_WALL" \
    --transition-type any \
    --transition-duration 0.5 \
    --transition-fps 60

# Save current wallpaper
echo "$RANDOM_WALL" > "$CACHE_FILE"

# Apply pywal colors
~/.config/hypr/apply-pywal.sh "$RANDOM_WALL"

notify-send "Wallpaper Changed" "$(basename "$RANDOM_WALL")"
