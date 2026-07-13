-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Variables Configuration                  ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

local colors = require("config.vars").colors

-- https://wiki.hypr.land/Configuring/Variables/#general
hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 10,
        border_size = 2,
        col = {
            active_border   = colors.active,
            inactive_border = colors.backgroundAlt,
        },
        layout = "dwindle", -- master|dwindle
        snap = {
            enabled = true,
        },
    },

    misc = {
        font_family            = "Geist",
        disable_hyprland_logo  = true,
        background_color       = colors.background,
        enable_swallow         = true,
        swallow_regex          = "^(zen-browser|btrfs-assistant.)$",
        focus_on_activate      = true,
        vrr                    = 3,
        animate_manual_resizes = true,
    },

    -- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        special_scale_factor = 0.8,
        preserve_split       = true,
    },

    -- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status           = "master",
        special_scale_factor = 0.8,
    },
})
