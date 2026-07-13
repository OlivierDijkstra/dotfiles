-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                  Shared Variables (Lua)                     ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
--
-- In hyprlang, `$mainMod` etc. were global across all sourced files.
-- Lua modules have separate scopes, so shared values live here and each
-- module does `local vars = require("config.vars")`.

local palette = require("config.palette")

return {
    mainMod      = "SUPER",
    terminal     = "ghostty",
    applauncher  = "~/dotfiles/scripts/vicinae-toggle",
    fileManager  = "nautilus",
    resizeAmount = 150,

    colors = {
        active        = palette.accent,
        activeAlt     = palette.selected,
        background    = palette.surface1,
        backgroundAlt = palette.borderStrong,
        border        = palette.border,
        foreground    = palette.foreground,
        muted         = palette.muted,
        shadow        = palette.shadow,
    },
}
