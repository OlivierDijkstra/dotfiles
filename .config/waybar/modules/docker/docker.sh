#!/bin/bash

# File paths
STATE_FILE="$HOME/.config/waybar/modules/docker/state"

# Icons
ICONS='{
    "down": "󰆧",
    "loading": "",
    "running": ""
}'

# Default state
DEFAULT_STATE="down"

# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "$DEFAULT_STATE" > "$STATE_FILE"
fi

# Get current state
CURRENT_STATE=$(cat "$STATE_FILE")

# Check if Docker daemon is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "down"
    else
        # Check if there are any running containers
        if [ "$(docker ps -q)" ]; then
            echo "running"
        else
            echo "down"
        fi
    fi
}

# Toggle state function
toggle_state() {
    local new_state
    case "$CURRENT_STATE" in
        "down")
            new_state="loading"
            echo "$new_state" > "$STATE_FILE"
            # Start Docker service and check if it succeeded
            if systemctl start docker.service; then
                # Wait for Docker to be ready
                while ! docker info >/dev/null 2>&1; do
                    sleep 1
                done
                new_state="running"
            else
                # If systemctl failed, revert to down state
                new_state="down"
            fi
            ;;
        "running")
            new_state="loading"
            echo "$new_state" > "$STATE_FILE"
            # Stop all containers and Docker service, check if it succeeded
            docker stop $(docker ps -q) 2>/dev/null || true
            if systemctl stop docker.service; then
                new_state="down"
            else
                # If systemctl failed, revert to running state
                new_state="running"
            fi
            ;;
        "loading")
            return 1
            ;;
    esac
    
    echo "$new_state" > "$STATE_FILE"
    # Signal waybar to update
    pkill -RTMIN+9 waybar
}

# Output JSON for waybar
output_json() {
    local icon
    local tooltip
    local class
    
    case "$CURRENT_STATE" in
        "down")
            icon=$(echo "$ICONS" | jq -r '.down')
            tooltip="Docker: Stopped"
            class="docker"
            ;;
        "loading")
            icon=$(echo "$ICONS" | jq -r '.loading')
            tooltip="Docker: Loading..."
            class="docker loading"
            ;;
        "running")
            icon=$(echo "$ICONS" | jq -r '.running')
            tooltip="Docker: Running"
            class="docker running"
            ;;
    esac
    
    printf '{"text": "%s", "tooltip": "%s", "class": "%s", "alt": "%s"}' "$icon" "$tooltip" "$class" "$CURRENT_STATE"
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