#!/usr/bin/env bash

# Watch for monitor changes and auto-apply hyprmon profile
# Uses Hyprland IPC socket to detect monitor connect/disconnect events

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

handle() {
    case $1 in
        monitoradded*|monitorremoved*)
            sleep 0.5  # Wait for monitor to stabilize
            "$SCRIPT_DIR/hyprmon-auto.sh"
            ;;
    esac
}

# Listen to Hyprland socket events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done
