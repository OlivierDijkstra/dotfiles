# CachyOS Gaming Reference

Source:
- https://wiki.cachyos.org/configuration/gaming/
- Upstream content source: https://raw.githubusercontent.com/CachyOS/wiki/next/src/content/docs/configuration/gaming.mdx
- Retrieved: 2026-03-04

## Table of Contents

1. Prerequisites and Packages
2. Proton-CachyOS
3. Launch Option Composition
4. Proton Environment Variables
5. Lutris and Heroic Setup for proton-cachyos
6. Anti-Cheat and proton-cachyos-slr
7. Wine-CachyOS and wine-cachyos-opt
8. Steam FAQ and Operational Tips
9. Lutris Field Mapping
10. Performance and Miscellaneous Tuning
11. Known Limitations

## 1. Prerequisites and Packages

- Ensure GPU drivers are installed and functioning before gaming setup.
- CachyOS groups gaming dependencies into meta packages:
```sh
sudo pacman -S cachyos-gaming-meta
sudo pacman -S cachyos-gaming-applications
```
- `cachyos-gaming-applications` includes tools and launchers such as Gamescope, Goverlay, MangoHud, Steam, Heroic, and Lutris.
- CachyOS Hello can install both package groups via Apps/Tweaks.

## 2. Proton-CachyOS

Proton-CachyOS is based on Proton bleeding-edge and includes:
- Wine-staging patches
- Wine Fullscreen FSR
- Video/audio codec coverage for cutscenes
- UMU launcher support and UMU-Protonfixes
- Early hotfixes/workarounds

NTSync note:
- Not enabled by default
- Enable with:
```sh
PROTON_USE_NTSYNC=1
```

## 3. Launch Option Composition

Use this structure:
```bash
<env variables> <wrappers> %command% <application arguments>
```

Definitions:
- Env variables: `VARIABLE=value`
- Wrappers: e.g. `mangohud --dlsym`, `gamescope ... --`
- `%command%`: keep exactly as `%command%`
- Application arguments: game-specific flags after `%command%`

Example complete chain:
```bash
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 prime-run game-performance %command% -dx11
```

Important:
- Do not place multiple `%command%` tokens in one launch option.
- Everything after the first `%command%` is treated as game args.

## 4. Proton Environment Variables

### Graphics and Upscaling

NVIDIA and DLSS:
- `PROTON_DLSS_UPGRADE=1`
- `PROTON_DLSS_INDICATOR=1`
- `PROTON_NVIDIA_LIBS=1` (PhysX/CUDA libraries; not needed for DLSS/RT itself)

Advanced NVIDIA controls:
- `PROTON_NVIDIA_NVCUDA=1`
- `PROTON_NVIDIA_NVENC=1`
- `PROTON_NVIDIA_NVML=1`
- `PROTON_NVIDIA_NVOPTIX=1`
- `PROTON_NVIDIA_LIBS_NO_32BIT=1` (can mitigate RTX 4000+ performance issues)

AMD and Intel upscaling:
- `PROTON_FSR4_UPGRADE=1`
- `PROTON_FSR4_RDNA3_UPGRADE=1`
- `PROTON_XESS_UPGRADE=1`

### Display and HDR

- `PROTON_ENABLE_WAYLAND=1`
  - Benefits: HDR without Gamescope, lower latency, better pacing
  - Caveats: experimental, breaks Steam Overlay
- `PROTON_NO_WM_DECORATION=1`
  - Can fix borderless fullscreen and click-through issues
- `PROTON_ENABLE_HDR=1`
  - Requires Gamescope `--hdr-enabled` or `PROTON_ENABLE_WAYLAND=1`
  - On NVIDIA add `ENABLE_HDR_WSI=1` and install `vk-hdr-layer-kwin6-git`
  - Extra platform setup may be required (Arch Wiki HDR monitor support)

### Performance and Caching

- `PROTON_USE_NTSYNC=1`
  - Experimental; may improve smoothness in some games
  - Verify with `lsof /dev/ntsync` (MangoHud may report incorrectly)
- `PROTON_LOCAL_SHADER_CACHE=1`
  - Isolates shader cache per game
  - Does not precompile shaders ahead of time
- `PROTON_ENABLE_MEDIACONV=1`
  - Primarily for testing
- `ENABLE_LAYER_MESA_ANTI_LAG=1`
  - Enables AMD Anti-Lag

### Input and Compatibility

- `PROTON_PREFER_SDL=1` for controller detection issues
- `PROTON_NO_STEAMINPUT=1` for Wayland controller/gamepad issues
- `PROTON_ENABLE_XALIA=1` for accessibility support

## 5. Lutris and Heroic Setup for proton-cachyos

This section applies to `proton-cachyos` (native, non-SLR).

Prerequisite:
```sh
sudo pacman -S cachyos/umu-launcher
```

Lutris (global or per-game runner options):
- Wine version: `proton-cachyos`
- Use System winetricks: disabled
- Enable DXVK: enabled
- Disable Lutris Runtime: enabled
- Prefer system libraries: enabled
- Environment variables table:
  - `UMU_RUNTIME_UPDATE=0` (optional; do not use for SLR-based Proton builds)
  - `PROTON_VERB=waitforexitandrun` (optional; helps protonfixes with matching GAMEID)

Heroic:
- Open game configuration
- Set Wine version to Proton `proton-cachyos`

## 6. Anti-Cheat and proton-cachyos-slr

For Easy Anti-Cheat and BattlEye login/server issues, prefer `proton-cachyos-slr`.

Install methods:

With pacman:
```sh
sudo pacman -S proton-cachyos-slr
```

With ProtonUp-Qt:
```sh
sudo pacman -S protonup-qt
```
- In ProtonUp-Qt, choose `x86-64_v3` when CPU supports AVX2; otherwise `x86-64`.
- Restart Steam afterwards.

Manual advanced install:
- Download release tarball from CachyOS proton-cachyos releases
- Extract into `~/.steam/steam/compatibilitytools.d/`
- Restart Steam

## 7. Wine-CachyOS and wine-cachyos-opt

- Wine-CachyOS is Proton-CachyOS Wine core provided standalone.
- Intended primarily for gaming.
- Package variants:
  - `wine-cachyos`: replaces system wine/wine-staging
  - `wine-cachyos-opt`: installed in `/opt` so multiple wine versions can coexist

Useful variables:
- `WINE_WMCLASS="<name>"`
- `WINEUSERSANDBOX=1`
- `WINE_NO_WM_DECORATION=1`
- `WINE_PREFER_SDL_INPUT=1`

Standalone `wine-cachyos-opt` usage:
```sh
/opt/wine-cachyos/bin/wine <app-or-installer>
```

Strict environment setup example:
```sh
export PATH="/opt/wine-cachyos/bin/:$PATH"
export WINEDLLPATH="/opt/wine-cachyos/lib/wine:/opt/wine-cachyos/lib32/wine:$WINEDLLPATH"
export LD_LIBRARY_PATH="/opt/wine-cachyos/lib/:/opt/wine-cachyos/lib32/:$LD_LIBRARY_PATH"
```

Winetricks with `wine-cachyos-opt`:
```sh
WINE=/opt/wine-cachyos/bin/wine WINEPREFIX=<prefix> winetricks <verb>
```

## 8. Steam FAQ and Operational Tips

### Proton version selection guidance

- `Proton 10.x`: stable baseline from Valve
- `Proton Experimental`: newest fixes for recent/problematic titles
- `proton-cachyos-slr`: recommended CachyOS-maintained option with QoL fixes and anti-cheat focus
- `proton-cachyos`: native non-SLR variant; use only if you understand tradeoffs
- `Proton-GE`: useful supplemental custom build
- `Proton 9.0.4 or lower`: for games requiring older versions

### Fix stuttering from Steam Game Recorder

```sh
LD_PRELOAD="" %command%
```

Caveat:
- Can disable Steam Overlay.

### Capture Proton logs

Enable logging:
```sh
PROTON_LOG=1 %command%
```

Output:
- `~/steam-<AppID>.log`

Custom log directory:
```sh
PROTON_LOG=1 PROTON_LOG_DIR=/home/<user>/steam-logs %command%
```

### Shader pre-caching guidance

- With Proton-CachyOS/GE/EM, Steam shader pre-caching may be unnecessary for many users.
- If disabling Steam shader pre-caching, increase local shader cache size to reduce recompilation churn.

Steam settings to disable:
- Allow background processing of Vulkan shaders
- Enable Shader Pre-caching

### NTFS partition caveat

- Proton on NTFS is unsupported by Valve and can be unpredictable.
- If user insists, point to Valve Proton unofficial NTFS guide and explain risk clearly.

## 9. Lutris Field Mapping

Do not mix field types in Lutris:
- Launch args (for example `-dx11`, `-fullscreen`) go to `Game options > Arguments`
- Wrappers (for example `mangohud --dlsym`, `game-performance`) go to `System options > Command prefix`
- Environment variables go to `System options > Environment variables`
- In env var key field, do not include `=`

## 10. Performance and Miscellaneous Tuning

### Avoid gamemode + ananicy-cpp combination

- They can conflict over process niceness.
- Recommended command to stop ananicy-cpp:
```sh
systemctl stop ananicy-cpp
```

### game-performance wrapper

- `game-performance` uses `power-profiles-daemon` to raise performance profile while game runs.
- On exit, previous profile is restored.
- On Intel `intel_pstate`, behavior is adjusted via EPP/EPB while governor may remain powersave.

Add wrapper in launchers:

Steam launch options:
```sh
game-performance %command%
```

Heroic wrapper field:
```sh
game-performance
```

Lutris command prefix:
```sh
game-performance
```

### Increase shader cache size

Create environment file:
```sh
mkdir -p ~/.config/environment.d
touch ~/.config/environment.d/gaming.conf
```

AMD example:
```sh
AMD_VULKAN_ICD=RADV
MESA_SHADER_CACHE_MAX_SIZE=12G
```

NVIDIA example:
```sh
__GL_SHADER_DISK_CACHE_SIZE=12000000000
```

Restart system after changes.

### Force latest DLSS preset with dlss-swapper

Steam:
```sh
dlss-swapper %command%
```

Heroic/Lutris wrapper:
```sh
dlss-swapper
```

Fallback:
- Replace `nvngx_dlss.dll` manually and use `dlss-swapper-dll` if wrapper flow fails.

### Ray tracing references

Use Arch Wiki hardware ray tracing docs:
- NVIDIA
- AMD
- Intel

## 11. Known Limitations

- NVIDIA DX12 performance drops on Linux are reported as a driver-side issue; no known universal workaround in guide.
- Optimization gains vary by title and hardware; do not present tuning as guaranteed major FPS uplift.
