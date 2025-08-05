# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Linux dotfiles repository for a Hyprland-based desktop environment running on CachyOS (Arch Linux derivative). The configuration includes:

- **Hyprland**: Wayland compositor with configuration split across multiple files in `.config/hypr/config/`
- **AGS (Astal Shell)**: TypeScript-based desktop shell for bars and widgets using GTK3/Astal framework
- **Neovim**: LazyVim-based configuration with plugins for development
- **System utilities**: btop, rofi, mako, yazi, ghostty, and various theme configurations

## System Information

- **OS**: CachyOS (Arch Linux derivative) 
- **Kernel**: Linux 6.16.0-5-cachyos
- **Window Manager**: Hyprland (Wayland)
- **Shell/Bar**: AGS (Astal-based TypeScript)
- **Terminal**: Warp Terminal (`/opt/warpdotdev/warp-terminal/warp`)
- **File Manager**: Nautilus
- **Launcher**: Rofi

## Key Architecture

### AGS Shell Structure
- **Entry point**: `.config/ags/app.ts` - Main application with monitor management and error handling
- **Styling**: `.config/ags/style.scss` - SCSS styling for all components
- **Widgets**: `.config/ags/widget/` - Contains Bar and other widget components
- **Framework**: Uses Astal/GTK3 instead of traditional AGS
- **Multi-monitor**: Robust monitor detection with retry logic and event handling

### Hyprland Configuration
Configuration is modularized in `.config/hypr/config/`:
- `defaults.conf` - Default applications and variables
- `decorations.conf` - Window decorations and visual effects  
- `variables.conf` - Environment variables and settings
- `windowrules.conf` - Window-specific rules and behavior
- `autostart.conf` - Applications to start with Hyprland

### Neovim Setup
- **Base**: LazyVim starter template
- **Old config**: Backed up to `.config/nvim.old/`
- **Active config**: `.config/nvim/` with custom plugins and configurations

## Common Commands

### AGS Development
```bash
# Lint AGS code
cd .config/ags && npm run lint

# Restart AGS service
systemctl --user restart ags.service

# Quick restart with notification (using provided script)
.config/scripts/restart-ags.sh
```

### System Management
```bash
# Reload Hyprland configuration
hyprctl reload

# Check running services
systemctl --user status ags.service
```

## Development Notes

- AGS uses TypeScript with Astal framework, not traditional AGS
- Multi-monitor setup requires careful handling of monitor events
- Configuration files use modular approach for maintainability
- Scripts directory contains utility scripts for common tasks