#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/walls"
INTERVAL=300 

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory $WALLPAPER_DIR not found!"
    exit 1
fi

while true; do
    WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \)))
    
    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        sleep $INTERVAL
        continue
    fi
    
    RANDOM_WALL="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"
    
    hyprctl hyprpaper wallpaper ",$RANDOM_WALL,cover"
    
    sleep $INTERVAL
done
