#!/usr/bin/env bash

# Random wallpaper selector with pywal integration

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
CACHE_DIR="$HOME/.cache/wal"

mkdir -p "$(dirname "$CACHE_FILE")"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

WALLPAPERS=($(find "$WALLPAPER_DIR" \( -type f -o -type l \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

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
swww img "$RANDOM_WALL" \
    --transition-type any \
    --transition-duration 0.5 \
    --transition-fps 60

# Generate colors with pywal
wal -i "$RANDOM_WALL" -n

# Reload swaync styles
swaync-client --reload-css 2>/dev/null

# Update kitty theme
if command -v kitty &>/dev/null && [ -f "$CACHE_DIR/colors-kitty.conf" ]; then
    mkdir -p ~/.cache/kitty
    cat "$CACHE_DIR/colors-kitty.conf" > ~/.cache/kitty/current-theme.conf
    pkill -USR1 kitty 2>/dev/null
fi

# Update pywalfox
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null
fi

# Update cava colors
if [ -f "$HOME/.config/cava/config" ]; then
    source "$CACHE_DIR/colors.sh"
    cava_config="$HOME/.config/cava/config"
    sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '${color2}'/" "$cava_config" 2>/dev/null
    sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '${color3}'/" "$cava_config" 2>/dev/null
    pkill -USR2 cava 2>/dev/null
fi

# Generate starship config with pywal colors
generate_starship() {
    local starship_base="$HOME/.config/starship.toml.base"
    local colors_file="$CACHE_DIR/colors.sh"
    local output="$CACHE_DIR/starship.toml"

    if [ -f "$starship_base" ] && [ -f "$colors_file" ]; then
        source "$colors_file"

        # Create derived colors (darker variants for backgrounds)
        # Extract RGB from color0 (background) and darken it
        local bg_r=$((16#${color0:1:2}))
        local bg_g=$((16#${color0:3:2}))
        local bg_b=$((16#${color0:5:2}))

        # Create darker background variants
        local bg1=$(printf "#%02x%02x%02x" $((bg_r*80/100)) $((bg_g*80/100)) $((bg_b*80/100)))
        local bg2=$(printf "#%02x%02x%02x" $((bg_r*60/100)) $((bg_g*60/100)) $((bg_b*60/100)))
        local bg3=$(printf "#%02x%02x%02x" $((bg_r*40/100)) $((bg_g*40/100)) $((bg_b*40/100)))

        # Replace placeholders with actual colors
        sed -e "s/COLOR_PRIMARY/${color4}/g" \
            -e "s/COLOR_SECONDARY/${color5}/g" \
            -e "s/COLOR_BG1/${bg1}/g" \
            -e "s/COLOR_BG2/${bg2}/g" \
            -e "s/COLOR_BG3/${bg3}/g" \
            -e "s/COLOR_TEXT/${color7}/g" \
            "$starship_base" > "$output"
    fi
}

# Generate complete CSS files for waybar and wofi (GTK CSS doesn't support @import)
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

generate_css
generate_starship

# Restart waybar with generated CSS
pkill waybar
sleep 0.3
waybar -s "$CACHE_DIR/waybar-style.css" &

# Save current wallpaper
echo "$RANDOM_WALL" > "$CACHE_FILE"
source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

notify-send "Wallpaper Changed" "$(basename "$RANDOM_WALL")"
