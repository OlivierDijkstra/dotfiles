-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                     Monitor Configuration                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Monitors/

hl.monitor({
    output        = "DP-1",
    mode          = "preferred",
    position      = "auto",
    scale         = 1.2,
    -- HDR is disabled: on this NVIDIA + Hyprland setup, enabling cm="hdr"
    -- breaks wlroots screencopy (grim/hyprshot/wf-recorder/screen-share all
    -- capture a stale frame from the wrong workspace). Re-enable the block
    -- below once HDR screencopy is fixed upstream.
    -- bitdepth      = 10,
    -- cm            = "hdr",
    -- sdrbrightness = 2.0,
    -- sdrsaturation = 1.0,
})

-- Unscale XWayland (uncomment GDK_SCALE in environment.lua if you scale apps)
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- NOTE: the LG dual-mode helper (~/dotfiles/scripts/hypr-dual-mode) drives
-- modes at runtime via `hyprctl eval "hl.monitor({...})"` (`hyprctl keyword` is
-- rejected under a Lua config). It also keeps HDR off by default; if you
-- re-enable the HDR block above, also set HYPR_DUALMODE_HDR=1 for that script
-- so mode switches don't drop the color settings.
