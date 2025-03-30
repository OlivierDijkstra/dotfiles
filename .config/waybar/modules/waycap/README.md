# WayCap

A versatile screen capture module for Waybar on Wayland compositors, providing screenshot and screen recording functionality.

## Features

- 📷 Take screenshots of regions or the entire screen
- 🎥 Record videos of regions or the entire screen
- 🔄 Shows recording status with a dynamic icon
- 📂 Automatically saves captures to organized directories

## Dependencies

- **grim** - For taking screenshots
- **slurp** - For region selection
- **wf-recorder** - For screen recording
- **libnotify** (notify-send) - For notifications
- **yad** or **zenity** (optional) - For the graphical menu

## Installation

1. Create the modules directory in your waybar config (if it doesn't exist):

```bash
mkdir -p ~/.config/waybar/modules/
```

2. Copy the waycap folder to your waybar modules directory:

```bash
cp -r waycap ~/.config/waybar/modules/
```

3. Make the script executable:

```bash
chmod +x ~/.config/waybar/modules/waycap/waycap.sh
```

4. Add the module to your waybar config (`~/.config/waybar/config.jsonc`):

```json
"custom/waycap": {
    "format": "{}",
    "return-type": "json",
    "interval": "once",
    "exec": "$HOME/.config/waybar/modules/waycap/waycap.sh",
    "on-click": "$HOME/.config/waybar/modules/waycap/waycap.sh menu",
    "on-click-right": "$HOME/.config/waybar/modules/waycap/waycap.sh screenshot_region",
    "signal": 10,
    "tooltip": true,
    "escape": false
}
```

5. Add the module to your modules-right (or modules-left/modules-center) array:

```json
"modules-right": ["custom/waycap", "custom/waypick", "pulseaudio", "battery", "clock"],
```

6. Style how you want, example:

```css
#custom-waycap {
  font-size: 16px;
  padding: 0 10px;
}
```

7. Restart waybar:

```bash
pkill waybar && sleep 1 && waybar &
```

## Usage

- **Left-click**: Show the capture options menu
- **Right-click**: Quick screenshot of a selected region

### Advanced Usage

You can directly call the script with specific actions:

- `~/.config/waybar/modules/waycap/waycap.sh screenshot_region` - Take a screenshot of a selected region
- `~/.config/waybar/modules/waycap/waycap.sh screenshot_screen` - Take a screenshot of the entire screen
- `~/.config/waybar/modules/waycap/waycap.sh record_region` - Start/stop recording a selected region
- `~/.config/waybar/modules/waycap/waycap.sh record_screen` - Start/stop recording the entire screen

## Customization

You can customize the module by editing the `waycap.sh` script. Some possible customizations:

- Change the output directories for screenshots and recordings
- Modify the file naming format
- Add additional capture options
- Change the menu system

## Menu System

The module uses a simple menu system with the following priority:

1. **yad** - A GTK dialog tool that works well with Wayland
2. **zenity** - Another GTK dialog tool
3. Fallback to notifications if neither is available

To install yad (recommended):

```bash
# On Arch Linux
sudo pacman -S yad

# On Ubuntu/Debian
sudo apt install yad
```

## License

MIT 