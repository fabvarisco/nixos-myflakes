#!/usr/bin/env bash

# Automatic wallpaper slideshow
# Changes wallpaper every INTERVAL seconds

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
INTERVAL=43200  # 12 hours (12 * 60 * 60)

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory $WALLPAPER_DIR not found!"
    exit 1
fi

while true; do
    WALLPAPERS=($(find -L "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        sleep $INTERVAL
        continue
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

    # Set wallpaper with animation
    awww img "$RANDOM_WALL" \
        --transition-type fade \
        --transition-duration 2 \
        --transition-fps 60

    # Save current wallpaper
    echo "$RANDOM_WALL" > "$CACHE_FILE"

    # Apply pywal colors
    ~/.config/hypr/apply-pywal.sh "$RANDOM_WALL"

    sleep $INTERVAL
done
