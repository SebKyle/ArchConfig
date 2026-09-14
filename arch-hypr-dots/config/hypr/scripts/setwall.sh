#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  setwall.sh — set the wallpaper and re-colour the whole desktop       ║
# ║                                                                      ║
# ║  Usage:                                                              ║
# ║    setwall.sh /path/to/image.png   set this image                    ║
# ║    setwall.sh --random             random image from ~/Pictures/...  ║
# ║    setwall.sh --restore            re-apply the last palette (login) ║
# ║    setwall.sh --reload             re-push current colours to apps   ║
# ║                                                                      ║
# ║  What it does:                                                       ║
# ║    1. runs pywal to regenerate ~/.cache/wal/* from the image         ║
# ║    2. points ~/.config/hypr/current-wallpaper at it (hyprlock uses   ║
# ║       this symlink, so the lock screen always matches)               ║
# ║    3. pushes the image to hyprpaper over IPC                         ║
# ║    4. reloads Hyprland, Waybar, swaync, kitty, GTK and Dolphin       ║
# ╚══════════════════════════════════════════════════════════════════════╝
set -uo pipefail

WALL_DIRS=("$HOME/Pictures/wallpapers" "$HOME/.config/hypr/wallpapers" "$HOME/Wallpapers")
CURRENT_LINK="$HOME/.config/hypr/current-wallpaper"

# pywal16 flags. --cols16 spreads the palette across all 16 slots and
# --contrast guarantees a minimum contrast ratio against the image, which is
# what stops dark wallpapers producing an unreadable dark-on-dark launcher.
# Override from the environment if you want a different look, e.g.
#   WAL_FLAGS="--saturate 0.8" setwall.sh ~/pic.png
WAL_FLAGS="${WAL_FLAGS:---cols16 darken --contrast 2.5}"

log()  { printf '\033[1;35m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

notify() {
    if have notify-send; then
        notify-send -a setwall -i "${2:-preferences-desktop-wallpaper}" "$1" "${3:-}" || true
    fi
}

die() { warn "$*"; notify "Wallpaper" "" "$*"; exit 1; }

# ── Pick the image ─────────────────────────────────────────────────────
pick_random() {
    local d found=()
    for d in "${WALL_DIRS[@]}"; do
        [[ -d $d ]] || continue
        while IFS= read -r -d '' f; do found+=("$f"); done \
            < <(find "$d" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)
    done
    (( ${#found[@]} )) || return 1
    printf '%s\n' "${found[RANDOM % ${#found[@]}]}"
}

MODE="set"
IMAGE=""

case "${1:-}" in
    --restore) MODE="restore" ;;
    --reload)  MODE="reload"  ;;
    --random)  IMAGE="$(pick_random)" || die "No images found in: ${WALL_DIRS[*]}" ;;
    ""|-h|--help)
        if [[ ${1:-} == "" ]]; then
            IMAGE="$(pick_random)" || die "No images found in: ${WALL_DIRS[*]}"
        else
            sed -n '2,20p' "$0" | sed 's/^# \?//'; exit 0
        fi ;;
    *) IMAGE="$1" ;;
esac

have wal || die "pywal is not installed (need the 'wal' binary from python-pywal16)"

# ── 1. Generate the palette ────────────────────────────────────────────
case "$MODE" in
    restore|reload)
        log "Restoring saved colour scheme"
        # -R restores the previous scheme; -n skips setting the wallpaper,
        # -s/-t skip poking terminals and the TTY, -e skips pywal's own
        # gtk/xrdb/i3 reload (we do our own, better, below).
        wal -R -n -s -t -e -q || warn "wal -R failed; falling back to whatever is already cached"
        IMAGE="$(readlink -f "$CURRENT_LINK" 2>/dev/null || true)"
        ;;
    set)
        [[ -f $IMAGE ]] || die "Not a file: $IMAGE"
        IMAGE="$(readlink -f "$IMAGE")"
        log "Generating palette from $(basename "$IMAGE")"
        # shellcheck disable=SC2086
        wal -i "$IMAGE" -n -s -t -e -q $WAL_FLAGS || die "pywal failed on $IMAGE"
        ;;
esac

# ── 2. Remember the choice ─────────────────────────────────────────────
if [[ -n ${IMAGE:-} && -f ${IMAGE:-} ]]; then
    mkdir -p "$(dirname "$CURRENT_LINK")"
    ln -sfn "$IMAGE" "$CURRENT_LINK"
fi

# ── 3. Wallpaper ───────────────────────────────────────────────────────
if [[ -n ${IMAGE:-} && -f ${IMAGE:-} ]] && have hyprctl; then
    if pidof hyprpaper >/dev/null 2>&1; then
        log "Pushing wallpaper to hyprpaper"
        # Newer hyprpaper needs no preload step; older builds do, and simply
        # error harmlessly if the request is unknown.
        hyprctl hyprpaper preload "$IMAGE"  >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ", $IMAGE, cover" >/dev/null 2>&1 \
            || hyprctl hyprpaper wallpaper ",$IMAGE" >/dev/null 2>&1 \
            || warn "hyprpaper would not take the wallpaper"
    else
        warn "hyprpaper is not running; starting it"
        hyprpaper >/dev/null 2>&1 &
    fi
fi

# ── 3b. Distribute the generated palettes ──────────────────────────────
# Waybar, swaync, rofi and GTK all use *relative* imports so they keep
# working when ~/.config/<app> is a symlink into a dotfiles repo. That means
# the generated palette has to sit next to each stylesheet rather than being
# imported out of ~/.cache/wal. These copies are gitignored.
sync_colors() {
    local cache="$HOME/.cache/wal"
    local -a pairs=(
        "$cache/colors-waybar.css:$HOME/.config/waybar/colors.css"
        "$cache/colors-swaync.css:$HOME/.config/swaync/colors.css"
        "$cache/colors-rofi.rasi:$HOME/.config/rofi/themes/colors.rasi"
        "$cache/colors-gtk.css:$HOME/.config/gtk-3.0/colors.css"
        "$cache/colors-gtk.css:$HOME/.config/gtk-4.0/colors.css"
    )
    local pair src dst
    for pair in "${pairs[@]}"; do
        src="${pair%%:*}"; dst="${pair#*:}"
        [[ -f $src ]] || continue
        mkdir -p "$(dirname "$dst")" 2>/dev/null || continue
        cp -f "$src" "$dst" 2>/dev/null || warn "could not write $dst"
    done
    log "Palettes distributed to app config dirs"
}

sync_colors

# ── 4. Reload everything that reads the palette ────────────────────────
reload_hyprland() {
    have hyprctl && hyprctl reload >/dev/null 2>&1 && log "Hyprland reloaded"
}

reload_waybar() {
    if pidof waybar >/dev/null 2>&1; then
        killall -SIGUSR2 waybar 2>/dev/null && log "Waybar reloaded"
    fi
}

reload_swaync() {
    if have swaync-client && pidof swaync >/dev/null 2>&1; then
        swaync-client -rs >/dev/null 2>&1
        swaync-client -R  >/dev/null 2>&1
        log "swaync reloaded"
    fi
}

reload_kitty() {
    # kitty re-reads its config on SIGUSR1.
    if pidof kitty >/dev/null 2>&1; then
        killall -SIGUSR1 kitty 2>/dev/null && log "kitty reloaded"
    fi
}

reload_gtk() {
    # Nudge GTK apps into re-reading gtk.css. Harmless if gsettings is absent.
    if have gsettings; then
        local scheme
        scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'prefer-dark'")"
        gsettings set org.gnome.desktop.interface color-scheme 'default'      2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme "${scheme//\'/}" 2>/dev/null || true
    fi
}

reload_dolphin() {
    # Qt apps pick up Kvantum/qt6ct changes on this DBus signal.
    if have dbus-send; then
        dbus-send --session --type=signal /KGlobalSettings \
            org.kde.KGlobalSettings.notifyChange int32:0 int32:0 >/dev/null 2>&1 || true
    fi
}

reload_hyprland
reload_waybar
reload_swaync
reload_kitty
reload_gtk
reload_dolphin

if [[ $MODE == "set" ]]; then
    notify "Wallpaper updated" "preferences-desktop-wallpaper" "$(basename "${IMAGE:-unknown}")"
fi
log "Done"
