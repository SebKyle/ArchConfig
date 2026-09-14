-- Look and feel ---------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/

local c = require("conf.colors")

hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 2,
        border_size = 2,

        col = {
            -- Active border is a gradient between two pywal accents; the
            -- inactive one is a flat, dimmer colour so focus is obvious.
            active_border   = { colors = { c.border_active_a, c.border_active_b }, angle = 45 },
            inactive_border = c.border_inactive,
        },

        resize_on_border = true,   -- drag borders/gaps to resize
        allow_tearing    = true,   -- needed for the `immediate` rule on games
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 6,
        -- rounding_power must be between 2.0 and 10.0. 2.0 = a true circle,
        -- 4.0 = squircle. The old config had 1, which is out of range.
        rounding_power = 2.0,

        active_opacity   = 1.0,
        inactive_opacity = 0.92,   -- 0.5 was aggressive enough to hurt readability

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = c.shadow,
        },

        -- Blur has to be on globally for the bar / launcher / notification
        -- layer rules in conf/rules.lua to do anything. If you want the old
        -- zero-blur look (or you are on weak hardware), set enabled = false.
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            xray              = true,
            ignore_opacity    = true,
            noise             = 0.0117,
            vibrancy          = 0.1696,
            popups            = true,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = 0,     -- no anime mascot wallpaper
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        vrr                     = 2,     -- adaptive sync on fullscreen only
        focus_on_activate       = true,
        background_color        = c.color0,
        enable_swallow          = false,
        new_float_force_onscreen = 2,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },

    cursor = {
        inactive_timeout = 5,            -- hide the pointer after 5s idle
        hide_on_key_press = true,
    },

    render = {
        direct_scanout = 2,              -- auto: on for `game` content type
    },
})

-- Layouts ---------------------------------------------------------------
hl.config({
    dwindle = {
        preserve_split = true,
        smart_resizing = true,
        -- NOTE: `pseudotile` is no longer a dwindle option. Pseudotiling is
        -- now purely the hl.dsp.window.pseudo() dispatcher (SUPER+P).
    },
    master = {
        new_status = "master",
    },
})
