-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Decorations Configuration                ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Variables/#decoration

hl.config({
    decoration = {
        active_opacity = 1,
        rounding       = 20,

        blur = {
            size   = 18,
            passes = 3, -- more passes = more resource intensive
            noise  = 0.0331,
        },

        shadow = {
            enabled      = true,
            range        = 30,    -- spread it further (softer edge)
            render_power = 2,     -- lower = less harsh falloff (2–2.5 is soft)
            color        = require("config.vars").colors.shadow,
            offset       = { 0, 4 }, -- tiny lift so it looks "floating"
        },
    },
})
