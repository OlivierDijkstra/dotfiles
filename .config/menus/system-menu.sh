#!/bin/sh
# Simple script to run the system menu from waybar

cd "$(dirname "$0")"
# Use the full path to bun to ensure it's found
exec ghostty --title='System Menu' -e '/home/$(whoami)/.bun/bin/bun run system.tsx'