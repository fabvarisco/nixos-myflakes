#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/niri/current_wallpaper"
INTERVAL=43200  # 12 hours

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory $WALLPAPER_DIR not found!"
    exit 1
fi

swww query || swww-daemon &
sleep 1

while true; do
    mapfile -t WALLPAPERS < <(find -L "$WALLPAPER_DIR" \( -type f -o -type l \) \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        sleep $INTERVAL
        continue
    fi

    CURRENT_WALL=""
    [ -f "$CACHE_FILE" ] && CURRENT_WALL=$(cat "$CACHE_FILE")

    RANDOM_WALL="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"
    ATTEMPTS=0
    while [ "$RANDOM_WALL" = "$CURRENT_WALL" ] && [ $ATTEMPTS -lt 10 ] && [ ${#WALLPAPERS[@]} -gt 1 ]; do
        RANDOM_WALL="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"
        ((ATTEMPTS++))
    done

    swww img "$RANDOM_WALL" \
        --transition-type fade \
        --transition-duration 2 \
        --transition-fps 60

    echo "$RANDOM_WALL" > "$CACHE_FILE"

    wal -i "$RANDOM_WALL" -n -q 2>/dev/null || true

    sleep $INTERVAL
done
