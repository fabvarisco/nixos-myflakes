#!/usr/bin/env bash

# Wallpaper selector using wofi
# Provides a graphical interface to select wallpapers

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Build list of wallpapers with friendly names
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper for marking
CURRENT_WALL=""
if [ -f "$CACHE_FILE" ]; then
    CURRENT_WALL=$(cat "$CACHE_FILE")
fi

# Create menu entries
MENU=""
for wall in "${WALLPAPERS[@]}"; do
    name=$(basename "$wall")
    if [ "$wall" = "$CURRENT_WALL" ]; then
        MENU+="● $name\n"
    else
        MENU+="  $name\n"
    fi
done

# Add special options
MENU+="─────────────\n"
MENU+="🔀 Random Wallpaper\n"
MENU+="🔄 Reload Hyprpaper"

# Show wofi menu
SELECTED=$(echo -e "$MENU" | wofi --dmenu \
    --prompt "Select Wallpaper" \
    --width 400 \
    --height 350 \
    --cache-file /dev/null \
    --insensitive)

# Handle selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Check for special options
if [[ "$SELECTED" == *"Random Wallpaper"* ]]; then
    ~/.config/hypr/change-wallpaper.sh
    exit 0
fi

if [[ "$SELECTED" == *"Reload Hyprpaper"* ]]; then
    killall hyprpaper 2>/dev/null
    hyprpaper &
    sleep 1
    if [ -f "$CACHE_FILE" ]; then
        LAST_WALL=$(cat "$CACHE_FILE")
        hyprctl hyprpaper wallpaper ",$LAST_WALL"
    fi
    notify-send "Hyprpaper" "Reloaded successfully"
    exit 0
fi

# Skip separator line
if [[ "$SELECTED" == "─────────────" ]]; then
    exit 0
fi

# Extract wallpaper name (remove the marker prefix)
WALL_NAME=$(echo "$SELECTED" | sed 's/^[●  ] //')

# Find the full path
SELECTED_WALL=""
for wall in "${WALLPAPERS[@]}"; do
    if [ "$(basename "$wall")" = "$WALL_NAME" ]; then
        SELECTED_WALL="$wall"
        break
    fi
done

if [ -z "$SELECTED_WALL" ]; then
    notify-send "Wallpaper Error" "Could not find wallpaper: $WALL_NAME"
    exit 1
fi

# Set the wallpaper
hyprctl hyprpaper preload "$SELECTED_WALL" 2>/dev/null
hyprctl hyprpaper wallpaper ",$SELECTED_WALL"

# Unload old wallpaper
if [ -n "$CURRENT_WALL" ] && [ "$CURRENT_WALL" != "$SELECTED_WALL" ]; then
    hyprctl hyprpaper unload "$CURRENT_WALL" 2>/dev/null
fi

# Save current wallpaper
echo "$SELECTED_WALL" > "$CACHE_FILE"

notify-send "Wallpaper Changed" "$WALL_NAME"
