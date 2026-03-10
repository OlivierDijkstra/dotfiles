---
name: cachyos-gaming
description: Configure and troubleshoot gaming on CachyOS using official guide patterns for Steam, Lutris, and Heroic with Proton-CachyOS, proton-cachyos-slr, and Wine-CachyOS. Use for package setup, launch option composition, Proton environment variable tuning, anti-cheat compatibility, shader caching, and performance troubleshooting on Arch-based CachyOS systems.
---

# CachyOS Gaming

## Overview

Use this skill to apply the CachyOS gaming guide in a safe, reproducible order with minimal guesswork. Focus on compatibility first, then targeted tuning; do not promise fixed FPS gains.

## Workflow

1. Confirm context before recommending changes:
- GPU vendor (`AMD`, `NVIDIA`, `Intel`)
- Launcher and runner (`Steam`, `Lutris`, `Heroic`, native game)
- Proton/Wine version currently used
- Anti-cheat requirement (`EAC`, `BattlEye`, none)
- Desktop stack details relevant to HDR (`Wayland`, `Gamescope`, `KWin`)
- Whether user wants compatibility-first defaults or aggressive tuning

2. Apply baseline setup:
- Install core gaming packages with `pacman`:
```sh
sudo pacman -S cachyos-gaming-meta cachyos-gaming-applications
```
- If user installs via GUI, mention CachyOS Hello can install both package groups.

3. Choose the runner by compatibility target:
- Prefer `proton-cachyos-slr` when anti-cheat or launcher compatibility is important.
- Use `Proton Experimental` for very new games when Proton stable fails.
- Use `Proton 10.x` (or current stable) for known-good titles.
- Use native `proton-cachyos` only if user understands non-SLR tradeoffs and can fall back.

4. Build launch options correctly:
- Use this order exactly:
```bash
ENV_VAR=value wrapper --args %command% game_args
```
- Never place multiple `%command%` tokens in one launch string.

5. Apply launcher-specific configuration:
- Steam: launch options and per-game Proton selection.
- Lutris: split options across `Arguments`, `Command prefix`, and `Environment variables`.
- Heroic: set wrapper commands separately from game arguments.

6. Add only targeted environment variables:
- Choose variables by use case (HDR, cache behavior, controller issues, NTSync).
- Explain tradeoffs (for example `PROTON_ENABLE_WAYLAND=1` can break Steam Overlay).

7. Validate with evidence:
- For Proton logs: `PROTON_LOG=1 %command%`.
- For NTSync status: `lsof /dev/ntsync`.
- If symptoms persist, step back to conservative defaults and reintroduce one tweak at a time.

## Decision Rules

- Compatibility-first default:
  - `proton-cachyos-slr`
  - No experimental env vars unless needed
  - Minimal wrapper chain
- Performance-tuning default:
  - Keep compatibility baseline working first
  - Add one optimization at a time (for example `game-performance`, cache sizing, DLSS swapper)
  - Re-test after each change
- Known caveats:
  - Do not combine `gamemode` and `ananicy-cpp`
  - Proton on NTFS is unsupported by Valve and may behave unpredictably
  - NVIDIA DX12 Linux performance drop is currently driver-related and not CachyOS-specific

## Reference Files

Read only what is needed:

- For full guide content, commands, launcher flows, env vars, and caveats:
  - [references/cachyos-gaming-reference.md](references/cachyos-gaming-reference.md)

## Response Style

- Provide commands and launcher UI steps in the exact order the user should apply.
- State what to verify after each change.
- If a tweak is experimental or breaks another feature, call that out clearly.
