#!/bin/bash

# Path to the cap menu application
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="/tmp/cap_menu_open"
BUN_PATH="$HOME/.bun/bin/bun"
WAYCAP_SCRIPT="$HOME/.config/waybar/modules/waycap/waycap.sh"

# Use system bun if the user-specific one doesn't exist
if [ ! -x "$BUN_PATH" ]; then
    BUN_PATH="$(which bun 2>/dev/null || echo "")"
    if [ -z "$BUN_PATH" ]; then
        echo "Error: bun not found in PATH or in $HOME/.bun/bin/" >&2
        exit 1
    fi
fi

# Function to toggle the menu
toggle_menu() {
    # Menu is closed, open it
    cd "$SCRIPT_DIR" || exit 1
    
    # Run in a terminal for better visibility
    if command -v ghostty &> /dev/null; then
        ghostty --title='Cap Menu' -e "$BUN_PATH run $SCRIPT_DIR/waycap.tsx" &
    else
        # Fall back to direct execution
        "$BUN_PATH" run "$SCRIPT_DIR/waycap.tsx" &
    fi
    
    touch "$STATE_FILE"
}

# Function to close the menu
close_menu() {
    pkill -f "bun run.*waycap.tsx" 2>/dev/null
    pkill -f "ghostty --title='Cap Menu'" 2>/dev/null
    rm -f "$STATE_FILE"
}

# Function to execute a specific action directly
execute_action() {
    local action="$1"
    
    # Close the menu first if it's open
    close_menu
    
    # Execute the action
    if [ -x "$WAYCAP_SCRIPT" ]; then
        "$WAYCAP_SCRIPT" "$action"
    else
        echo "Error: Waycap script not found or not executable: $WAYCAP_SCRIPT"
        exit 1
    fi
}

case "$1" in
    toggle)
        toggle_menu
        ;;
    close)
        close_menu
        ;;
    screenshot_region|screenshot_screen|record_region|record_screen)
        execute_action "$1"
        ;;
    *)
        echo "Usage: $0 {toggle|close|screenshot_region|screenshot_screen|record_region|record_screen}"
        exit 1
        ;;
esac

exit 0 