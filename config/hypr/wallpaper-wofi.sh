#!/usr/bin/env bash

# Wallpaper selector using wofi
# Provides a graphical interface to select wallpapers

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
CACHE_DIR="$HOME/.cache/wal"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Build list of wallpapers with friendly names
WALLPAPERS=($(find "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

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
MENU+="🔄 Reload swww"

# Determine wofi style file (use cached if available, fallback to config)
WOFI_STYLE="$CACHE_DIR/wofi-style.css"
if [ ! -f "$WOFI_STYLE" ]; then
    WOFI_STYLE="$HOME/.config/wofi/style.css"
fi

# Show wofi menu
SELECTED=$(echo -e "$MENU" | wofi --dmenu \
    --prompt "Select Wallpaper" \
    --width 400 \
    --height 350 \
    --cache-file /dev/null \
    --insensitive \
    -s "$WOFI_STYLE")

# Handle selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Check for special options
if [[ "$SELECTED" == *"Random Wallpaper"* ]]; then
    ~/.config/hypr/change-wallpaper.sh
    exit 0
fi

if [[ "$SELECTED" == *"Reload swww"* ]]; then
    killall swww-daemon 2>/dev/null
    swww-daemon &
    sleep 1
    if [ -f "$CACHE_FILE" ]; then
        LAST_WALL=$(cat "$CACHE_FILE")
        swww img "$LAST_WALL" --transition-type fade --transition-duration 1
    fi
    notify-send "swww" "Reloaded successfully"
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

# Set the wallpaper with animation
swww img "$SELECTED_WALL" \
    --transition-type grow \
    --transition-duration 1.5 \
    --transition-fps 60 \
    --transition-pos center

# Generate colors with pywal
wal -i "$SELECTED_WALL" -n --cols16

# Update kitty theme
if command -v kitty &>/dev/null && [ -f "$CACHE_DIR/colors-kitty.conf" ]; then
    mkdir -p ~/.cache/kitty
    cat "$CACHE_DIR/colors-kitty.conf" > ~/.cache/kitty/current-theme.conf
    pkill -USR1 kitty 2>/dev/null
fi

# Reload swaync styles
swaync-client --reload-css 2>/dev/null

# Update pywalfox
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null
fi

# Generate complete CSS files (GTK CSS doesn't support @import)
generate_css() {
    local colors_file="$CACHE_DIR/colors-waybar.css"
    local waybar_base="$HOME/.config/waybar/style.css"
    local wofi_base="$HOME/.config/wofi/style.css"

    if [ -f "$colors_file" ]; then
        if [ -f "$waybar_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/waybar-style.css"
            tail -n +2 "$waybar_base" >> "$CACHE_DIR/waybar-style.css"
        fi
        if [ -f "$wofi_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/wofi-style.css"
            tail -n +2 "$wofi_base" >> "$CACHE_DIR/wofi-style.css"
        fi
    fi
}
generate_css

# Restart waybar with generated CSS
pkill waybar
sleep 0.3
waybar -s "$CACHE_DIR/waybar-style.css" &

# Save current wallpaper
echo "$SELECTED_WALL" > "$CACHE_FILE"
source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

notify-send "Wallpaper Changed" "$WALL_NAME"
