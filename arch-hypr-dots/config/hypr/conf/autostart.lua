-- Autostart -------------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- The old `exec-once =` lines become hl.exec_cmd() calls inside a
-- "hyprland.start" handler. Note hl.exec_cmd (plain) here, not
-- hl.dsp.exec_cmd -- the hl.dsp.* variants build dispatcher tables for binds.

-- Set to true if you want the lock screen up the moment you log in.
-- The original config did this; hypridle already locks on idle and before
-- sleep, so leaving it false is usually what you want.
local LOCK_ON_LOGIN = false

hl.on("hyprland.start", function()
    -- Make sure portals and anything dbus-activated see the Wayland session.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")

    -- Authentication agent (needed for GUI password prompts).
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Shell components.
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")

    -- Clipboard history for SUPER+| (needs wl-clipboard + cliphist).
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Tray helpers.
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("udiskie --tray")

    -- Re-apply the saved pywal colours so the bar, launcher and notification
    -- centre come up in the same palette as the wallpaper.
    hl.exec_cmd((os.getenv("HOME") or "") .. "/.config/hypr/scripts/setwall.sh --restore")

    if LOCK_ON_LOGIN then
        hl.exec_cmd("hyprlock")
    end
end)
