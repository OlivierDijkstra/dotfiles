-- Generated from .config/theme/palette.json by scripts/generate-theme.
local palettes = {
    light = {
        surface1 = "#FAFAFA",
        surface2 = "#FCFCFC",
        surface3 = "#FFFFFF",
        surface4 = "#FFFFFF",
        surface5 = "#FFFFFF",
        surface6 = "#FFFFFF",
        surface7 = "#FFFFFF",
        surface8 = "#FFFFFF",
        foreground = "#171717",
        muted = "#737373",
        border = "#E5E5E5",
        borderStrong = "#D4D4D4",
        hover = "#F5F5F5",
        selected = "#E5E5E5",
        accent = "#171717",
        accentForeground = "#FFFFFF",
        shadow = "rgba(0000001A)",
        red = "#B84E4E",
        green = "#3F7D58",
        yellow = "#916622",
        blue = "#3F6F9F",
        magenta = "#7C5E92",
        cyan = "#3E7B7D",
    },
    dark = {
        surface1 = "#171717",
        surface2 = "#1E1E1E",
        surface3 = "#252525",
        surface4 = "#2C2C2C",
        surface5 = "#333333",
        surface6 = "#3A3A3A",
        surface7 = "#414141",
        surface8 = "#484848",
        foreground = "#F5F5F5",
        muted = "#A3A3A3",
        border = "#333333",
        borderStrong = "#484848",
        hover = "#2C2C2C",
        selected = "#414141",
        accent = "#F5F5F5",
        accentForeground = "#171717",
        shadow = "rgba(0000004D)",
        red = "#E57373",
        green = "#76B78B",
        yellow = "#D2A85B",
        blue = "#7CA9D8",
        magenta = "#A994C3",
        cyan = "#73B5B7",
    },
}

local mode = "dark"
local home = os.getenv("HOME") or "/home/oli"
local state = io.open(home .. "/.local/state/theme-mode/state.json", "r")

if state then
    local contents = state:read("*a")
    state:close()
    mode = contents:match('"applied"%s*:%s*"(light)"') and "light" or "dark"
end

return palettes[mode]
