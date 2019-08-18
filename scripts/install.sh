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
pacman -Syu --noconfirm --needed dialog ||  error "Please check if the following requirements have been met: 
    * Run as root 
    * Run on arch-based distro 
    * Available internet connection 
    * Arch keyring updated"

#TODO: Check internet connectivity  ex: ping -c 1 www.archlinux.org

# Welcome user.
welcomemsg || error "User exited."

# Make scripts executable
ls modules/ | grep .sh | while read line; do  
    chmod +x modules/$line
done

# Run scripts
./modules/1-setup.sh
./modules/2-custom_progs.sh
./modules/3-graphic.sh
./modules/4-hw_manager.sh