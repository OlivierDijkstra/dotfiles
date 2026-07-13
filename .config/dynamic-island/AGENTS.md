## Skills

Always automatically before working on code check what skills are available, and automatically load ones you think are usefull for that specific task.

## File Editing

- CRITICAL: NEVER use sed, awk, or bash commands to edit files. ALWAYS use the Edit tool.**
- NEVER fall back to sed/awk/bash for file edits. Every sed command requires manual user approval and is frustrating.

## Common Mistakes to Avoid

- **Load skills FIRST** — Before writing code, check and load relevant skills. Think before acting.
- **No ugly workarounds** — Find the proper pattern, not a quick hack that "works".
- **Do exactly what's asked** — Don't add unrequested changes. Scope changes precisely to what was requested.

## Repo Workflow

- Use `make lint` in `/home/oli/dotfiles/.config/dynamic-island` for QML linting. It wraps the local Qt binary path for `qmllint`.

Less code is better code.
