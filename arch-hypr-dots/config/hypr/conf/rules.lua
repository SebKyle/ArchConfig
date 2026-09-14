-- Window / layer / workspace rules --------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- Reminder: named rules are evaluated before anonymous ones, and within each
-- group the LAST match wins.

-- Sanity ----------------------------------------------------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Long-standing XWayland drag fix.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true,
              float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Float the usual suspects ----------------------------------------------
local floaters = {
    "^(pavucontrol)$",
    "^(org.pulseaudio.pavucontrol)$",
    "^(nm-connection-editor)$",
    "^(blueman-manager)$",
    "^(org.kde.polkit-kde-authentication-agent-1)$",
    "^(hyprpolkitagent)$",
    "^(xdg-desktop-portal-gtk)$",
    "^(org.kde.kdeconnect.*)$",
    "^(file-roller|org.gnome.FileRoller)$",
    "^(qt5ct|qt6ct)$",
    "^(kvantummanager)$",
    "^(nwg-look)$",
}
for _, cls in ipairs(floaters) do
    hl.window_rule({ match = { class = cls }, float = true, center = true })
end

-- Dolphin's own dialogs (copy progress, properties, open-with) float; the
-- main window stays tiled.
hl.window_rule({
    match = { class = "^(org.kde.dolphin)$", title = "^(Copying|Moving|Deleting|Properties).*" },
    float = true, center = true, size = { 600, 400 },
})

-- Picture-in-picture floats, pins and stays out of the way.
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture-in-Picture)$" },
    float = true, pin = true, size = { 480, 270 },
    move  = { "monitor_w-500", "monitor_h-300" },
    no_blur = true,
})

-- Opacity ---------------------------------------------------------------
-- Terminals and the file manager get a little translucency; everything that
-- shows images or video stays fully opaque so colours are not muddied.
hl.window_rule({ match = { class = "^(kitty)$" },        opacity = "0.90 0.80" })
hl.window_rule({ match = { class = "^(org.kde.dolphin)$" }, opacity = "0.95 0.88" })

local opaque = {
    "^(firefox)$", "^(zen)$", "^(chromium)$", "^(google-chrome)$",
    "^(mpv)$", "^(imv)$", "^(vlc)$", "^(org.kde.gwenview)$",
    "^(steam)$", "^(steam_app_.*)$", "^(lutris)$", "^(obs)$",
    "^(Gimp.*)$", "^(org.kde.krita)$", "^(code|code-oss|Code)$",
}
for _, cls in ipairs(opaque) do
    hl.window_rule({ match = { class = cls }, opacity = "1.0 override 1.0 override 1.0 override" })
end

-- Games: allow tearing and skip the compositor niceties -----------------
hl.window_rule({
    match = { class = "^(steam_app_.*)$" },
    immediate = true, no_blur = true, no_shadow = true, no_anim = true,
    content = "game",
})

-- Idle inhibition while something is fullscreen (video, games).
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "fullscreen" })

-- No shadow on tiled windows -- shadows are for floating ones.
hl.window_rule({ match = { float = false }, no_shadow = true })

-- Layer rules -----------------------------------------------------------
-- These require decoration.blur.enabled = true in conf/looks.lua.
hl.layer_rule({ match = { namespace = "^waybar$" },   blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^rofi$" },     blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^swaync-notification-window$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^swaync-control-center$" },      blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^selection$" }, no_anim = true })
hl.layer_rule({ match = { namespace = "^hyprpicker$" }, no_anim = true })

-- Workspace rules -------------------------------------------------------
-- "Smart gaps": a lone tiled window on a workspace gets no gap and no border.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "smart-gaps-tiled",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0, rounding = 0,
})
hl.window_rule({
    name  = "smart-gaps-fullscreen",
    match = { float = false, workspace = "f[1]" },
    border_size = 0, rounding = 0,
})
