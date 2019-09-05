#!/usr/bin/env bash

PKGS=(
        'bluez'                 # Daemons for the bluetooth protocol stack
        'bluez-utils'           # Bluetooth development and debugging utilities
        'bluez-firmware'        # Firmwares for Broadcom BCM203x and STLC2300 Bluetooth chips
        'blueberry'             # Bluetooth configuration tool
        'pulseaudio-bluetooth'  # Bluetooth support for PulseAudio

        # Deprecated ibraries for the bluetooth protocol stack.
        # I believe the blues package above is all that is necessary now,
        # but I havn't tested this out, so for now I install this too.
        'bluez-libs' 
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "Bluetooth components Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from pacman." 5 70
    sudo pacman -S "$PKG" --noconfirm --needed >/dev/null 2>&1
    n=$((n+1))
done