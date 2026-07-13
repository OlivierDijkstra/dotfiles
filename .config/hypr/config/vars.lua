-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                  Shared Variables (Lua)                     ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
--
-- In hyprlang, `$mainMod` etc. were global across all sourced files.
-- Lua modules have separate scopes, so shared values live here and each
-- module does `local vars = require("config.vars")`.

return {
    mainMod      = "SUPER",
    terminal     = "ghostty",
    applauncher  = "~/dotfiles/scripts/vicinae-toggle",
    fileManager  = "nautilus",
    resizeAmount = 150,

    -- NOTE: colors are HARDCODED here for the static-config migration pass.
    -- The `theme-mode` script still writes ~/.config/theme/colors.conf
    -- (hyprlang $vars), which a Lua config cannot `source`. Wiring theme-mode
    -- to emit a colors.lua and require()-ing it is the deferred follow-up.
    -- Current values mirror ~/.config/theme/colors.conf at migration time.
    colors = {
        active        = "rgb(D66A52)",
        activeAlt     = "rgb(E8B7A8)",
        background    = "rgb(1E1A17)",
        backgroundAlt = "rgb(25201C)",
    },
}
