#!/usr/bin/env bash

PKGS=(
            'alsa-utils'        # Advanced Linux Sound Architecture (ALSA) Components https://alsa.opensrc.org/
            'alsa-plugins'      # ALSA plugins
            'pulseaudio'        # Pulse Audio sound components
            'pulseaudio-alsa'   # ALSA configuration for pulse audio
            'pavucontrol'       # Pulse Audio volume control
            'volumeicon'        # System tray volume control
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "Audio components Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from pacman." 5 70
    sudo pacman -S "$PKG" --noconfirm --needed >/dev/null 2>&1
    n=$((n+1))
done