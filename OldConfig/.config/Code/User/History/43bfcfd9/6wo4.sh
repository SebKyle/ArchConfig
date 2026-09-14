#!/bin/bash 


killall waybar

if [[$USER = "sebkyle"]]
then waybar -c config.jsonc & -s /home/sebkyle/.config/hypr/waybar/style.css
else waybar &
fi