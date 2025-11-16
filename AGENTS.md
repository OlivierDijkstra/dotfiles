## Agent Environment Overview

This repository contains personal configuration files (**dotfiles**) for the user.

### System
- **OS**: Linux (`linux 6.17.8-2-cachyos`)
- **Primary workspace path**: `/home/oli/dotfiles`
- **Default shell**: `/usr/bin/zsh`

### Repository Purpose
- **Goal**: Track and manage system configuration, scripts, and related setup files.
- **Primary usage**: Customize and maintain the user's development and desktop environment.

### Conventions for Tools / Agents
- **Working directory**: Assume `/home/oli/dotfiles` as the project root.
- **Paths**: Prefer **absolute paths** in tool calls (e.g., `/home/oli/dotfiles/scripts/syscheck.sh`).
- **Edits**: When making changes, keep them:
  - Minimal and well-scoped
  - Consistent with existing style and structure

### Notable Directories
- **`scripts/`**: Utility scripts and helpers.
  - `scripts/screenrecord`: Screen recording helper.
  - `scripts/syscheck.sh`: System check / diagnostics helper.

### Package Management
- **Distro family**: Arch-based (CachyOS)
- **System package manager**: `pacman`
- **AUR helper**: `yay`
- **Guidelines**:
  - Prefer `pacman` / `yay` when suggesting system package management commands.
  - Do not suggest `apt`, `dnf`, `yum`, or other non-Arch package managers unless explicitly requested.
  - When suggesting install commands, propose them but do not assume they have been run.

### Agent Best Practices
- **Explain changes briefly**: Summarize what was modified and why.
- **Avoid destructive actions**: Do not delete or overwrite files unless explicitly requested.
- **Check for cleanliness**: Aim to keep `git status` clean after changes, unless work-in-progress is expected.

### Additional Notes
- **Absolute paths**: When invoking tools or scripts, prefer absolute paths rooted at `/home/oli`.
- **System-wide changes**: For anything that affects the broader system (packages, services, etc.), prefer giving explicit commands and rationale rather than performing them automatically.



