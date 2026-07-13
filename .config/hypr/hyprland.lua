-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃              CachyOS Hyprland Configuration (Lua)            ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
--
-- Migrated from the legacy hyprlang (.conf) setup; the .conf files have been
-- removed and Lua is now the single source of truth. Hyprland loads this file
-- (hyprland.lua) in preference to hyprland.conf when it exists.
--
-- package.path is set by Hyprland to <configdir>/?.lua, so `require("config.x")`
-- resolves to ~/.config/hypr/config/x.lua.

require("config.animations")
require("config.autostart")
require("config.decorations")
require("config.environment")
require("config.input")
require("config.keybinds")
require("config.monitor")
require("config.variables")
require("config.windowrules")
