#!/bin/bash
chosen=$(printf " Lock\n󰤄 Sleep\n󰜉 Reboot\n󰐥 Shutdown" | wofi -dmenu -i -p "Power:")
case "$chosen" in
    " Lock") swaylock -f ;;
    "󰤄 Sleep") systemctl suspend ;;
    "󰜉 Reboot") systemctl reboot ;;
    "󰐥 Shutdown") systemctl poweroff ;;
esac
