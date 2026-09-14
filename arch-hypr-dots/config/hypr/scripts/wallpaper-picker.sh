#!/usr/bin/env bash
# Pick a wallpaper with rofi, then hand it to setwall.sh.
# Bound to SUPER+W.
set -uo pipefail

WALL_DIRS=("$HOME/Pictures/wallpapers" "$HOME/.config/hypr/wallpapers" "$HOME/Wallpapers")
SETWALL="$HOME/.config/hypr/scripts/setwall.sh"

mapfile -d '' -t files < <(
    for d in "${WALL_DIRS[@]}"; do
        [[ -d $d ]] && find "$d" -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0
    done
)

if (( ${#files[@]} == 0 )); then
    notify-send -a wallpaper "No wallpapers found" "Put images in ${WALL_DIRS[0]}"
    exit 1
fi

# Build the rofi menu with image thumbnails via the icon protocol.
menu() {
    printf '%s\0icon\x1f%s\n' "🎲  Random" "dice"
    local f
    for f in "${files[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(basename "${f%.*}")" "$f"
    done
}

choice="$(menu | rofi -dmenu -i -p "wallpaper" \
    -show-icons \
    -theme-str 'element-icon { size: 88px; } listview { columns: 4; lines: 3; } window { width: 900px; }' \
    2>/dev/null)" || exit 0

[[ -z $choice ]] && exit 0

if [[ $choice == *"Random"* ]]; then
    exec "$SETWALL" --random
fi

for f in "${files[@]}"; do
    if [[ "$(basename "${f%.*}")" == "$choice" ]]; then
        exec "$SETWALL" "$f"
    fi
done

notify-send -a wallpaper "Could not resolve selection" "$choice"
