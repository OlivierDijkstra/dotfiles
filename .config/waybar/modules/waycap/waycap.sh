#!/bin/bash

# Storage locations
CONFIG_DIR="$HOME/.config/waybar/modules/waycap"
LAST_ACTION_FILE="$CONFIG_DIR/last_action"
CAP_MENU_DIR="$HOME/.config/menus"
DEBUG_LOG="$CONFIG_DIR/debug.log"

# Enable debug logging
DEBUG=true

# Debug function
debug() {
    if [ "$DEBUG" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$DEBUG_LOG"
    fi
}

# Create files if they don't exist
mkdir -p "$CONFIG_DIR"
if [ ! -f "$LAST_ACTION_FILE" ]; then
    echo "screenshot_region" > "$LAST_ACTION_FILE"
fi

# Log the command being executed
debug "Command: $0 $*"

# Dependencies check
check_dependencies() {
    local missing_deps=()
    
    # Check for grim (screenshot tool)
    if ! command -v grim &> /dev/null; then
        missing_deps+=("grim")
    fi
    
    # Check for slurp (region selection)
    if ! command -v slurp &> /dev/null; then
        missing_deps+=("slurp")
    fi
    
    # Check for wf-recorder (screen recording)
    if ! command -v wf-recorder &> /dev/null; then
        missing_deps+=("wf-recorder")
    fi
    
    # Check for notify-send (notifications)
    if ! command -v notify-send &> /dev/null; then
        missing_deps+=("libnotify")
    fi
    
    # Check for bun (JavaScript runtime)
    if ! command -v bun &> /dev/null; then
        echo "bun not found, cap menu may not work properly" >&2
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        notify-send "WayCap Error" "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

get_last_action() {
    cat "$LAST_ACTION_FILE"
}

set_last_action() {
    echo "$1" > "$LAST_ACTION_FILE"
}

screenshot_region() {
    local output_file="$HOME/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png"
    local output_dir="$HOME/Pictures"
    mkdir -p "$output_dir"
    
    grim -g "$(slurp)" "$output_file"
    
    if [ $? -eq 0 ]; then
        # Get relative path for cleaner display
        local rel_path="${output_file/#$HOME/~}"
        notify-send "Screenshot Captured" "$rel_path"
        set_last_action "screenshot_region"
    else
        notify-send "Screenshot Failed" "Failed to capture region"
    fi
    
    # Signal waybar to update
    pkill -RTMIN+9 waybar
}

screenshot_screen() {
    local output_file="$HOME/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png"
    local output_dir="$HOME/Pictures"
    mkdir -p "$output_dir"
    
    grim "$output_file"
    
    if [ $? -eq 0 ]; then
        # Get relative path for cleaner display
        local rel_path="${output_file/#$HOME/~}"
        notify-send "Screenshot Captured" "$rel_path"
        set_last_action "screenshot_screen"
    else
        notify-send "Screenshot Failed" "Failed to capture screen"
    fi
    
    # Signal waybar to update
    pkill -RTMIN+9 waybar
}

# Check if recording is in progress
is_recording() {
    local recording=false
    if pgrep -x "wf-recorder" > /dev/null; then
        recording=true
    fi
    
    debug "is_recording check: $recording"
    
    if [ "$recording" = true ]; then
        return 0  # True in bash
    else
        return 1  # False in bash
    fi
}

show_menu() {
    debug "Entering show_menu function"
    
    # Check if recording is in progress
    if is_recording; then
        debug "Recording in progress, stopping recording"
        
        # Stop the recording
        local output_file="$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4"
        local output_dir="$HOME/Videos"
        pkill -x wf-recorder
        
        # Get relative path for cleaner display
        local rel_path="${output_file/#$HOME/~}"
        notify-send "Recording Stopped" "$rel_path"
        
        # Signal waybar to update
        pkill -RTMIN+9 waybar
        debug "Recording stopped, waybar updated"
        return
    fi

    debug "No recording in progress, showing menu"
    
    # If not recording, show the cap menu
    if [ -f "$CAP_MENU_DIR/toggle.sh" ]; then
        debug "Launching cap menu via toggle.sh"
        "$CAP_MENU_DIR/toggle.sh" toggle
    else
        debug "toggle.sh not found, falling back to notification"
        # Fall back to a simple notification with options
        notify-send "WayCap Options" "Run one of these commands:\n\n$0 screenshot_region\n$0 screenshot_screen\n$0 record_region\n$0 record_screen"
    fi
}

record_region() {
    debug "Entering record_region function"
    
    local output_file="$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4"
    local output_dir="$HOME/Videos"
    mkdir -p "$output_dir"
    
    # Check if already recording
    if is_recording; then
        debug "Already recording, stopping recording"
        pkill -x wf-recorder
        
        # Get relative path for cleaner display
        local rel_path="${output_file/#$HOME/~}"
        notify-send "Recording Stopped" "$rel_path"
    else
        debug "Not recording, starting region recording"
        notify-send "Select Region" "Select the region to record"
        
        # Get the region selection first
        local region=$(slurp)
        
        # Only start recording if a region was selected (slurp wasn't canceled)
        if [ -n "$region" ]; then
            debug "Region selected: $region"
            wf-recorder -g "$region" -f "$output_file" &
            
            # Get relative path for cleaner display
            local rel_path="${output_file/#$HOME/~}"
            notify-send "Recording Started" "Recording region to: $rel_path\nDirectory: $output_dir"
        else
            debug "No region selected, canceling"
            notify-send "Recording Canceled" "No region selected"
            return
        fi
    fi
    
    set_last_action "record_region"
    
    # Signal waybar to update
    pkill -RTMIN+9 waybar
    debug "record_region completed"
}

record_screen() {
    debug "Entering record_screen function"
    
    local output_file="$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4"
    local output_dir="$HOME/Videos"
    mkdir -p "$output_dir"
    
    # Check if already recording
    if is_recording; then
        debug "Already recording, stopping recording"
        pkill -x wf-recorder
        
        # Get relative path for cleaner display
        local rel_path="${output_file/#$HOME/~}"
        notify-send "Recording Stopped" "$rel_path"
    else
        debug "Not recording, starting screen recording"
        wf-recorder -f "$output_file" &
        
        # Get relative path for cleaner display
        local rel_path="${output_file/#$HOME/~}"
        notify-send "Recording Started" "$rel_path"
    fi
    
    set_last_action "record_screen"
    
    # Signal waybar to update
    pkill -RTMIN+9 waybar
    debug "record_screen completed"
}

output_json() {
    local action=$(get_last_action)
    local icon="󰄀"  # Camera icon (Nerd Font)
    local tooltip="Click to show capture options"
    
    # Check if recording is in progress
    if is_recording; then
        icon="󰑊"  # Recording icon (Nerd Font)
        tooltip="Recording in progress. Click to stop."
    fi
    
    # Output clean JSON for waybar
    printf '{"text": "%s", "tooltip": "%s", "class": "waycap", "alt": "%s"}\n' "$icon" "$tooltip" "$action"
}

case "$1" in
    screenshot_region)
        screenshot_region
        ;;
    screenshot_screen)
        screenshot_screen
        ;;
    record_region)
        record_region
        ;;
    record_screen)
        record_screen
        ;;
    menu)
        show_menu
        ;;
    *)
        check_dependencies
        output_json
        ;;
esac