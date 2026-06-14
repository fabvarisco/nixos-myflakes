#!/usr/bin/env bash

# Battery Manager TUI for ThinkPad
# Uses gum for beautiful terminal UI

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Paths
PROFILE_PATH="/sys/firmware/acpi/platform_profile"
PROFILE_CHOICES="/sys/firmware/acpi/platform_profile_choices"
CHARGE_START="/sys/class/power_supply/BAT0/charge_control_start_threshold"
CHARGE_END="/sys/class/power_supply/BAT0/charge_control_end_threshold"
BAT_CAPACITY="/sys/class/power_supply/BAT0/capacity"
BAT_STATUS="/sys/class/power_supply/BAT0/status"
BAT_HEALTH="/sys/class/power_supply/BAT0/energy_full"
BAT_DESIGN="/sys/class/power_supply/BAT0/energy_full_design"

get_battery_info() {
    local capacity=$(cat "$BAT_CAPACITY" 2>/dev/null || echo "?")
    local status=$(cat "$BAT_STATUS" 2>/dev/null || echo "Unknown")
    local profile=$(cat "$PROFILE_PATH" 2>/dev/null || echo "unknown")
    local charge_start=$(cat "$CHARGE_START" 2>/dev/null || echo "?")
    local charge_end=$(cat "$CHARGE_END" 2>/dev/null || echo "?")

    # Calculate battery health
    local health="?"
    if [[ -f "$BAT_HEALTH" && -f "$BAT_DESIGN" ]]; then
        local full=$(cat "$BAT_HEALTH")
        local design=$(cat "$BAT_DESIGN")
        if [[ $design -gt 0 ]]; then
            health=$((full * 100 / design))
        fi
    fi

    echo "$capacity|$status|$profile|$charge_start|$charge_end|$health"
}

show_status() {
    IFS='|' read -r capacity status profile charge_start charge_end health <<< "$(get_battery_info)"

    # Status icon
    local status_icon="⚡"
    local status_color="$YELLOW"
    case "$status" in
        "Charging") status_icon="🔌"; status_color="$GREEN" ;;
        "Discharging") status_icon="🔋"; status_color="$YELLOW" ;;
        "Not charging") status_icon="🔋"; status_color="$CYAN" ;;
        "Full") status_icon="✓"; status_color="$GREEN" ;;
    esac

    # Profile icon
    local profile_icon="⚖️"
    case "$profile" in
        "performance") profile_icon="🚀" ;;
        "balanced") profile_icon="⚖️" ;;
        "low-power") profile_icon="🍃" ;;
    esac

    clear
    echo ""
    gum style \
        --border rounded \
        --border-foreground 212 \
        --padding "1 2" \
        --margin "0 1" \
        "$(gum style --foreground 212 --bold '⚡ Battery Manager')"

    echo ""
    gum style --padding "0 2" "$(echo -e "${BOLD}Current status:${NC}")"
    echo ""
    gum style --padding "0 4" "🔋 Battery:      ${capacity}% (${status})"
    gum style --padding "0 4" "💚 Health:       ${health}%"
    gum style --padding "0 4" "${profile_icon} Profile:      ${profile}"
    gum style --padding "0 4" "🔌 Charge limit: ${charge_start}% - ${charge_end}%"
    echo ""
}

change_profile() {
    local current=$(cat "$PROFILE_PATH" 2>/dev/null)

    echo ""
    gum style --foreground 212 --bold "Select performance profile:"
    echo ""

    local choice=$(gum choose \
        --cursor.foreground 212 \
        --selected.foreground 212 \
        "🚀 performance  (maximum performance, higher consumption)" \
        "⚖️  balanced     (balance between performance and battery)" \
        "🍃 low-power    (power saving, lower performance)" \
        "↩️  Back")

    case "$choice" in
        *performance*)
            echo "performance" | pkexec tee "$PROFILE_PATH" > /dev/null
            gum style --foreground 40 "✓ Profile changed to performance"
            ;;
        *balanced*)
            echo "balanced" | pkexec tee "$PROFILE_PATH" > /dev/null
            gum style --foreground 40 "✓ Profile changed to balanced"
            ;;
        *low-power*)
            echo "low-power" | pkexec tee "$PROFILE_PATH" > /dev/null
            gum style --foreground 40 "✓ Profile changed to low-power"
            ;;
    esac
    sleep 1
}

change_charge_limit() {
    local current_end=$(cat "$CHARGE_END" 2>/dev/null)

    echo ""
    gum style --foreground 212 --bold "Select maximum charge limit:"
    echo ""
    gum style --foreground 245 --italic "  Limiting charge extends battery lifespan"
    echo ""

    local choice=$(gum choose \
        --cursor.foreground 212 \
        --selected.foreground 212 \
        "💚 60%  (maximum lifespan - always plugged in)" \
        "💛 80%  (recommended - good balance)" \
        "🧡 90%  (more capacity, less lifespan)" \
        "❤️  100% (full capacity, normal wear)" \
        "↩️  Back")

    local new_end=""
    local new_start=""

    case "$choice" in
        *60%*) new_end="60"; new_start="55" ;;
        *80%*) new_end="80"; new_start="75" ;;
        *90%*) new_end="90"; new_start="85" ;;
        *100%*) new_end="100"; new_start="95" ;;
        *) return ;;
    esac

    if [[ -n "$new_end" ]]; then
        # Set thresholds (end first if increasing, start first if decreasing)
        if [[ $new_end -gt $current_end ]]; then
            echo "$new_end" | pkexec tee "$CHARGE_END" > /dev/null
            echo "$new_start" | pkexec tee "$CHARGE_START" > /dev/null
        else
            echo "$new_start" | pkexec tee "$CHARGE_START" > /dev/null
            echo "$new_end" | pkexec tee "$CHARGE_END" > /dev/null
        fi
        gum style --foreground 40 "✓ Limit changed to ${new_start}% - ${new_end}%"
    fi
    sleep 1
}

show_health_info() {
    echo ""
    gum style --foreground 212 --bold "Battery health information:"
    echo ""

    if [[ -f "$BAT_HEALTH" && -f "$BAT_DESIGN" ]]; then
        local full=$(cat "$BAT_HEALTH")
        local design=$(cat "$BAT_DESIGN")
        local health=$((full * 100 / design))
        local full_wh=$((full / 1000000))
        local design_wh=$((design / 1000000))

        gum style --padding "0 2" "Current capacity: ${full_wh} Wh"
        gum style --padding "0 2" "Design capacity:  ${design_wh} Wh"
        gum style --padding "0 2" "Battery health:   ${health}%"
        echo ""

        if [[ $health -ge 80 ]]; then
            gum style --foreground 40 --padding "0 2" "✓ Battery in good condition"
        elif [[ $health -ge 60 ]]; then
            gum style --foreground 214 --padding "0 2" "⚠ Battery with moderate wear"
        else
            gum style --foreground 196 --padding "0 2" "✗ Battery with significant wear"
        fi
    else
        gum style --foreground 196 "Health information not available"
    fi

    echo ""
    gum style --foreground 245 "Press Enter to go back..."
    read -r
}

main_menu() {
    while true; do
        show_status

        local choice=$(gum choose \
            --cursor.foreground 212 \
            --selected.foreground 212 \
            "🚀 Change performance profile" \
            "🔋 Change charge limit" \
            "💚 View battery health" \
            "❌ Exit")

        case "$choice" in
            *"profile"*) change_profile ;;
            *"limit"*) change_charge_limit ;;
            *"health"*) show_health_info ;;
            *"Exit"*)
                clear
                exit 0
                ;;
        esac
    done
}

# Check requirements
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed"
    exit 1
fi

if [[ ! -f "$PROFILE_PATH" ]]; then
    echo "Error: platform_profile not available on this system"
    exit 1
fi

main_menu
