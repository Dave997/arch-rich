#!/usr/bin/env bash

echo
echo "INSTALLING i3vm"
echo

PKGS=(
        'i3-gaps'               # UI - Window manager
        'i3blocks'              # Status bar items
        'i3lock'                # Screen lock
        'i3status'              # Generates status bar
        'compton'		# screen composer manager
        'slim'			# Login manager
        'slim-themes'              
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "i3vm Software Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]})" 5 70
    sudo pacman -S "$PKG" --noconfirm --needed
    n=$((n+1))
done

echo
echo "Done!"
echo