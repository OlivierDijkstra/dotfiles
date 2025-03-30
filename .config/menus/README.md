# System Menu

A simple TUI menu for system actions (lock, suspend, shutdown, reboot) that can be run from waybar.

## Features

- Simple and fast TUI interface
- Keyboard navigation (arrow keys or j/k)
- Four system actions: lock, suspend, shutdown, reboot

## Installation

To install dependencies:

```bash
bun install
```

## Usage

To run the menu directly:

```bash
./system-menu.sh
```

Or:

```bash
bun run index.tsx
```

## Integration with Waybar

Add the following to your Waybar configuration:

```json
"custom/power": {
    "format": "⏻",
    "tooltip": false,
    "on-click": "~/.config/menus/system/system-menu.sh"
}
```

Then add `"custom/power"` to your Waybar modules list.

## Customization

You can modify the system commands in `index.tsx` by editing the `menuItems` array.

This project uses [Ink](https://github.com/vadimdemedes/ink) for the TUI interface and [Bun](https://bun.sh) as the JavaScript runtime.
