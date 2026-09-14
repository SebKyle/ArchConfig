# Wallpapers

`install.sh` copies everything in here to `~/Pictures/wallpapers/`, which is
the first directory `setwall.sh` and the `SUPER+W` picker look in.

Drop any `.png`, `.jpg`, `.jpeg` or `.webp` here (or straight into
`~/Pictures/wallpapers/`) and it shows up in the picker.

Changing wallpaper regenerates the entire colour scheme through pywal —
Hyprland borders, Waybar, rofi, swaync, kitty, GTK accents and the lock
screen all follow the image.

    setwall ~/Pictures/wallpapers/whatever.png   # specific image
    setwall --random                             # surprise me
    SUPER+W                                      # graphical picker

Large wallpaper collections are better kept out of git — add
`wallpapers/*` to `.gitignore` and keep them in `~/Pictures/wallpapers`
instead.
