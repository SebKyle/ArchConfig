--  ╔══════════════════════════════════════════════════════════════════╗
--  ║  Hyprland — main entry point                                     ║
--  ║  Config format: Lua (Hyprland >= 0.55). hyprlang is deprecated.  ║
--  ║  Docs: https://wiki.hypr.land/Configuring/Start/                 ║
--  ╚══════════════════════════════════════════════════════════════════╝
--
--  Everything lives in conf/. Each require() is its own Lua scope, so an
--  error in one file will not stop the others from loading.
--
--  Load order matters: colors must come before looks, and binds last so
--  that the programs table is populated.

require("conf.env")        -- environment variables
require("conf.monitors")   -- displays
require("conf.looks")      -- general / decoration / blur / shadow
require("conf.animations") -- curves + animation tree
require("conf.input")      -- keyboard, mouse, touchpad, gestures
require("conf.rules")      -- window + layer + workspace rules
require("conf.binds")      -- keybindings
require("conf.autostart")  -- exec-once equivalents

-- Drop a conf/local.lua next to these to add machine-specific overrides
-- without touching anything tracked by git. It is gitignored.
pcall(require, "conf.local")
