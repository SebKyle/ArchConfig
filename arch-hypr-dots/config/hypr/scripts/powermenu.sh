#!/usr/bin/env bash
# rofi power menu. Bound to SUPER+ESCAPE and the bar's power pill.
set -uo pipefail

THEME="$HOME/.config/rofi/themes/powermenu.rasi"

lock=""      # lock
suspend=""   # suspend
logout=""    # log out
reboot=""    # reboot
shutdown=""  # power off

chosen="$(printf '%s\n%s\n%s\n%s\n%s\n' \
    "$lock" "$suspend" "$logout" "$reboot" "$shutdown" \
    | rofi -dmenu -theme "$THEME" -p "$(whoami)@$(hostname)" -selected-row 0)" || exit 0

confirm() {
    local answer
    answer="$(printf 'No\nYes\n' | rofi -dmenu -p "$1?" \
        -theme-str 'window { width: 320px; } listview { columns: 2; lines: 1; } element-text { font: "JetBrainsMono Nerd Font 12"; }' \
        -theme "$THEME")" || return 1
    [[ $answer == "Yes" ]]
}

case "$chosen" in
    "$lock")     pidof hyprlock >/dev/null || hyprlock ;;
    "$suspend")  systemctl suspend ;;
    "$logout")
        confirm "Log out" || exit 0
        if command -v uwsm >/dev/null && uwsm check is-active >/dev/null 2>&1; then
            uwsm stop
        elif command -v hyprshutdown >/dev/null; then
            hyprshutdown
        else
            hyprctl dispatch 'hl.dsp.exit()'
        fi ;;
    "$reboot")   confirm "Reboot"   && systemctl reboot ;;
    "$shutdown") confirm "Shut down" && systemctl poweroff ;;
esac
