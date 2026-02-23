#!/usr/bin/env bash

# Wallpaper selector using Vicinae
# Provides a graphical interface to select wallpapers

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
CACHE_DIR="$HOME/.cache/wal"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Build list of wallpapers (full paths for quicklook support)
WALLPAPERS=($(find "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Create menu with full paths (enables quicklook preview)
MENU=""
for wall in "${WALLPAPERS[@]}"; do
    MENU+="$wall\n"
done

# Show Vicinae menu with quicklook for image preview
SELECTED=$(echo -e "$MENU" | vicinae dmenu --placeholder "Select Wallpaper:")

# Handle selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Vicinae returns the full path directly
SELECTED_WALL="$SELECTED"

if [ ! -f "$SELECTED_WALL" ]; then
    notify-send "Wallpaper Error" "File not found: $SELECTED_WALL"
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

    if [ -f "$colors_file" ]; then
        if [ -f "$waybar_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/waybar-style.css"
            tail -n +2 "$waybar_base" >> "$CACHE_DIR/waybar-style.css"
        fi
    fi
}

# Generate btop theme with pywal colors
generate_btop_theme() {
    local colors_file="$CACHE_DIR/colors.sh"
    local output="$CACHE_DIR/btop-pywal.theme"

    if [ -f "$colors_file" ]; then
        source "$colors_file"

        cat > "$output" << EOF
# PyWal generated theme for btop
theme[main_bg]="${color0}"
theme[main_fg]="${color7}"
theme[title]="${color7}"
theme[hi_fg]="${color4}"
theme[selected_bg]="${color8}"
theme[selected_fg]="${color7}"
theme[inactive_fg]="${color8}"
theme[graph_text]="${color15}"
theme[meter_bg]="${color8}"
theme[proc_misc]="${color6}"
theme[cpu_box]="${color5}"
theme[mem_box]="${color2}"
theme[net_box]="${color6}"
theme[proc_box]="${color4}"
theme[div_line]="${color8}"
theme[temp_start]="${color6}"
theme[temp_mid]="${color3}"
theme[temp_end]="${color1}"
theme[cpu_start]="${color6}"
theme[cpu_mid]="${color3}"
theme[cpu_end]="${color1}"
theme[free_start]="${color2}"
theme[free_mid]="${color3}"
theme[free_end]="${color1}"
theme[cached_start]="${color3}"
theme[cached_mid]="${color5}"
theme[cached_end]="${color1}"
theme[available_start]="${color6}"
theme[available_mid]="${color4}"
theme[available_end]="${color5}"
theme[used_start]="${color2}"
theme[used_mid]="${color3}"
theme[used_end]="${color1}"
theme[download_start]="${color6}"
theme[download_mid]="${color4}"
theme[download_end]="${color5}"
theme[upload_start]="${color2}"
theme[upload_mid]="${color3}"
theme[upload_end]="${color5}"
theme[process_start]="${color4}"
theme[process_mid]="${color5}"
theme[process_end]="${color6}"
EOF
        mkdir -p "$HOME/.config/btop/themes"
        cp "$output" "$HOME/.config/btop/themes/pywal.theme"
    fi
}

# Generate yazi theme with pywal colors
generate_yazi_theme() {
    local colors_file="$CACHE_DIR/colors.sh"
    local yazi_base="$HOME/.config/yazi/theme-base.toml"
    local output="$HOME/.config/yazi/theme.toml"

    if [ -f "$colors_file" ] && [ -f "$yazi_base" ]; then
        source "$colors_file"

        sed -e "s/PYWAL_COLOR0/${color0}/g" \
            -e "s/PYWAL_COLOR1/${color1}/g" \
            -e "s/PYWAL_COLOR2/${color2}/g" \
            -e "s/PYWAL_COLOR3/${color3}/g" \
            -e "s/PYWAL_COLOR4/${color4}/g" \
            -e "s/PYWAL_COLOR5/${color5}/g" \
            -e "s/PYWAL_COLOR6/${color6}/g" \
            -e "s/PYWAL_COLOR7/${color7}/g" \
            -e "s/PYWAL_COLOR8/${color8}/g" \
            -e "s/PYWAL_COLOR9/${color9}/g" \
            -e "s/PYWAL_COLOR10/${color10}/g" \
            -e "s/PYWAL_COLOR11/${color11}/g" \
            -e "s/PYWAL_COLOR12/${color12}/g" \
            -e "s/PYWAL_COLOR13/${color13}/g" \
            -e "s/PYWAL_COLOR14/${color14}/g" \
            -e "s/PYWAL_COLOR15/${color15}/g" \
            "$yazi_base" > "$output"
    fi
}

generate_css
generate_btop_theme
generate_yazi_theme

# Restart waybar with generated CSS
pkill waybar
sleep 0.3
waybar -s "$CACHE_DIR/waybar-style.css" &

# Save current wallpaper
echo "$SELECTED_WALL" > "$CACHE_FILE"
source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

notify-send "Wallpaper Changed" "$(basename "$SELECTED_WALL")"
