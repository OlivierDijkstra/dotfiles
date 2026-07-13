-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Windowrules Configuration                ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Window-Rules/
--
-- Match keys (class/title/float/fullscreen/pin/workspace) and rule props
-- (float/stay_focused/center/size/move/pin/rounding/opacity/border_color/
-- border_size) mirror the new hyprlang `match:` syntax 1:1. Verify on first
-- reload — these field names weren't covered by the converter's test suite.

local colors = require("config.vars").colors

-- ── System & File Dialogs ──────────────────────────────────────────────────

hl.window_rule({
    match = { title = "^(Save File|Open File|Open Files|Open Folder|Save Files|termfilechooser)$" },
    float = true,
    stay_focused = true,
})

hl.window_rule({ match = { class = "^(hyprpolkitagent)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(zenity)$" },          float = true })

-- Desktop portals
hl.window_rule({
    match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$" },
    float = true,
})

-- ── Application Launchers ───────────────────────────────────────────────────

hl.window_rule({ match = { class = "^(rofi)$" }, float = true })

-- ── Media & Picture-in-Picture ──────────────────────────────────────────────

hl.window_rule({
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    size  = "960 540",
    move  = "100%-w-30 100%-h-30",
})

-- LibreWolf PiP specific
hl.window_rule({
    match = { class = "^(LibreWolf)$", title = "^(Picture-in-Picture)$" },
    float = true,
})

-- Media applications
hl.window_rule({
    match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" },
    float = true,
    move  = "100%-w-30 100%-h-30",
    size  = "960 540",
})
hl.window_rule({ match = { title = "^(danmufloat)$" },           pin = true })
hl.window_rule({ match = { title = "^(danmufloat|termfloat)$" }, rounding = 12 })

-- ── Application-Specific Rules ──────────────────────────────────────────────

hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)" }, float = true }) -- audio control
hl.window_rule({ match = { class = "^(blueman-manager)$" },           float = true }) -- bluetooth manager
hl.window_rule({ match = { class = "^(CachyOSHello)$" },              float = true }) -- system tools

-- Steam updater
hl.window_rule({
    match = { class = "^()$", title = "^(Steam - Self Updater)$" },
    float = true,
})

-- Application opacity settings
hl.window_rule({ match = { class = "^(ghostty)$" },  opacity = 0.95 })
hl.window_rule({ match = { class = "^(vesktop)$" },  opacity = 0.95 })
hl.window_rule({ match = { class = "^(zen)$" },      opacity = 1 })
hl.window_rule({ match = { class = "^(cursor)$" },   opacity = 0.95 })

-- ── Workspace-Specific Rules ────────────────────────────────────────────────

-- Floating window decorations on workspaces 1-10
hl.window_rule({
    match = { float = true, workspace = "w[fv1-10]" },
    border_color = colors.active,
})

-- Tiling window decorations on workspaces 1-10
hl.window_rule({
    match = { float = false, workspace = "f[1-10]" },
    border_size = 2,
    rounding    = 12,
})

-- ── Workspace Rules ─────────────────────────────────────────────────────────
-- https://wiki.hypr.land/Configuring/Workspace-Rules/  (smart gaps)

hl.workspace_rule({ workspace = "w[tv1-10]", gaps_out = 10, gaps_in = 6 })
hl.workspace_rule({ workspace = "f[1]",      gaps_out = 10, gaps_in = 6 })

-- ── Layer Rules ─────────────────────────────────────────────────────────────

-- Vicinae launcher
hl.layer_rule({ match = { namespace = "vicinae" }, blur = true })
hl.layer_rule({ match = { namespace = "vicinae" }, ignore_alpha = 0 })

-- Wallpaper
hl.layer_rule({ match = { namespace = "wallpaper" }, animation = "fade 50%" })
