-- Monitors --------------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- An empty output is the catch-all fallback: every display that has no
-- explicit rule uses its preferred mode, auto position and auto scale.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Examples -- run `hyprctl monitors` to get real names, then copy one of
-- these into conf/local.lua so your per-machine layout is not tracked:
--
-- hl.monitor({ output = "DP-1",  mode = "2560x1440@165", position = "0x0",    scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60",  position = "2560x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", disabled = true })

-- XWayland: stop old X11 apps rendering blurry on scaled displays.
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
