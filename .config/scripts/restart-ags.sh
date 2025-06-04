#!/bin/bash

# Quick AGS restart script
systemctl --user restart ags.service

# Optional: send notification
if command -v notify-send &> /dev/null; then
    notify-send "AGS" "Bar restarted" -t 2000
fi 