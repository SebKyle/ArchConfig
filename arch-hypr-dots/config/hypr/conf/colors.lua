-- Colors ----------------------------------------------------------------
-- Single source of truth for every colour Hyprland itself draws.
--
-- pywal writes ~/.cache/wal/colors-hypr.lua from
-- ~/.config/wal/templates/colors-hypr.lua every time you change wallpaper.
-- If that file exists we use it; if it does not (fresh install, before you
-- have ever run `setwall`), we fall back to the static palette below so
-- Hyprland always starts with sane colours instead of erroring.
--
-- Values are strings in Hyprland colour syntax: "rgb(rrggbb)" / "rgba(rrggbbaa)".

local M = {
    -- Fallback palette: the orchid/hot-pink scheme from the original config.
    background = "rgb(100a16)",
    foreground = "rgb(dedeee)",
    color0  = "rgb(100a16)", color1  = "rgb(5630a6)",
    color2  = "rgb(715295)", color3  = "rgb(956da9)",
    color4  = "rgb(b7a4c6)", color5  = "rgb(cfa0d4)",
    color6  = "rgb(fbb3fb)", color7  = "rgb(dedeee)",
    color8  = "rgb(9b9ba6)", color9  = "rgb(5630a6)",
    color10 = "rgb(715295)", color11 = "rgb(956da9)",
    color12 = "rgb(b7a4c6)", color13 = "rgb(cfa0d4)",
    color14 = "rgb(fbb3fb)", color15 = "rgb(dedeee)",

    -- Pre-composed border/shadow colours (alpha baked in).
    border_active_a = "rgba(cfa0d4ee)",
    border_active_b = "rgba(fbb3fbee)",
    border_inactive = "rgba(9b9ba655)",
    shadow          = "rgba(00000099)",
}

local home = os.getenv("HOME") or ""
local ok, wal = pcall(dofile, home .. "/.cache/wal/colors-hypr.lua")
if ok and type(wal) == "table" then
    for k, v in pairs(wal) do
        if type(v) == "string" then M[k] = v end
    end
end

return M
