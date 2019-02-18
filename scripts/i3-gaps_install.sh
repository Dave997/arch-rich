#!/bin/bash
# Davide's i3-gaps install script

##=====  FUNCTIONS  =====###

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
###=====================###

# Initial check
if [ dialog --version | wc -l -eq 0]; then 
    echo "You need to install dialog (sudo pacman -S dialog)"
    exit 1
fi

#pacman -Syu --noconfirm --needed dialog ||  error "Are you sure you're running this script as the root user? Are you sure you're using an Arch-based distro?"

# Welcome user.
welcomemsg || error "User exited"

# Refresh Arch keyrings.
refreshkeys || error "Something went wrong in Arch keyring refresh! Consider doing so manually."

dialog --title "Installation" --infobox "Installing \`basedevel\` and \`git\` for installing other software." 5 70
pacman --noconfirm --needed -S base-devel git >/dev/null 2>&1
[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers # Just in case

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
newperms "%wheel ALL=(ALL) NOPASSWD: ALL"

# Make pacman and yay colorful and adds eye candy on the progress bar because why not.
sed -i "s/^#Color/Color/g;/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

manualinstall $aurhelper || error "Failed to install AUR helper."