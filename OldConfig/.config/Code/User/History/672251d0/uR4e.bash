#!/bin/bash

# Select a random PNG image from the waifu directory
image_source=$(find "${XDG_CONFIG_HOME:-$HOME/.config}/neofetch/Waifus/")

# Use the selected image in Neofetch
neofetch --source "$image_source"

if [[ -z "$image_source" ]]; then
    echo "No PNG files found in the waifu directory!"
    exit 1
fi