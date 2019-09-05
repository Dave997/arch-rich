#!/usr/bin/env bash

dialog --title "AUR Software Installation" --infobox "Installing \`yay\` an AUR helper." 5 70

git clone https://aur.archlinux.org/yay.git
bash -c "cd yay; sudo makepkg --noconfirm --si >/dev/null 2>&1"
rm -rf yay


PKGS=(

    # SYSTEM UTILITIES ----------------------------------------------------

    'menulibre'                 # Menu editor
    'gtkhash'                   # Checksum verifier

    # TERMINAL UTILITIES --------------------------------------------------

    'hyper'                     # Terminal emulator built on Electron
    'sc-im'                     # Excel-like terminal spreadsheet manager.

    # UTILITIES -----------------------------------------------------------

    'dropbox'                   # Cloud file storage
    'enpass-bin'                # Password manager
    'slimlock'                  # Screen locker
    'oomox'                     # Theme editor

    # DEVELOPMENT ---------------------------------------------------------
    
    'visual-studio-code-bin'    # Kickass text editor

    # MEDIA ---------------------------------------------------------------

    'spotify'                   # Music player
    'screenkey'                 # Screencast your keypresses

    # POST PRODUCTION -----------------------------------------------------

    'peek'                      # GIF animation screen recorder

    # COMMUNICATIONS ------------------------------------------------------

    'skypeforlinux-stable-bin'  # Skype

    # THEMES --------------------------------------------------------------

    'gtk-theme-arc-git'
    'gtk-theme-arc-gruvbox-git'
    'adapta-gtk-theme-git'
    'paper-icon-theme'
    'tango-icon-theme'
    'tango-icon-theme-extras'
    'numix-icon-theme-git'
    'sardi-icons'
    'ttf-emojione'              # is a package that gives the system unicode symbols and emojis used in the status bar and elsewhere
    'ttf-symbola'               # provides unicode and emoji symbols
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "AUR Software Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from the AUR." 5 70
    yay -S $PKG >/dev/null 2>&1
    n=$((n+1))
done