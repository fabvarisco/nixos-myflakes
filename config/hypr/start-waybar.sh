#!/usr/bin/env bash

# Waybar startup script with pywal integration
# Generates CSS from pywal colors before starting waybar

CACHE_DIR="$HOME/.cache/wal"

# Wait for pywal colors to be available (max 5 seconds)
wait_for_colors() {
    local max_wait=50  # 50 * 0.1s = 5 seconds
    local count=0
    while [ ! -f "$CACHE_DIR/colors-waybar.css" ] && [ $count -lt $max_wait ]; do
        sleep 0.1
        count=$((count + 1))
    done
}

# Generate complete CSS files (GTK CSS doesn't support @import)
generate_css() {
    local colors_file="$CACHE_DIR/colors-waybar.css"
    local waybar_base="$HOME/.config/waybar/style.css"
    local wofi_base="$HOME/.config/wofi/style.css"
    local wofi_wallpaper_base="$HOME/.config/wofi/style-wallpaper.css"

    mkdir -p "$CACHE_DIR"

    if [ -f "$colors_file" ]; then
        # Generate waybar CSS (colors + styles without @import line)
        if [ -f "$waybar_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/waybar-style.css"
            tail -n +2 "$waybar_base" >> "$CACHE_DIR/waybar-style.css"
        fi

        # Generate wofi CSS (colors + styles without @import line)
        if [ -f "$wofi_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/wofi-style.css"
            tail -n +2 "$wofi_base" >> "$CACHE_DIR/wofi-style.css"
        fi

        # Generate wofi wallpaper selector CSS
        if [ -f "$wofi_wallpaper_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/wofi-style-wallpaper.css"
            tail -n +2 "$wofi_wallpaper_base" >> "$CACHE_DIR/wofi-style-wallpaper.css"
        fi
    fi
}

# Wait for pywal colors and generate CSS files
wait_for_colors
generate_css

# Start waybar with generated CSS if it exists, otherwise use default
if [ -f "$CACHE_DIR/waybar-style.css" ]; then
    exec waybar -s "$CACHE_DIR/waybar-style.css"
else
    exec waybar
fi
