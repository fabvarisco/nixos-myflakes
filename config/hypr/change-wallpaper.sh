#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

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

# Preload the new wallpaper (in case it's not already loaded)
hyprctl hyprpaper preload "$RANDOM_WALL" 2>/dev/null

# Set the wallpaper
hyprctl hyprpaper wallpaper ",$RANDOM_WALL"

# Unload old wallpaper to save memory (optional)
if [ -n "$CURRENT_WALL" ] && [ "$CURRENT_WALL" != "$RANDOM_WALL" ]; then
    hyprctl hyprpaper unload "$CURRENT_WALL" 2>/dev/null
fi

# Save current wallpaper
echo "$RANDOM_WALL" > "$CACHE_FILE"

notify-send "Wallpaper Changed" "$(basename "$RANDOM_WALL")"
