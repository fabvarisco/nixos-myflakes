#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/walls"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory $WALLPAPER_DIR not found!"
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \)))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

RANDOM_WALL="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"

hyprctl hyprpaper wallpaper ",$RANDOM_WALL,cover"

notify-send "Wallpaper Changed" "$(basename "$RANDOM_WALL")"
