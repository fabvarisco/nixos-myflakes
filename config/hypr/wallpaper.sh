#!/usr/bin/env bash

# Wallpaper selector with pywal integration
# Selects wallpaper via Vicinae, applies with swww, generates colors with pywal

WALLPAPER_DIR="$HOME/.config/walls"
CACHE_FILE="$HOME/.cache/hypr/current_wallpaper"
CACHE_DIR="$HOME/.cache/wal"

mkdir -p "$(dirname "$CACHE_FILE")"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Function to generate menu with image previews
# Vicinae supports Quick Look for absolute file paths
menu() {
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \)
}

# Generate complete CSS files for waybar (GTK CSS doesn't support @import)
generate_css() {
    local colors_file="$CACHE_DIR/colors-waybar.css"
    local waybar_base="$HOME/.config/waybar/style.css"

    mkdir -p "$CACHE_DIR"

    if [ -f "$colors_file" ]; then
        # Generate waybar CSS (colors + styles without @import line)
        if [ -f "$waybar_base" ]; then
            cat "$colors_file" > "$CACHE_DIR/waybar-style.css"
            tail -n +2 "$waybar_base" >> "$CACHE_DIR/waybar-style.css"
        fi
    fi
}

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

# Function to apply wallpaper and update all themes
apply_wallpaper() {
    local selected_wallpaper="$1"

    # Apply wallpaper with swww
    swww img "$selected_wallpaper" \
        --transition-type any \
        --transition-fps 60 \
        --transition-duration 0.5

    # Generate colors with pywal
    wal -i "$selected_wallpaper" -n --cols16

    # Reload swaync styles
    swaync-client --reload-css 2>/dev/null

    # Update kitty theme if kitty is running
    if command -v kitty &>/dev/null && [ -f "$CACHE_DIR/colors-kitty.conf" ]; then
        mkdir -p ~/.cache/kitty
        cat "$CACHE_DIR/colors-kitty.conf" > ~/.cache/kitty/current-theme.conf
        # Reload kitty config for all instances
        pkill -USR1 kitty 2>/dev/null
    fi

    # Update pywalfox (Firefox/Zen Browser)
    if command -v pywalfox &>/dev/null; then
        pywalfox update 2>/dev/null
    fi

    # Setup Zen Browser PywalZen theme
    setup_zen_browser

    # Update cava colors if cava config exists
    if [ -f "$HOME/.config/cava/config" ]; then
        source "$CACHE_DIR/colors.sh"
        cava_config="$HOME/.config/cava/config"
        sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '${color2}'/" "$cava_config" 2>/dev/null
        sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '${color3}'/" "$cava_config" 2>/dev/null
        pkill -USR2 cava 2>/dev/null
    fi

    # Generate btop theme
    generate_btop_theme

    # Generate yazi theme
    generate_yazi_theme

    # Generate complete CSS files
    generate_css

    # Restart waybar with generated CSS
    pkill waybar
    sleep 0.3
    waybar -s "$CACHE_DIR/waybar-style.css" &

    # Save current wallpaper path
    echo "$selected_wallpaper" > "$CACHE_FILE"
    source "$CACHE_DIR/colors.sh" && cp -r "$wallpaper" ~/wallpapers/pywallpaper.jpg 2>/dev/null

    notify-send "Wallpaper Changed" "$(basename "$selected_wallpaper")"
}

# Main function
main() {
    # Show Vicinae menu (supports Quick Look for file previews)
    choice=$(menu | vicinae dmenu --placeholder "Select Wallpaper:")

    # Check if user made a selection
    if [ -z "$choice" ]; then
        exit 0
    fi

    # Selected wallpaper path (Vicinae returns the path directly)
    selected_wallpaper="$choice"

    # Check if file exists
    if [ ! -f "$selected_wallpaper" ]; then
        notify-send "Wallpaper Error" "File not found: $selected_wallpaper"
        exit 1
    fi

    # Apply wallpaper
    apply_wallpaper "$selected_wallpaper"
}

main
