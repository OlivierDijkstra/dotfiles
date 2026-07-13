-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Autostart Configuration                  ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- exec-once equivalents: hl.on("hyprland.start", ...) fires once at launch.

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("mako")
    hl.exec_cmd("/usr/bin/vicinae server --replace")
    hl.exec_cmd("~/dotfiles/scripts/theme-mode sync --quiet")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- image data

    -- Slow app launch fix
    hl.exec_cmd("systemctl --user import-environment")
    hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null")
    hl.exec_cmd("dbus-update-activation-environment --systemd")

    -- Keep LG dual-mode profile synced automatically in the background.
    hl.exec_cmd("~/dotfiles/scripts/hypr-dual-mode watch")
end)
