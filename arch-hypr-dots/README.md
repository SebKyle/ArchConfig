# arch-hypr-dots

A Hyprland desktop for Arch Linux: tiling WM, Waybar, rofi, swaync, Dolphin,
and a pywal pipeline that repaints the whole desktop from whatever wallpaper
you point it at.

Install Arch, clone this, run `./install.sh`, log in. That's the whole idea.

---

## Contents

| Path | What it is |
|---|---|
| `install.sh` | Installs dependencies and links `config/` into `~/.config` |
| `packages/` | `pacman.txt`, `aur.txt`, `optional.txt` — the dependency list |
| `config/hypr/` | Hyprland (Lua), hyprlock, hypridle, hyprpaper, scripts |
| `config/waybar/` | Status bar |
| `config/rofi/` | Launcher, window switcher, power menu |
| `config/swaync/` | Notification daemon and control centre |
| `config/kitty/` | Terminal |
| `config/wal/templates/` | pywal templates — the source of every colour |
| `config/qt6ct/`, `Kvantum/`, `gtk-*/` | Theming for Qt (Dolphin) and GTK apps |
| `assets/fallback-cache/` | Default palette, so the desktop is themed before pywal first runs |
| `wallpapers/` | Copied to `~/Pictures/wallpapers` on install |

---

## Install

### From a fresh Arch install

You need a working Arch system with networking, a regular user with `sudo`,
and nothing else.

```bash
sudo pacman -S --needed git
git clone https://github.com/<you>/arch-hypr-dots.git ~/dots
cd ~/dots
./install.sh
```

Then reboot (or log out) and start Hyprland from a TTY:

```bash
start-hyprland
```

> `start-hyprland` is the current launch command. The old advice to run
> `Hyprland` directly still works but is no longer what upstream documents.

> **If you cloned this from a Windows checkout** (or anywhere without a POSIX
> executable bit), run `bash install.sh` the first time — it chmods itself and
> the helper scripts as its first step. To record the bit in git permanently:
> `git update-index --chmod=+x install.sh config/hypr/scripts/*.sh`

### Options

```
./install.sh                  packages + link the config
./install.sh --no-packages    only link the config
./install.sh --packages-only  only install dependencies
./install.sh --optional       also install packages/optional.txt
./install.sh --copy           copy files instead of symlinking
./install.sh --dry-run        show what it would do, change nothing
```

The script is safe to re-run. Anything it would overwrite is moved to
`~/.config-backup-<timestamp>/` first, and a config already linked to this
repo is left alone.

By default it **symlinks**, so editing `~/.config/hypr/hyprland.lua` edits the
file in this repo and `git diff` shows your changes. Use `--copy` if you'd
rather keep the two separate.

---

## Wallpaper and colours

This is the part that ties everything together.

```bash
setwall ~/Pictures/wallpapers/whatever.png   # specific image
setwall --random                             # random from your wallpaper dirs
setwall --restore                            # re-apply the saved palette
```

or press **`SUPER+W`** for a graphical picker with thumbnails.

Changing the wallpaper does all of this in one go:

1. pywal extracts a 16-colour palette from the image
2. `config/wal/templates/` renders that palette into Hyprland-Lua, GTK-CSS,
   rasi and hyprlang formats
3. those get copied next to each app's stylesheet
4. Hyprland, Waybar, swaync, kitty, GTK and Dolphin are all reloaded in place

Window borders, the bar, the launcher, notifications, terminal colours, GTK
accents and the lock screen background all follow the image.

### Tuning the palette

`setwall.sh` defaults to `--cols16 darken --contrast 2.5`. The `--contrast`
flag is what stops a dark wallpaper producing dark-on-dark, unreadable UI.
Override it per-run:

```bash
WAL_FLAGS="--saturate 0.8 --contrast 3" setwall ~/Pictures/wallpapers/x.png
WAL_FLAGS="-l" setwall ~/Pictures/wallpapers/x.png    # light scheme
```

Add a colour to a new app by dropping a template in
`config/wal/templates/`. pywal renders every file in there to
`~/.cache/wal/<same name>` on each run. **Literal `{` and `}` in a template
must be doubled** (`{{`, `}}`) — pywal uses Python's `str.format`.

---

## Keybindings

`SUPER` is the modifier throughout. `hyprctl binds` prints this list live.

### Launching
| Key | Action |
|---|---|
| `SUPER` `T` / `SUPER` `Return` | Terminal (kitty) |
| `SUPER` `F` | File manager (Dolphin) |
| `SUPER` `R` | App launcher (rofi drun) |
| `SUPER` `Shift` `R` | Run a command |
| `SUPER` `Tab` | Window switcher |

### Windows
| Key | Action |
|---|---|
| `Ctrl` `Q` / `SUPER` `Q` | Close window |
| `SUPER` `V` | Toggle floating |
| `SUPER` `M` | Maximise |
| `SUPER` `Shift` `F` | Fullscreen |
| `SUPER` `C` | Centre |
| `SUPER` `P` | Pseudotile |
| `SUPER` `J` | Toggle split direction |
| `SUPER` `Shift` `P` | Pin to all workspaces |
| `SUPER` `←↑↓→` | Move focus |
| `SUPER` `Shift` `←↑↓→` | Move window |
| `SUPER` `S` | Resize mode — arrows to resize, `Esc` to exit |
| `SUPER` drag LMB / RMB | Move / resize with the mouse |

### Workspaces
| Key | Action |
|---|---|
| `SUPER` `1`–`0` | Go to workspace 1–10 |
| `SUPER` `Shift` `1`–`0` | Move window there |
| `SUPER` `Ctrl` `←` `→` | Previous / next workspace |
| `SUPER` scroll | Previous / next workspace |
| `SUPER` `A` | Toggle scratchpad |
| `SUPER` `Shift` `A` | Send window to scratchpad |

### System
| Key | Action |
|---|---|
| `SUPER` `L` | Lock |
| `SUPER` `Esc` | Power menu |
| `SUPER` `Shift` `M` | Exit Hyprland |
| `SUPER` `N` | Notification centre |
| `SUPER` `Shift` `N` | Do not disturb |
| `SUPER` `W` | Wallpaper picker |
| <code>SUPER &#124;</code> | Clipboard history |
| `SUPER` `Shift` `C` | Colour picker |
| `SUPER` `Shift` `B` | Reload Waybar |
| `Print` | Screenshot region to clipboard |
| `Shift` `Print` | Screenshot monitor |
| `SUPER` `Print` | Screenshot window |
| `SUPER` `Shift` `S` | Screenshot region, then annotate |

Volume, brightness and media keys work as expected, **including while the
screen is locked** (they carry the `locked` bind flag).

---

## The lock screen

`SUPER+L`, or automatically after 5.5 minutes idle.

The password field is **always visible** and pressing `Enter` on an empty
field does nothing at all — so you can tap `Enter` to wake the screen and then
type into a box you can actually see, instead of typing blind into a field
that has faded out.

That comes from two settings in `config/hypr/hyprlock.conf`:

```ini
general { ignore_empty_input = true }      # Enter on an empty field is a no-op
input-field { fade_on_empty = false }      # the box never fades away
```

`ignore_empty_input` matters for more than tidiness: without it, `Enter` on an
empty field submits an empty password, which counts as a failed attempt.
Arch's `pam_faillock` locks you out for 10 minutes after 3 of those.

If you'd rather the box hide itself when idle, set `fade_on_empty = true`.

Drop a square image at `~/.face` to get an avatar on the lock screen.

---

## Per-machine settings

Monitor layout and per-device input don't belong in a shared repo. Put them in
`config/hypr/conf/local.lua`, which is gitignored and loaded last:

```lua
-- ~/.config/hypr/conf/local.lua
hl.monitor({ output = "DP-1",  mode = "2560x1440@165", position = "0x0",    scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60",  position = "2560x0", scale = 1 })

hl.device({ name = "my-mouse", sensitivity = -0.4 })
```

Run `hyprctl monitors` and `hyprctl devices` to get the real names.

---

## Notes on what changed from the old config

This was ported from a pre-0.55 `hyprland.conf`. The things worth knowing:

**Hyprland uses Lua now.** Since 0.55, `hyprland.conf` (hyprlang) is
deprecated in favour of `hyprland.lua`. `hyprctl dispatch` takes Lua too:
`hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'`. hyprlock, hypridle
and hyprpaper still use the old `.conf` format — only the compositor moved.

**Bugs that were fixed along the way:**

- `hypridle.conf` said `hyprctrl`, not `hyprctl` — a typo, so DPMS never
  actually fired. It also used the old `dpms on` dispatcher syntax.
- `hyprpaper.conf` hardcoded `/home/sebkyle/...`, which breaks for any other
  username. Its `preload =` / `wallpaper =` syntax has also been replaced by
  `wallpaper { }` blocks.
- `decoration:rounding_power` was `1`; the valid range is `2.0`–`10.0`.
- `dwindle:pseudotile` is no longer a config option — pseudotiling is purely
  the `SUPER+P` dispatcher now.
- `gestures { workspace_swipe = ... }` was removed in favour of `hl.gesture()`.
- `windowrulev2` is now just `hl.window_rule()`.
- `exec-once = hyprlock` locked the screen on every single login. It's now the
  `LOCK_ON_LOGIN` flag at the top of `conf/autostart.lua`, off by default,
  since hypridle already locks on idle and before sleep.

**Package changes:**

- `neofetch` was dropped from the Arch repos (upstream is archived). Replaced
  with `fastfetch`, configured in `config/fastfetch/`.
- `rofi-wayland` no longer exists — rofi 2.0 merged Wayland support, so the
  plain `rofi` package is the right one. This replaces the old wofi setup.
- pywal upstream was archived in 2024. The list installs `python-pywal16`,
  the maintained fork. The binary is still `wal`.
- `hyprland-qtutils` was renamed `hyprland-guiutils`.

**Blur is on.** The old config had `blur.enabled = false`. It's on now because
the bar, launcher and notification centre are translucent and look flat
without it. If you want it off, set `enabled = false` under `decoration.blur`
in `config/hypr/conf/looks.lua` — the layer rules in `conf/rules.lua` become
no-ops automatically.

---

## Troubleshooting

**Hyprland won't start / config errors.**
Hyprland gives you emergency binds when the config fails early: `SUPER+Q`
(terminal), `SUPER+R` (run), `SUPER+M` (exit). Check the log:

```bash
tail -f "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
```

A Lua error in one `conf/*.lua` file only kills that file — each `require()`
is its own scope — so the rest of the desktop still comes up.

**Colours look wrong or unreadable after a wallpaper change.**
Raise the contrast floor:
`WAL_FLAGS="--cols16 darken --contrast 4" setwall <image>`

**Waybar is blank or unstyled.**
`config/waybar/colors.css` is missing. Run `setwall --restore`.

**Dolphin looks like plain Fusion, not themed.**
The chain is `QT_QPA_PLATFORMTHEME=qt6ct` → `qt6ct.conf` → `style=kvantum-dark`
→ Kvantum. Check `echo $QT_QPA_PLATFORMTHEME` inside a Hyprland session, and
that `kvantum` is installed. Fonts in `qt6ct.conf` are deliberately unset —
Qt stores them as binary blobs that aren't safe to hand-write, so set them in
the `qt6ct` GUI if you want to change them.

**Screen sharing picks the wrong backend.**
`config/xdg-desktop-portal/hyprland-portals.conf` pins screenshot/screencast
to the Hyprland backend and the file chooser to GTK. Restart the portals:
`systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland`

**Notifications don't appear.**
Only one notification daemon can own the DBus name. `pidof swaync` should
return something, and `dunst`/`mako` must not be running.

---

## References

- Hyprland wiki — <https://wiki.hypr.land/>
- Waybar — <https://github.com/Alexays/Waybar/wiki>
- swaync — <https://github.com/ErikReider/SwayNotificationCenter>
- rofi — `man rofi`, `man rofi-theme`
- pywal16 — <https://github.com/eylles/pywal16>
