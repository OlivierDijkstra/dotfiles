#!/bin/bash

# File paths
STATE_FILE="$HOME/.config/waybar/modules/hyprsunset/state"

# Default temperatures
NORMAL_TEMP=6500
WARM_TEMP=4000

# Icons (using simple text for testing)
LIGHT_ICON=""  # Normal lightbulb icon
DIM_ICON=""   # Dimmed lightbulb icon

# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "off" > "$STATE_FILE"
fi

# Get current state
CURRENT_STATE=$(cat "$STATE_FILE")

# Toggle state function
toggle_state() {
    if [ "$CURRENT_STATE" = "off" ]; then
        echo "on" > "$STATE_FILE"
        hyprsunset -t $WARM_TEMP
    else
        echo "off" > "$STATE_FILE"
        hyprsunset -i
    fi
    
    # Signal waybar to update
    pkill -RTMIN+9 waybar
}

# Output JSON for waybar
output_json() {
    if [ "$CURRENT_STATE" = "on" ]; then
        printf '{"text": "%s", "tooltip": "Night Light: On (%d K)", "class": "hyprsunset", "alt": "on"}' "$DIM_ICON" "$WARM_TEMP"
    else
        printf '{"text": "%s", "tooltip": "Night Light: Off (%d K)", "class": "hyprsunset", "alt": "off"}' "$LIGHT_ICON" "$NORMAL_TEMP"
    fi
}

# Main logic
case "$1" in
    toggle)
        toggle_state
        ;;
    *)
        output_json
        ;;
esac

