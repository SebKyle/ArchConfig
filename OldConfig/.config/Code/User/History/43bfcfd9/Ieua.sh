#!/bin/bash 


killall waybar

if [[$USER = "sebkyle"]]
then waybar -c ~/.config/hypr/waybar/config.jsonc & -s ~/.config/hypr/waybar/style.css
else waybar &
fi