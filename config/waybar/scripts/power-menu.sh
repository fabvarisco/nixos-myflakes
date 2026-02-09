#!/usr/bin/env bash

options="󰌾 Lock\n󰤄 Suspend\n󰍃 Logout\n󰜉 Reboot\n󰐥 Shutdown"

selected=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --width 200 --height 230)

case "$selected" in
    "󰌾 Lock")
        hyprlock
        ;;
    "󰤄 Suspend")
        systemctl suspend
        ;;
    "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    "󰜉 Reboot")
        systemctl reboot
        ;;
    "󰐥 Shutdown")
        systemctl poweroff
        ;;
esac
