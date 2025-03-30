# Docker Module for Waybar

A Docker status module for Waybar that shows the current state of Docker and allows easy control.

## Features

- Shows Docker status with three states:
  - Down (stopped)
  - Loading (transitioning)
  - Running (active)
- Customizable icons for each state
- Left-click to toggle Docker service
- Right-click to open lazydocker
- Prevents spam clicking with loading state
- Automatic state detection

## Dependencies

- **docker** - Docker daemon
- **lazydocker** - Terminal UI for Docker
- **jq** - JSON processor
- **systemctl** - System service manager

## Installation

1. Make the script executable:

```bash
chmod +x ~/.config/waybar/modules/docker/docker.sh
```

2. Add the module to your waybar config (`~/.config/waybar/config.jsonc`):

```json
"custom/docker": {
    "format": "{}",
    "return-type": "json",
    "interval": "once",
    "exec": "$HOME/.config/waybar/modules/docker/docker.sh",
    "on-click": "$HOME/.config/waybar/modules/docker/docker.sh toggle && pkill -RTMIN+9 waybar",
    "on-click-right": "ghostty --title='Docker Control' -e 'lazydocker'",
    "signal": 9,
    "tooltip": true,
    "escape": false
}
```

3. Add the module to your modules-right (or modules-left/modules-center) array:

```json
"modules-right": ["custom/docker", "pulseaudio", "battery", "clock"],
```

4. Style how you want, example:

```css
#custom-docker {
    font-size: 16px;
    padding: 0 10px;
}

#custom-docker.docker {
    color: #FF8080;
}

#custom-docker.docker.loading {
    color: #FFC799;
}

#custom-docker.docker.running {
    color: #99FFE4;
}
```

## Customization

You can customize the icons by editing the `config.jsonc` file in the docker module directory:

```json
{
    "icons": {
        "down": "󰡑",
        "loading": "󰑮",
        "running": "󰡔"
    }
}
```

## Usage

- **Left-click**: Toggle Docker service (start/stop)
- **Right-click**: Open lazydocker in a new terminal window

## License

MIT 