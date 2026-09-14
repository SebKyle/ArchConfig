-- Environment variables -------------------------------------------------
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- NOTE: if you launch Hyprland through uwsm, put these in
-- ~/.config/uwsm/env-hyprland instead -- uwsm sets up the environment
-- before Hyprland starts, so hl.env() lands too late for some toolkits.

-- Cursor ----------------------------------------------------------------
hl.env("XCURSOR_THEME",   "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_THEME","Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt --------------------------------------------------------------------
-- qt6ct/qt5ct drive the Qt theme (see ~/.config/qt6ct/qt6ct.conf), which in
-- turn points at Kvantum. This is what makes Dolphin match the rest.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Toolkits --------------------------------------------------------------
hl.env("GDK_BACKEND",   "wayland,x11,*")
hl.env("SDL_VIDEODRIVER","wayland")
hl.env("CLUTTER_BACKEND","wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- XDG desktop hints -----------------------------------------------------
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- NVIDIA ----------------------------------------------------------------
-- Uncomment the block below only if you are on an NVIDIA GPU.
-- See https://wiki.hypr.land/Nvidia/
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")
