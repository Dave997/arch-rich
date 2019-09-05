#!/usr/bin/env bash

PKGS=(
        'xorg-server'           # XOrg server
        'xorg-apps'             # XOrg apps group
        'xorg-xprop'            # Tool for detecting window properties
        'xorg-xinit'            # XOrg init
        'xorg-xbacklight'	# Enables changing screen brightness levels.
        'xwallpaper'	        # Sets the wallpaper
        'xf86-video-intel'      # 2D/3D video driver
        'mesa'                  # Open source version of OpenGL
        'xf86-input-libinput'   # Trackpad driver for Dell XPS
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "Xorg Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from pacman" 5 70
    sudo pacman -S "$PKG" --noconfirm --needed >/dev/null 2>&1
    n=$((n+1))
done