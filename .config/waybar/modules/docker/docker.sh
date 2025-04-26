#!/bin/bash

# File paths
STATE_FILE="$HOME/.config/waybar/modules/docker/state"

# Icons
ICONS='{
    "down": "󰆧",
    "loading": "",
    "running": " "
}'

# Default state
DEFAULT_STATE="down"

# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "$DEFAULT_STATE" > "$STATE_FILE"
fi

# Check if Docker daemon is running
check_docker() {
    # First check if the service is running at the system level
    if systemctl is-active --quiet docker.service; then
        # Service is running, check if daemon is responsive
        if docker info >/dev/null 2>&1; then
            # Check if there are any running containers
            if [ "$(docker ps -q)" ]; then
                echo "running"
            else
                # No containers but service is up
                echo "running"
            fi
        else
            # Service is running but daemon not responsive
            echo "down"
        fi
    else
        # Service is not running
        echo "down"
    fi
}

# Get current state from state file
SAVED_STATE=$(cat "$STATE_FILE")

# Always check actual Docker status
ACTUAL_STATE=$(check_docker)

# Update state file if it doesn't match actual state
if [ "$SAVED_STATE" != "$ACTUAL_STATE" ]; then
    echo "$ACTUAL_STATE" > "$STATE_FILE"
fi

# Use the actual state for the current state
CURRENT_STATE="$ACTUAL_STATE"

# Toggle state function
toggle_state() {
    local new_state
    case "$CURRENT_STATE" in
        "down")
            new_state="loading"
            echo "$new_state" > "$STATE_FILE"
            # Signal waybar to show loading state
            pkill -RTMIN+9 waybar
            
            # Start Docker service and check if it succeeded
            systemctl start docker.service
            
            # Regardless of systemctl's return code, check actual status
            sleep 1
            if systemctl is-active --quiet docker.service && docker info >/dev/null 2>&1; then
                new_state="running"
            else
                # Docker failed to start or auth was canceled
                new_state="down"
            fi
            ;;
        "running")
            new_state="loading"
            echo "$new_state" > "$STATE_FILE"
            # Signal waybar to show loading state
            pkill -RTMIN+9 waybar
            
            # Stop all containers and Docker service, check if it succeeded
            docker stop $(docker ps -q) 2>/dev/null || true
            systemctl stop docker.service
            
            # Regardless of systemctl's return code, check actual status
            sleep 1
            if systemctl is-active --quiet docker.service; then
                new_state="running"
            else
                new_state="down"
            fi
            ;;
        "loading")
            return 1
            ;;
    esac
    
    # Update state file with final state
    echo "$new_state" > "$STATE_FILE"
    # Force check actual state again to be sure
    ACTUAL_STATE=$(check_docker)
    echo "$ACTUAL_STATE" > "$STATE_FILE"
    # Signal waybar to update with final state
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
    debug)
        DOCKER_ACTIVE=$(systemctl is-active docker.service)
        DOCKER_INFO_WORKS=$(docker info >/dev/null 2>&1 && echo "yes" || echo "no")
        RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l)
        
        echo "Debug information:"
        echo "  systemctl is-active docker.service: $DOCKER_ACTIVE"
        echo "  docker info works: $DOCKER_INFO_WORKS"
        echo "  running containers: $RUNNING_CONTAINERS"
        echo "  saved state: $(cat $STATE_FILE)"
        echo "  detected state: $(check_docker)"
        ;;
    *)
        output_json
        ;;
esac 