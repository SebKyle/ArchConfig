#!/bin/bash 


killall waybar

if [[$USER = "sebkyle"]]
then waybar -c /home/sebkyle/.config/hypr/waybar/waybarconfig.jsonc & -s /home/sebkyle/.config/hypr/waybar/style.css
else waybar &
fi