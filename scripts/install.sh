#!/bin/sh

#    Script for automation of arch linux post install
#
#    Author: Davide Ambrosi
#    
#    Credits to larbs (https://larbs.xyz/) and rickellis (https://github.com/rickellis)

### FUNCTIONS ###

error() { \
    clear; 
    printf "ERROR:\\n%s\\n" "$1"; 
    exit;
}

welcomemsg() { \
	dialog --title "Welcome!" --yes-label "Let's go!" --no-label "Exit" --yesno "This script will automatically install the i3-gaps on your Arch linux desktop.\\n\\n-Davide" 10 50 || { clear; exit; }
}

refreshkeys() { \
	dialog --infobox "Refreshing Arch Keyring..." 4 40
	pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
}

#===============#

# Initial check
#[ $(ping -c 1 www.archlinux.org) -gt 0 ] && error "Please check internet connection"
pacman -Syu --noconfirm --needed dialog ||  error "Please check if the following requirements have been met: 
    * Run as root 
    * Run on arch-based distro 
    * Available internet connection 
    * Arch keyring updated"

# Welcome user.
welcomemsg || error "User exited."

# Refresh Arch keyrings.
refreshkeys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

ls modules/ | grep .sh | while read line; do  
    # Make scripts executable
    chmod +x modules/$line
    # Run scripts
    ./modules/$line
done

dialog --title "Congrats! Arch installation completed." --msgbox "Now reboot and type 'xinit' to initialize Xorg, after that 'startx' to launch the GUI." 20 70