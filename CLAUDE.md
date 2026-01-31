# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for a CachyOS (Arch-based) Linux system running Hyprland (Wayland compositor).

## Environment

- **OS**: CachyOS (Arch Linux derivative)
- **Shell**: zsh
- **Window Manager**: Hyprland
- **Terminal**: Ghostty
- **Editor**: Neovim (with lazy.nvim plugin manager)

## Package Management

- Use `pacman` for official packages, `yay` for AUR packages
- Do not suggest apt, dnf, or other non-Arch package managers

## Repository Structure

### scripts/
Utility shell scripts:
- `screenrecord` - Screen recording using wf-recorder and slurp (zsh)
- `syscheck.sh` - Post-update system diagnostics (bash)

### .config/hypr/
Hyprland configuration with modular structure:
- `hyprland.conf` - Main config, sources all other files
- `config/` - Split configs: animations, autostart, decorations, environment, input, keybinds, monitor, variables, windowrules

### .config/nvim/
Neovim configuration using lazy.nvim:
- `init.lua` - Bootstrap and plugin setup
- `lua/config/` - Core settings (options, keymaps, autocmds)
- `lua/plugins/` - Plugin specifications

### Other configs
btop, fastfetch, ghostty, hyprpanel, mako, mpv, rofi, xdg-desktop-portal, yazi

## Conventions

- Use absolute paths in tool calls (e.g., `/home/oli/dotfiles/scripts/syscheck.sh`)
- Keep edits minimal and consistent with existing style
- Avoid destructive actions unless explicitly requested
