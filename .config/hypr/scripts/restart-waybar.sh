#!/bin/bash

# Script to restart waybar
# Created for quick and easy waybar restarts

# Kill any existing waybar instances
killall waybar

# Wait a moment to ensure waybar is fully terminated
sleep 0.5

# Start waybar in the background
waybar &

# Notify user that waybar has been restarted
if command -v notify-send &> /dev/null; then
    notify-send "Waybar" "Waybar has been restarted" -i "system-restart-panel"
fi

exit 0 