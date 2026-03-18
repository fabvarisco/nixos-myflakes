#!/usr/bin/env bash

options="󰌾 Lock\n󰤄 Suspend\n󰍃 Logout\n󰜉 Reboot\n󰐥 Shutdown"

selected=$(echo -e "$options" | vicinae dmenu --placeholder "Power Menu")

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
