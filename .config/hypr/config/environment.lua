-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                   Environment Configuration                 ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("GTK_USE_PORTAL", "1")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_CURSOR_SIZE", "24")
hl.env("TERMCMD", "ghostty")

-- Theme mode is managed centrally by ~/dotfiles/scripts/theme-mode.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") -- for QT6 apps

hl.env("GDK_BACKEND", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Force Zed to use Vulkan to prevent fallback to software rendering (llvmpipe)
hl.env("ZED_BACKEND", "vulkan")

-- env = GDK_SCALE, 1.25  -- GDK Scaling Factor (uncomment if needed)
