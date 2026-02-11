#!/usr/bin/env bash
#
# Theme Switcher for NixOS Hyprland Setup
# Usage: theme-switcher.sh [theme-name] [--no-restart]
#        theme-switcher.sh list
#        theme-switcher.sh current
#

set -euo pipefail

# Configuration
CONFIG_DIR="$HOME/.config"
THEMES_DIR="$CONFIG_DIR/themes"
DEFINITIONS_DIR="$THEMES_DIR/definitions"
TEMPLATES_DIR="$THEMES_DIR/templates"
CURRENT_THEME_FILE="$THEMES_DIR/current"

# Available themes
AVAILABLE_THEMES=(
    "catppuccin-mocha"
    "catppuccin-latte"
    "nord"
    "dracula"
    "gruvbox-dark"
    "gruvbox-light"
    "tokyo-night"
    "rose-pine"
)

#=============================================================================
# UTILITY FUNCTIONS
#=============================================================================

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[OK]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

notify() {
    if command -v notify-send &> /dev/null; then
        notify-send "Theme Switcher" "$1" -i preferences-desktop-theme -t 3000
    fi
}

get_current_theme() {
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "catppuccin-mocha"
    fi
}

list_themes() {
    echo "Available themes:"
    local current
    current=$(get_current_theme)
    for theme in "${AVAILABLE_THEMES[@]}"; do
        if [[ "$theme" == "$current" ]]; then
            echo -e "  \033[0;32m*\033[0m $theme (current)"
        else
            echo "    $theme"
        fi
    done
}

validate_theme() {
    local theme="$1"
    for t in "${AVAILABLE_THEMES[@]}"; do
        [[ "$t" == "$theme" ]] && return 0
    done
    return 1
}

#=============================================================================
# TEMPLATE PROCESSING
#=============================================================================

process_template() {
    local template="$1"
    local output="$2"

    if [[ ! -f "$template" ]]; then
        log_error "Template not found: $template"
        return 1
    fi

    local content
    content=$(cat "$template")

    # Replace all {{VARIABLE}} patterns with their values
    local vars=(
        "THEME_NAME" "THEME_TYPE" "VSCODE_THEME" "BTOP_THEME"
        "BASE" "MANTLE" "CRUST"
        "SURFACE0" "SURFACE1" "SURFACE2"
        "OVERLAY0" "OVERLAY1" "OVERLAY2"
        "TEXT" "SUBTEXT0" "SUBTEXT1"
        "ROSEWATER" "FLAMINGO" "PINK" "MAUVE" "RED" "MAROON"
        "PEACH" "YELLOW" "GREEN" "TEAL" "SKY" "SAPPHIRE" "BLUE" "LAVENDER"
        "PRIMARY" "SECONDARY" "ACCENT" "SUCCESS" "WARNING" "ERROR" "INFO"
        "COLOR0" "COLOR1" "COLOR2" "COLOR3" "COLOR4" "COLOR5" "COLOR6" "COLOR7"
        "COLOR8" "COLOR9" "COLOR10" "COLOR11" "COLOR12" "COLOR13" "COLOR14" "COLOR15"
        "CURSOR" "CURSOR_TEXT" "SELECTION_BG" "SELECTION_FG" "URL_COLOR"
        "ACTIVE_BORDER" "INACTIVE_BORDER"
        "BASE_RGB" "TEXT_RGB" "SURFACE0_RGB"
        "BASE_HEX" "MANTLE_HEX" "CRUST_HEX"
        "SURFACE0_HEX" "SURFACE1_HEX" "SURFACE2_HEX"
        "OVERLAY0_HEX" "OVERLAY1_HEX" "TEXT_HEX"
        "SUBTEXT0_HEX" "SUBTEXT1_HEX"
        "ROSEWATER_HEX" "FLAMINGO_HEX" "PINK_HEX" "MAUVE_HEX"
        "RED_HEX" "MAROON_HEX" "PEACH_HEX" "YELLOW_HEX"
        "GREEN_HEX" "TEAL_HEX" "SKY_HEX" "SAPPHIRE_HEX"
        "BLUE_HEX" "LAVENDER_HEX"
    )

    for var in "${vars[@]}"; do
        local value="${!var:-}"
        if [[ -n "$value" ]]; then
            content="${content//\{\{$var\}\}/$value}"
        fi
    done

    # Create directory if needed
    mkdir -p "$(dirname "$output")"
    echo "$content" > "$output"
}

#=============================================================================
# APPLICATION UPDATE FUNCTIONS
#=============================================================================

update_kitty() {
    log_info "Updating Kitty terminal colors..."
    local template="$TEMPLATES_DIR/kitty-theme.conf.tmpl"
    local output="$CONFIG_DIR/kitty/theme.conf"
    process_template "$template" "$output"
    log_success "Kitty theme updated"
}

reload_kitty() {
    if pgrep -x kitty > /dev/null; then
        pkill -USR1 kitty 2>/dev/null || true
        log_success "Kitty reloaded"
    fi
}

update_waybar() {
    log_info "Updating Waybar styles..."
    local template="$TEMPLATES_DIR/waybar-style.css.tmpl"
    local output="$CONFIG_DIR/waybar/style.css"
    process_template "$template" "$output"
    log_success "Waybar theme updated"
}

reload_waybar() {
    if pgrep -x waybar > /dev/null; then
        pkill -SIGUSR2 waybar 2>/dev/null || true
        log_success "Waybar style reloaded"
    fi
}

update_wofi() {
    log_info "Updating Wofi styles..."
    local template="$TEMPLATES_DIR/wofi-style.css.tmpl"
    local output="$CONFIG_DIR/wofi/style.css"
    process_template "$template" "$output"
    log_success "Wofi theme updated"
}

update_swaync() {
    log_info "Updating SwayNC styles..."
    local template="$TEMPLATES_DIR/swaync-style.css.tmpl"
    local output="$CONFIG_DIR/swaync/style.css"
    process_template "$template" "$output"
    log_success "SwayNC theme updated"
}

reload_swaync() {
    if pgrep -x swaync > /dev/null; then
        swaync-client --reload-css 2>/dev/null || true
        log_success "SwayNC reloaded"
    fi
}

update_hyprland() {
    log_info "Updating Hyprland colors..."
    local template="$TEMPLATES_DIR/hyprland-colors.conf.tmpl"
    local output="$CONFIG_DIR/hypr/colors.conf"
    process_template "$template" "$output"
    log_success "Hyprland colors updated"
}

reload_hyprland() {
    if command -v hyprctl &> /dev/null; then
        hyprctl reload 2>/dev/null || true
        log_success "Hyprland config reloaded"
    fi
}

update_hyprlock() {
    log_info "Updating Hyprlock colors..."
    local template="$TEMPLATES_DIR/hyprlock.conf.tmpl"
    local output="$CONFIG_DIR/hypr/hyprlock.conf"
    process_template "$template" "$output"
    log_success "Hyprlock theme updated"
}

update_btop() {
    log_info "Updating Btop theme..."
    local btop_conf="$CONFIG_DIR/btop/btop.conf"

    if [[ -f "$btop_conf" ]]; then
        sed -i "s/^color_theme = .*/color_theme = \"$BTOP_THEME\"/" "$btop_conf"
        log_success "Btop theme set to: $BTOP_THEME"
    fi
}

reload_btop() {
    if pgrep -x btop > /dev/null; then
        pkill -USR2 btop 2>/dev/null || true
        log_success "Btop refreshed"
    fi
}

update_vscode() {
    log_info "Updating VSCode theme..."
    local vscode_settings="$CONFIG_DIR/Code/User/settings.json"

    if [[ ! -f "$vscode_settings" ]]; then
        log_info "VSCode settings not found, skipping"
        return
    fi

    if command -v jq &> /dev/null; then
        local tmp
        tmp=$(mktemp)
        jq --arg theme "$VSCODE_THEME" '.["workbench.colorTheme"] = $theme' \
            "$vscode_settings" > "$tmp" && mv "$tmp" "$vscode_settings"
        log_success "VSCode theme set to: $VSCODE_THEME"
    else
        # Fallback to sed if jq is not available
        sed -i "s/\"workbench.colorTheme\": \"[^\"]*\"/\"workbench.colorTheme\": \"$VSCODE_THEME\"/" "$vscode_settings"
        log_success "VSCode theme set to: $VSCODE_THEME"
    fi
}

update_gtk_preference() {
    log_info "Updating GTK color scheme..."
    if command -v gsettings &> /dev/null; then
        if [[ "$THEME_TYPE" == "light" ]]; then
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
        else
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        fi
        log_success "GTK color scheme set to: $THEME_TYPE"
    fi
}

#=============================================================================
# MAIN SWITCH FUNCTION
#=============================================================================

switch_theme() {
    local theme="$1"
    local no_restart="${2:-false}"

    echo ""
    echo "======================================"
    echo "  Theme Switcher"
    echo "======================================"
    echo ""
    log_info "Switching to theme: $theme"
    echo ""

    # Validate theme exists
    if ! validate_theme "$theme"; then
        log_error "Unknown theme: $theme"
        echo ""
        list_themes
        exit 1
    fi

    # Source theme definition
    local theme_file="$DEFINITIONS_DIR/${theme}.sh"
    if [[ ! -f "$theme_file" ]]; then
        log_error "Theme definition not found: $theme_file"
        exit 1
    fi

    # shellcheck source=/dev/null
    source "$theme_file"

    echo "--- Updating configurations ---"
    echo ""

    # Update all application configs
    update_kitty
    update_waybar
    update_wofi
    update_swaync
    update_hyprland
    update_hyprlock
    update_btop
    update_vscode
    update_gtk_preference

    # Save current theme
    mkdir -p "$THEMES_DIR"
    echo "$theme" > "$CURRENT_THEME_FILE"

    # Reload applications (unless --no-restart)
    if [[ "$no_restart" != "true" ]]; then
        echo ""
        echo "--- Reloading applications ---"
        echo ""
        reload_kitty
        reload_waybar
        reload_swaync
        reload_hyprland
        reload_btop
    fi

    echo ""
    echo "======================================"
    log_success "Theme switched to: $THEME_NAME"
    echo "======================================"
    echo ""

    notify "Theme changed to $THEME_NAME"
}

#=============================================================================
# CLI INTERFACE
#=============================================================================

show_help() {
    cat << 'EOF'
Theme Switcher - NixOS Hyprland Theme Management

USAGE:
    theme-switcher.sh [COMMAND] [OPTIONS]

COMMANDS:
    <theme-name>    Switch to the specified theme
    list            List available themes
    current         Show current theme
    help            Show this help message

OPTIONS:
    --no-restart    Update configs without reloading applications

EXAMPLES:
    theme-switcher.sh catppuccin-mocha
    theme-switcher.sh nord --no-restart
    theme-switcher.sh list
    theme-switcher.sh current

AVAILABLE THEMES:
    catppuccin-mocha    Dark, warm pastel theme
    catppuccin-latte    Light, warm pastel theme
    nord                Cool, arctic color palette
    dracula             Dark purple theme
    gruvbox-dark        Retro groove dark theme
    gruvbox-light       Retro groove light theme
    tokyo-night         Tokyo city lights dark theme
    rose-pine           All natural pine dark theme
EOF
}

main() {
    local command="${1:-help}"
    local no_restart="false"

    # Parse options
    for arg in "$@"; do
        case "$arg" in
            --no-restart|--apply-only)
                no_restart="true"
                ;;
        esac
    done

    case "$command" in
        list)
            list_themes
            ;;
        current)
            echo "Current theme: $(get_current_theme)"
            ;;
        help|--help|-h)
            show_help
            ;;
        --no-restart|--apply-only)
            show_help
            ;;
        *)
            switch_theme "$command" "$no_restart"
            ;;
    esac
}

main "$@"
