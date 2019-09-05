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

ls modules/ | grep .sh | while read line; do  
    # Make scripts executable
    chmod +x modules/$line
    # Run scripts
    ./modules/$line
done

echo ""
echo "Congrats! Arch installation completed."
echo "Now reboot and type 'xinit' to initialize Xorg, after that 'startx' to launch the GUI."
echo ""