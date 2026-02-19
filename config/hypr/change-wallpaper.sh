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

# Update pywalfox (Firefox/Zen Browser)
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null
fi

# Setup Zen Browser PywalZen theme
setup_zen_browser() {
    local zen_dir="$HOME/.zen"
    local zen_config="$HOME/.config/zen"

    if [ -d "$zen_dir" ] && [ -d "$zen_config" ]; then
        for profile in "$zen_dir"/*; do
            if [ -d "$profile" ] && [[ "$(basename "$profile")" != "Profile Groups" ]]; then
                mkdir -p "$profile/chrome"
                if [ -f "$zen_config/userChrome.css" ]; then
                    rm -f "$profile/chrome/userChrome.css" 2>/dev/null
                    cp "$zen_config/userChrome.css" "$profile/chrome/userChrome.css"
                fi
            fi
        done
    fi
}
setup_zen_browser


# Update cava colors
if [ -f "$HOME/.config/cava/config" ]; then
    source "$CACHE_DIR/colors.sh"
    cava_config="$HOME/.config/cava/config"
    sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '${color2}'/" "$cava_config" 2>/dev/null
    sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '${color3}'/" "$cava_config" 2>/dev/null
    pkill -USR2 cava 2>/dev/null
fi

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
        # Copy to btop themes directory
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

        # Replace color placeholders with actual pywal colors
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

# Generate starship config with pywal colors
generate_starship() {
    local starship_base="$HOME/.config/starship.toml"
    local colors_file="$CACHE_DIR/colors.sh"
    local output="$CACHE_DIR/starship.toml"

    if [ -f "$starship_base" ] && [ -f "$colors_file" ]; then
        source "$colors_file"

        # Create derived colors (darker variants for backgrounds)
        # Extract RGB from color0 (background) and darken it
        local bg_r=$((16#${color0:1:2}))
        local bg_g=$((16#${color0:3:2}))
        local bg_b=$((16#${color0:5:2}))

        # Create darker background variants with good contrast
        local bg1=$(printf "#%02x%02x%02x" $((bg_r*120/100 > 255 ? 255 : bg_r*120/100)) $((bg_g*120/100 > 255 ? 255 : bg_g*120/100)) $((bg_b*120/100 > 255 ? 255 : bg_b*120/100)))
        local bg2=$(printf "#%02x%02x%02x" $((bg_r*90/100)) $((bg_g*90/100)) $((bg_b*90/100)))
        local bg3=$(printf "#%02x%02x%02x" $((bg_r*70/100)) $((bg_g*70/100)) $((bg_b*70/100)))

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
generate_btop_theme
generate_yazi_theme

# Restart waybar with generated CSS
pkill waybar
sleep 0.3
waybar -s "$CACHE_DIR/waybar-style.css" &

# Save current wallpaper
echo "$RANDOM_WALL" > "$CACHE_FILE"
source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

notify-send "Wallpaper Changed" "$(basename "$RANDOM_WALL")"
