-- Keybindings -----------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- Dispatchers:  https://wiki.hypr.land/Configuring/Basics/Dispatchers/
--
-- Run `hyprctl binds` to list everything together with its description.

local mod  = "SUPER"
local hypr = (os.getenv("HOME") or "") .. "/.config/hypr"

-- Programs --------------------------------------------------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"
local runner      = "rofi -show run"
local windowList  = "rofi -show window"
local clipboard   = "cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy"
local powerMenu   = hypr .. "/scripts/powermenu.sh"
local wallPicker  = hypr .. "/scripts/wallpaper-picker.sh"
local lock        = "pidof hyprlock || hyprlock"

-- Small wrapper so every bind carries a description for `hyprctl binds`.
local function bind(keys, dispatcher, desc, flags)
    flags = flags or {}
    flags.description = desc
    return hl.bind(keys, dispatcher, flags)
end

-- Applications ----------------------------------------------------------
bind(mod .. " + T",         hl.dsp.exec_cmd(terminal),    "Terminal")
bind(mod .. " + RETURN",    hl.dsp.exec_cmd(terminal),    "Terminal")
bind(mod .. " + F",         hl.dsp.exec_cmd(fileManager), "File manager")
bind(mod .. " + R",         hl.dsp.exec_cmd(menu),        "App launcher")
bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd(runner),      "Run a command")
bind(mod .. " + TAB",       hl.dsp.exec_cmd(windowList),  "Switch window")

-- Session ---------------------------------------------------------------
bind("CTRL + Q",         hl.dsp.window.close(),      "Close window")
bind(mod .. " + Q",      hl.dsp.window.close(),      "Close window")
bind(mod .. " + L",      hl.dsp.exec_cmd(lock),      "Lock screen")
bind(mod .. " + ESCAPE", hl.dsp.exec_cmd(powerMenu), "Power menu")

-- Graceful exit. hyprshutdown does an ordered teardown; hl.dsp.exit() is the
-- blunt fallback. If you launch through uwsm, run `uwsm stop` instead of
-- either -- exiting Hyprland directly pulls the session out from under its
-- clients.
bind(mod .. " + SHIFT + M",
     hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
     "Exit Hyprland")

-- Window management -----------------------------------------------------
bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }),        "Toggle floating")
bind(mod .. " + P",         hl.dsp.window.pseudo(),                            "Toggle pseudotile")
bind(mod .. " + J",         hl.dsp.layout("togglesplit"),                      "Toggle split (dwindle)")
bind(mod .. " + M",         hl.dsp.window.fullscreen({ mode = "maximized" }),  "Maximise")
bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind(mod .. " + C",         hl.dsp.window.center(),                            "Centre window")
bind(mod .. " + SHIFT + P", hl.dsp.window.pin(),                               "Pin window on all workspaces")

-- Focus -----------------------------------------------------------------
bind(mod .. " + left",  hl.dsp.focus({ direction = "l" }), "Focus left")
bind(mod .. " + right", hl.dsp.focus({ direction = "r" }), "Focus right")
bind(mod .. " + up",    hl.dsp.focus({ direction = "u" }), "Focus up")
bind(mod .. " + down",  hl.dsp.focus({ direction = "d" }), "Focus down")

-- Move windows ----------------------------------------------------------
bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }), "Move window left")
bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), "Move window right")
bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }), "Move window up")
bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }), "Move window down")

-- Resize mode (submap) --------------------------------------------------
-- SUPER+S, then arrow keys to resize, ESC or ENTER to leave.
bind(mod .. " + S", hl.dsp.submap("resize"), "Resize mode")
hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x =  40, y =   0, relative = true }), { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -40, y =   0, relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x =   0, y = -40, relative = true }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x =   0, y =  40, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("RETURN", hl.dsp.submap("reset"))
end)

-- Workspaces ------------------------------------------------------------
for i = 1, 10 do
    local key = i % 10               -- workspace 10 lives on the 0 key
    bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       "Workspace " .. i)
    bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Move to workspace " .. i)
end

bind(mod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")
bind(mod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")

-- Scratchpad ------------------------------------------------------------
bind(mod .. " + A",         hl.dsp.workspace.toggle_special("magic"),            "Toggle scratchpad")
bind(mod .. " + SHIFT + A", hl.dsp.window.move({ workspace = "special:magic" }), "Send to scratchpad")

-- Mouse binds -----------------------------------------------------------
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots -----------------------------------------------------------
bind("PRINT",               hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"),    "Screenshot region to clipboard")
bind("SHIFT + PRINT",       hl.dsp.exec_cmd("hyprshot -m output"),                     "Screenshot monitor")
bind(mod .. " + PRINT",     hl.dsp.exec_cmd("hyprshot -m window"),                     "Screenshot window")
bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --raw | swappy -f -"), "Screenshot and annotate")

-- Utilities -------------------------------------------------------------
bind(mod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"),   "Notification centre")
bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -d -sw"),   "Toggle do-not-disturb")
bind(mod .. " + VBAR",      hl.dsp.exec_cmd(clipboard),                "Clipboard history")
bind(mod .. " + W",         hl.dsp.exec_cmd(wallPicker),               "Change wallpaper (pywal)")
bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"),"Reload Waybar")
bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"),          "Colour picker")

-- Media and hardware keys -----------------------------------------------
-- `locked = true` keeps these working while hyprlock is on screen.
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
