#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  install.sh — set up this Hyprland config on a fresh Arch install     ║
# ║                                                                      ║
# ║    ./install.sh              packages + symlink the config           ║
# ║    ./install.sh --no-packages   only symlink (skip pacman/yay)       ║
# ║    ./install.sh --packages-only install deps, do not touch configs   ║
# ║    ./install.sh --optional      also install packages/optional.txt   ║
# ║    ./install.sh --copy          copy files instead of symlinking     ║
# ║    ./install.sh --dry-run       print what would happen              ║
# ║                                                                      ║
# ║  Safe to re-run. Anything it would overwrite is backed up first to   ║
# ║  ~/.config-backup-<timestamp>/                                       ║
# ╚══════════════════════════════════════════════════════════════════════╝
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

DO_PACKAGES=1
DO_LINK=1
DO_OPTIONAL=0
DRY_RUN=0
LINK_MODE="symlink"

# ── Output helpers ─────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    B=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[1;31m'; GRN=$'\033[1;32m'
    YLW=$'\033[1;33m'; MAG=$'\033[1;35m'; RST=$'\033[0m'
else
    B=""; DIM=""; RED=""; GRN=""; YLW=""; MAG=""; RST=""
fi
step() { printf '\n%s==>%s %s%s%s\n' "$MAG" "$RST" "$B" "$*" "$RST"; }
info() { printf '  %s·%s %s\n' "$DIM" "$RST" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$GRN" "$RST" "$*"; }
warn() { printf '  %s!%s %s\n' "$YLW" "$RST" "$*" >&2; }
die()  { printf '\n%serror:%s %s\n' "$RED" "$RST" "$*" >&2; exit 1; }
run()  { if (( DRY_RUN )); then printf '  %s$ %s%s\n' "$DIM" "$*" "$RST"; else "$@"; fi; }

usage() { sed -n '2,18p' "$0" | sed 's/^# \?//;s/[║╔╝╚╗═]//g'; exit 0; }

while (( $# )); do
    case "$1" in
        --no-packages)   DO_PACKAGES=0 ;;
        --packages-only) DO_LINK=0 ;;
        --optional)      DO_OPTIONAL=1 ;;
        --copy)          LINK_MODE="copy" ;;
        --dry-run)       DRY_RUN=1 ;;
        -h|--help)       usage ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
    shift
done

# ── Preflight ──────────────────────────────────────────────────────────
step "Checking the system"
[[ $EUID -ne 0 ]] || die "Do not run this as root. It installs into \$HOME and calls sudo where needed."
if (( DO_PACKAGES )) && ! command -v pacman >/dev/null; then
    die "pacman not found -- this script is for Arch and Arch-based distros. Use --no-packages to only link the config."
fi
ok "Running as $USER on $(source /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-unknown}")"
(( DRY_RUN )) && warn "Dry run: nothing will actually change."

# ── Packages ───────────────────────────────────────────────────────────
read_pkglist() {
    # Strip comments and blanks. Also drops trailing inline comments.
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1"
}

install_pacman() {
    local file="$1" label="$2"
    [[ -f $file ]] || { warn "missing $file"; return; }
    mapfile -t pkgs < <(read_pkglist "$file")
    (( ${#pkgs[@]} )) || return
    info "$label: ${#pkgs[@]} packages"
    run sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

bootstrap_yay() {
    command -v yay >/dev/null && { ok "yay already installed"; return; }
    step "Bootstrapping yay (AUR helper)"
    run sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp="$(mktemp -d)"
    run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    if (( ! DRY_RUN )); then
        ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
    fi
    run rm -rf "$tmp"
    ok "yay installed"
}

install_aur() {
    local file="$1"
    [[ -f $file ]] || return
    mapfile -t pkgs < <(read_pkglist "$file")
    (( ${#pkgs[@]} )) || return
    bootstrap_yay
    info "AUR: ${#pkgs[@]} packages"
    run yay -S --needed --noconfirm "${pkgs[@]}"
}

if (( DO_PACKAGES )); then
    step "Installing packages"
    run sudo pacman -Syu --noconfirm
    install_pacman "$REPO/packages/pacman.txt" "Repo"
    install_aur    "$REPO/packages/aur.txt"
    if (( DO_OPTIONAL )); then
        step "Installing optional packages"
        mapfile -t opt < <(read_pkglist "$REPO/packages/optional.txt")
        (( ${#opt[@]} )) && run yay -S --needed --noconfirm "${opt[@]}"
    fi
else
    step "Skipping packages (--no-packages)"
fi

# ── Link the config ────────────────────────────────────────────────────
backup() {
    local target="$1"
    [[ -e $target || -L $target ]] || return 0
    # An existing correct symlink into this repo needs no backup.
    if [[ -L $target && "$(readlink -f "$target")" == "$(readlink -f "$2")" ]]; then
        return 1
    fi
    mkdir -p "$BACKUP"
    local rel="${target#"$HOME"/}"
    run mkdir -p "$BACKUP/$(dirname "$rel")"
    run mv "$target" "$BACKUP/$rel"
    info "backed up ${rel}"
    return 0
}

place() {
    local src="$1" dst="$2"
    [[ -e $src ]] || { warn "missing source: $src"; return; }
    backup "$dst" "$src" || { ok "already linked: ${dst#"$HOME"/}"; return; }
    run mkdir -p "$(dirname "$dst")"
    if [[ $LINK_MODE == "copy" ]]; then
        run cp -r "$src" "$dst"
    else
        run ln -sfn "$src" "$dst"
    fi
    ok "${dst#"$HOME"/}"
}

if (( DO_LINK )); then
    # If this repo was cloned from a filesystem without a POSIX exec bit
    # (NTFS, a zip, a Windows checkout), the scripts arrive non-executable.
    # Fix that before anything tries to run them.
    step "Fixing script permissions"
    run chmod +x "$REPO/install.sh" "$REPO"/config/hypr/scripts/*.sh
    ok "scripts are executable"

    step "Linking configuration into ~/.config"
    info "mode: $LINK_MODE   (backups: $BACKUP)"

    for item in "$REPO"/config/*; do
        place "$item" "$HOME/.config/$(basename "$item")"
    done

    step "Linking home files"
    place "$REPO/home/bashrc" "$HOME/.bashrc"

    # ── Seed the pywal cache ───────────────────────────────────────────
    # Waybar, rofi, swaync, kitty and hyprlock all read generated files out
    # of ~/.cache/wal. On a brand new system those do not exist yet, so seed
    # them with the repo's default palette. Never clobber a real one.
    step "Seeding the colour cache"
    run mkdir -p "$HOME/.cache/wal"
    for f in "$REPO"/assets/fallback-cache/*; do
        base="$(basename "$f")"
        if [[ -e "$HOME/.cache/wal/$base" ]]; then
            info "keeping existing $base"
        else
            run cp "$f" "$HOME/.cache/wal/$base"
            ok "seeded $base"
        fi
    done

    # Distribute the palettes next to each stylesheet (same thing
    # setwall.sh does on every wallpaper change).
    for pair in \
        "colors-waybar.css:$HOME/.config/waybar/colors.css" \
        "colors-swaync.css:$HOME/.config/swaync/colors.css" \
        "colors-rofi.rasi:$HOME/.config/rofi/themes/colors.rasi" \
        "colors-gtk.css:$HOME/.config/gtk-3.0/colors.css" \
        "colors-gtk.css:$HOME/.config/gtk-4.0/colors.css"
    do
        src="$HOME/.cache/wal/${pair%%:*}"; dst="${pair#*:}"
        [[ -f $src ]] || continue
        run mkdir -p "$(dirname "$dst")"
        run cp -f "$src" "$dst"
        ok "palette -> ${dst#"$HOME"/}"
    done

    # ── Wallpapers ─────────────────────────────────────────────────────
    step "Wallpapers"
    run mkdir -p "$HOME/Pictures/wallpapers"
    if compgen -G "$REPO/wallpapers/*" >/dev/null; then
        for w in "$REPO"/wallpapers/*; do
            [[ -f $w ]] || continue
            dest="$HOME/Pictures/wallpapers/$(basename "$w")"
            [[ -e $dest ]] || run cp "$w" "$dest"
        done
        ok "copied into ~/Pictures/wallpapers"
    fi
    if [[ ! -e "$HOME/.config/hypr/current-wallpaper" ]]; then
        first="$(find "$HOME/Pictures/wallpapers" -maxdepth 1 -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
            -print -quit 2>/dev/null || true)"
        if [[ -n ${first:-} ]]; then
            run ln -sfn "$first" "$HOME/.config/hypr/current-wallpaper"
            ok "default wallpaper: $(basename "$first")"
        else
            warn "no wallpapers found -- drop some in ~/Pictures/wallpapers, then run: setwall --random"
        fi
    fi

    # ── Services ───────────────────────────────────────────────────────
    step "Enabling user services"
    if command -v systemctl >/dev/null; then
        run systemctl --user enable --now hyprpolkitagent.service 2>/dev/null || \
            warn "could not enable hyprpolkitagent (it also starts from hyprland.lua)"
    fi
fi

# ── Done ───────────────────────────────────────────────────────────────
step "Done"
cat <<EOM

  Next steps
  ──────────
  1. Log out and start Hyprland from a TTY with:   ${B}start-hyprland${RST}
     (or pick "Hyprland" in your display manager)

  2. Set a wallpaper and generate a matching palette:
       ${B}setwall ~/Pictures/wallpapers/your-image.png${RST}
     or press ${B}SUPER+W${RST} for the picker.

  3. Press ${B}SUPER+R${RST} for the launcher, ${B}SUPER+ESCAPE${RST} for the power menu.
     ${B}hyprctl binds${RST} lists every keybinding with a description.

  Backups of anything replaced: ${B}${BACKUP}${RST}
  (nothing was backed up if that directory does not exist)

EOM
