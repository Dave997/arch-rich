#!/usr/bin/env bash

PKGS=(
    'cups'                  # Open source printer drivers
    'cups-pdf'              # PDF support for cups
    'ghostscript'           # PostScript interpreter
    'gsfonts'               # Adobe Postscript replacement fonts
    'hplip'                 # HP Drivers
    'system-config-printer' # Printer setup  utility
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "Printer drivers Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from pacman." 5 70
    sudo pacman -S "$PKG" --noconfirm --needed >/dev/null 2>&1
    n=$((n+1))
done