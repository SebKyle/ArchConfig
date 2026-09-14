#!/usr/bin/env bash
# Small status line for hyprlock: battery + keyboard layout.
set -uo pipefail

out=""

bat="$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit 2>/dev/null || true)"
if [[ -n $bat && -r $bat/capacity ]]; then
    cap="$(cat "$bat/capacity")"
    status="$(cat "$bat/status" 2>/dev/null || echo Unknown)"
    case "$status" in
        Charging) icon="󰂄" ;;
        Full)     icon="󰁹" ;;
        *)        if   (( cap >= 80 )); then icon="󰂂"
                  elif (( cap >= 60 )); then icon="󰂀"
                  elif (( cap >= 40 )); then icon="󰁾"
                  elif (( cap >= 20 )); then icon="󰁼"
                  else                        icon="󰁺"; fi ;;
    esac
    out="$icon $cap%"
fi

if command -v hyprctl >/dev/null 2>&1; then
    layout="$(hyprctl devices -j 2>/dev/null \
        | grep -o '"active_keymap": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)"
    [[ -n ${layout:-} ]] && out="${out:+$out   }󰌌 ${layout}"
fi

printf '%s' "${out:-}"
