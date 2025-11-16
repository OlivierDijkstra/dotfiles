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

### Agent Best Practices
- **Explain changes briefly**: Summarize what was modified and why.
- **Avoid destructive actions**: Do not delete or overwrite files unless explicitly requested.
- **Check for cleanliness**: Aim to keep `git status` clean after changes, unless work-in-progress is expected.


