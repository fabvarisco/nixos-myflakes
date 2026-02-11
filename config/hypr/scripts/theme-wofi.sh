#!/usr/bin/env bash
#
# Theme selector using wofi
# Displays a visual menu to select and apply themes
#

THEMES_DIR="$HOME/.config/themes"
CURRENT_THEME_FILE="$THEMES_DIR/current"
THEME_SWITCHER="$HOME/.config/hypr/scripts/theme-switcher.sh"

# Theme definitions with icons and display names
declare -A THEME_ICONS=(
    ["catppuccin-mocha"]="󰄛"
    ["catppuccin-latte"]="󰖨"
    ["nord"]="󰼁"
    ["dracula"]="󰭟"
    ["gruvbox-dark"]="󰔎"
    ["gruvbox-light"]="󰖙"
    ["tokyo-night"]="󰅚"
    ["rose-pine"]="󰧭"
)

declare -A THEME_NAMES=(
    ["catppuccin-mocha"]="Catppuccin Mocha"
    ["catppuccin-latte"]="Catppuccin Latte"
    ["nord"]="Nord"
    ["dracula"]="Dracula"
    ["gruvbox-dark"]="Gruvbox Dark"
    ["gruvbox-light"]="Gruvbox Light"
    ["tokyo-night"]="Tokyo Night"
    ["rose-pine"]="Rose Pine"
)

declare -A THEME_DESCRIPTIONS=(
    ["catppuccin-mocha"]="Dark pastel theme"
    ["catppuccin-latte"]="Light pastel theme"
    ["nord"]="Arctic colors"
    ["dracula"]="Dark purple"
    ["gruvbox-dark"]="Retro dark"
    ["gruvbox-light"]="Retro light"
    ["tokyo-night"]="City lights"
    ["rose-pine"]="Natural pine"
)

# Theme order
THEMES_ORDER=(
    "catppuccin-mocha"
    "catppuccin-latte"
    "nord"
    "dracula"
    "gruvbox-dark"
    "gruvbox-light"
    "tokyo-night"
    "rose-pine"
)

# Get current theme
CURRENT_THEME=""
if [[ -f "$CURRENT_THEME_FILE" ]]; then
    CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
fi

# Build menu entries
MENU=""
for theme in "${THEMES_ORDER[@]}"; do
    icon="${THEME_ICONS[$theme]}"
    name="${THEME_NAMES[$theme]}"
    desc="${THEME_DESCRIPTIONS[$theme]}"

    if [[ "$theme" == "$CURRENT_THEME" ]]; then
        MENU+="● $icon  $name - $desc\n"
    else
        MENU+="  $icon  $name - $desc\n"
    fi
done

# Show wofi menu
SELECTED=$(echo -e "$MENU" | wofi --dmenu \
    --prompt "Select Theme" \
    --width 350 \
    --height 380 \
    --cache-file /dev/null \
    --insensitive)

# Handle empty selection (user cancelled)
if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# Map selection back to theme name
SELECTED_THEME=""
for theme in "${THEMES_ORDER[@]}"; do
    name="${THEME_NAMES[$theme]}"
    if [[ "$SELECTED" == *"$name"* ]]; then
        SELECTED_THEME="$theme"
        break
    fi
done

if [[ -z "$SELECTED_THEME" ]]; then
    notify-send "Theme Error" "Could not determine selected theme" -u critical
    exit 1
fi

# Skip if already current theme
if [[ "$SELECTED_THEME" == "$CURRENT_THEME" ]]; then
    notify-send "Theme" "${THEME_NAMES[$SELECTED_THEME]} is already active" -i preferences-desktop-theme
    exit 0
fi

# Apply the theme
exec "$THEME_SWITCHER" "$SELECTED_THEME"
