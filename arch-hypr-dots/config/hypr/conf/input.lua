-- Input -----------------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,     -- -1.0 .. 1.0, 0 = untouched
        repeat_rate  = 35,
        repeat_delay = 400,

        numlock_by_default = true,

        touchpad = {
            natural_scroll      = true,
            disable_while_typing = true,
            tap_to_click        = true,
            drag_lock           = 1,
            scroll_factor       = 0.6,
        },
    },

    binds = {
        workspace_back_and_forth = true,   -- SUPER+<current ws> goes back
        allow_workspace_cycles   = true,
        drag_threshold           = 10,
    },
})

-- Gestures --------------------------------------------------------------
-- `gestures { workspace_swipe = ... }` was removed in favour of hl.gesture().
-- Three fingers left/right switches workspace. Delete this block to get the
-- old `workspace_swipe = false` behaviour.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Per-device overrides go here. Get names from `hyprctl devices`, e.g.
-- hl.device({ name = "my-mouse", sensitivity = -0.5 })
