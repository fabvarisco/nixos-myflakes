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
    gum style --padding "0 2" "$(echo -e "${BOLD}Status atual:${NC}")"
    echo ""
    gum style --padding "0 4" "🔋 Bateria:      ${capacity}% (${status})"
    gum style --padding "0 4" "💚 Saúde:        ${health}%"
    gum style --padding "0 4" "${profile_icon} Perfil:       ${profile}"
    gum style --padding "0 4" "🔌 Limite carga: ${charge_start}% - ${charge_end}%"
    echo ""
}

change_profile() {
    local current=$(cat "$PROFILE_PATH" 2>/dev/null)

    echo ""
    gum style --foreground 212 --bold "Selecione o perfil de performance:"
    echo ""

    local choice=$(gum choose \
        --cursor.foreground 212 \
        --selected.foreground 212 \
        "🚀 performance  (máximo desempenho, mais consumo)" \
        "⚖️  balanced     (equilíbrio entre performance e bateria)" \
        "🍃 low-power    (economia de energia, menos performance)" \
        "↩️  Voltar")

    case "$choice" in
        *performance*)
            echo "performance" | pkexec tee "$PROFILE_PATH" > /dev/null
            gum style --foreground 40 "✓ Perfil alterado para performance"
            ;;
        *balanced*)
            echo "balanced" | pkexec tee "$PROFILE_PATH" > /dev/null
            gum style --foreground 40 "✓ Perfil alterado para balanced"
            ;;
        *low-power*)
            echo "low-power" | pkexec tee "$PROFILE_PATH" > /dev/null
            gum style --foreground 40 "✓ Perfil alterado para low-power"
            ;;
    esac
    sleep 1
}

change_charge_limit() {
    local current_end=$(cat "$CHARGE_END" 2>/dev/null)

    echo ""
    gum style --foreground 212 --bold "Selecione o limite máximo de carregamento:"
    echo ""
    gum style --foreground 245 --italic "  Limitar a carga prolonga a vida útil da bateria"
    echo ""

    local choice=$(gum choose \
        --cursor.foreground 212 \
        --selected.foreground 212 \
        "💚 60%  (máxima longevidade - uso sempre conectado)" \
        "💛 80%  (recomendado - bom equilíbrio)" \
        "🧡 90%  (mais capacidade, menos longevidade)" \
        "❤️  100% (capacidade total, desgaste normal)" \
        "↩️  Voltar")

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
        gum style --foreground 40 "✓ Limite alterado para ${new_start}% - ${new_end}%"
    fi
    sleep 1
}

show_health_info() {
    echo ""
    gum style --foreground 212 --bold "Informações de saúde da bateria:"
    echo ""

    if [[ -f "$BAT_HEALTH" && -f "$BAT_DESIGN" ]]; then
        local full=$(cat "$BAT_HEALTH")
        local design=$(cat "$BAT_DESIGN")
        local health=$((full * 100 / design))
        local full_wh=$((full / 1000000))
        local design_wh=$((design / 1000000))

        gum style --padding "0 2" "Capacidade atual:  ${full_wh} Wh"
        gum style --padding "0 2" "Capacidade design: ${design_wh} Wh"
        gum style --padding "0 2" "Saúde da bateria:  ${health}%"
        echo ""

        if [[ $health -ge 80 ]]; then
            gum style --foreground 40 --padding "0 2" "✓ Bateria em bom estado"
        elif [[ $health -ge 60 ]]; then
            gum style --foreground 214 --padding "0 2" "⚠ Bateria com desgaste moderado"
        else
            gum style --foreground 196 --padding "0 2" "✗ Bateria com desgaste significativo"
        fi
    else
        gum style --foreground 196 "Informações de saúde não disponíveis"
    fi

    echo ""
    gum style --foreground 245 "Pressione Enter para voltar..."
    read -r
}

main_menu() {
    while true; do
        show_status

        local choice=$(gum choose \
            --cursor.foreground 212 \
            --selected.foreground 212 \
            "🚀 Alterar perfil de performance" \
            "🔋 Alterar limite de carregamento" \
            "💚 Ver saúde da bateria" \
            "❌ Sair")

        case "$choice" in
            *"perfil"*) change_profile ;;
            *"limite"*) change_charge_limit ;;
            *"saúde"*) show_health_info ;;
            *"Sair"*)
                clear
                exit 0
                ;;
        esac
    done
}

# Check requirements
if ! command -v gum &> /dev/null; then
    echo "Erro: gum não está instalado"
    exit 1
fi

if [[ ! -f "$PROFILE_PATH" ]]; then
    echo "Erro: platform_profile não disponível neste sistema"
    exit 1
fi

main_menu
