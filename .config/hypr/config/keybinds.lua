-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Keybinds                            ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local vars         = require("config.vars")
local mainMod      = vars.mainMod
local resizeAmount = vars.resizeAmount

hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(vars.applauncher))

hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + M",         hl.dsp.layout("togglesplit"))

-- Window movement within workspace (vim-style keys)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Window movement within workspace (arrow keys)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Focus movement within workspace (vim-style keys)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Focus movement within workspace (arrow keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Window resizing (vim-style keys)
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -resizeAmount, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = resizeAmount,  y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -resizeAmount, relative = true }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = resizeAmount,  relative = true }))

-- Window resizing (arrow keys)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -resizeAmount, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = resizeAmount,  y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x = 0, y = -resizeAmount, relative = true }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x = 0, y = resizeAmount,  relative = true }))

-- Monitor focus and window movement
hl.bind(mainMod .. " + SHIFT + W",       hl.dsp.focus({ monitor = 0 }))
hl.bind(mainMod .. " + SHIFT + ALT + W", hl.dsp.window.move({ monitor = "0" }))
hl.bind(mainMod .. " + SHIFT + E",       hl.dsp.focus({ monitor = 1 }))
hl.bind(mainMod .. " + SHIFT + ALT + E", hl.dsp.window.move({ monitor = "1" }))
hl.bind(mainMod .. " + SHIFT + R",       hl.dsp.focus({ monitor = 2 }))
hl.bind(mainMod .. " + SHIFT + ALT + R", hl.dsp.window.move({ monitor = "2" }))

-- Switch workspaces (mainMod + [0-9]) and move active window (mainMod + SHIFT + [0-9])
-- key 0 maps to workspace 10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m output -m DP-1 --clipboard-only"))

-- Screen recording (toggle start/stop)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/dotfiles/scripts/screenrecord"))

-- LG dual-mode monitor helper (4K240 <-> 1080p480)
-- The helper uses `hyprctl eval` so runtime changes work with Lua configs.
hl.bind(mainMod .. " + CTRL + M",         hl.dsp.exec_cmd("~/dotfiles/scripts/hypr-dual-mode toggle"))
hl.bind(mainMod .. " + CTRL + SHIFT + M", hl.dsp.exec_cmd("~/dotfiles/scripts/hypr-dual-mode sync"))
hl.bind(mainMod .. " + CTRL + ALT + M",   hl.dsp.exec_cmd("~/dotfiles/scripts/hypr-dual-mode status"))

-- Volume control (fire on key release, like the old bindr)
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { release = true })
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { release = true })

-- https://wiki.hypr.land/Configuring/Binds/#binds-section
hl.config({
    binds = {
        allow_workspace_cycles            = true,
        workspace_back_and_forth          = true,
        workspace_center_on               = 1,
        movefocus_cycles_fullscreen       = true,
        window_direction_monitor_fallback = true,
    },
})
