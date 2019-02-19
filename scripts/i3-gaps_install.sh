#!/bin/bash
# Davide's i3-gaps install script

##==== DEFAULT VARS ====##
[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/lukesmithxyz/voidrice.git"
[ -z "$progsfile" ] && progsfile="./progs.csv"
[ -z "$aurhelper" ] && aurhelper="yay"
##======================##

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

newperms() { # Set special sudoers settings for install (or after).
	sed -i "/#i3install/d" /etc/sudoers
	echo "$* #i3install" >> /etc/sudoers ;
}

manualinstall() { # Installs $1 manually if not installed. Used only for AUR helper here.
	[ -f "/usr/bin/$1" ] || 
    (
        dialog --infobox "Installing \"$1\", an AUR helper..." 4 50
        cd /tmp || exit
        rm -rf /tmp/"$1"*
        curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
        sudo -u "$USER" tar -xvf "$1".tar.gz >/dev/null 2>&1 &&
        cd "$1" &&
        sudo -u "$USER" makepkg --noconfirm -si >/dev/null 2>&1
        cd /tmp || return
    ) ;https://raw.githubusercontent.com/LukeSmithxyz/LARBS/master/progs.csv
}

maininstall() { # Installs all needed programs from main repo.
	dialog --title "Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
}

gitmakeinstall() {
	dir=$(mktemp -d)
	dialog --title "Installation" --infobox "Installing \`$(basename "$1")\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2" 5 70
	git clone --depth 1 "$1" "$dir" >/dev/null 2>&1
	cd "$dir" || exit
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return ;
}

aurinstall() { \
	dialog --title "Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
	echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
	sudo -u "$USER" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
}

installationloop() { \
	#([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
    cat "$progsfile" | sed '/^#/d' > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	aurinstalled=$(pacman -Qm | awk '{print $1}')
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep "^\".*\"$" >/dev/null 2>&1 && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"") maininstall "$program" "$comment" ;;
			"A") aurinstall "$program" "$comment" ;;
			"G") gitmakeinstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv ;
}

putgitrepo() { # Downlods a gitrepo $1 and places the files in $2 only overwriting conflicts
	dialog --infobox "Downloading and installing config files..." 4 60
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2" && chown -R "$USER:wheel" "$2"
	chown -R "$USER:wheel" "$dir"
	sudo -u "$USER" git clone --depth 1 "$1" "$dir/gitrepo" >/dev/null 2>&1 &&
	sudo -u "$USER" cp -rfT "$dir/gitrepo" "$2"
}

serviceinit() {
    for service in "$@"; do
        dialog --infobox "Enabling \"$service\"..." 4 40
        systemctl enable "$service"
        systemctl start "$service"
	done ;
}

systembeepoff() { dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
	rmmod pcspkr
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf ;}

resetpulse() { dialog --infobox "Reseting Pulseaudio..." 4 50
	killall pulseaudio
	sudo -n "$USER" pulseaudio --start ;
}
###=====================###

# Initial check
#if [ dialog --version | wc -l -eq 0]; then 
    #echo "You need to install dialog (sudo pacman -S dialog)"
    #exit 1
 #fi
#[ -f /usr/bin/dialog ] || pacman -S dialog

pacman -Syu --noconfirm --needed dialog ||  error "Are you sure you're running this script as the root user? Are you sure you're using an Arch-based distro?"

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

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

## DOTFILES ##
# Install the dotfiles in the user's home directory
putgitrepo "$dotfilesrepo" "/home/$USER" #|| error "Programs have installed, but dotfiles failed to deploy."

# Install the LARBS Firefox profile in ~/.mozilla/firefox/
putgitrepo "https://github.com/LukeSmithxyz/mozillarbs.git" "/home/$USER/.mozilla/firefox"

##============##

# Pulseaudio, if/when initially installed, often needs a restart to work immediately.
[ -f /usr/bin/pulseaudio ] && resetpulse

# Install vim `plugged` plugins.
dialog --infobox "Installing (neo)vim plugins..." 4 50
(sleep 30 && killall nvim) &
sudo -u "$USER" nvim -E -c "PlugUpdate|visual|q|q" >/dev/null 2>&1

# Enable services here.
serviceinit NetworkManager cronie

# Most important command! Get rid of the beep!
systembeepoff

# This line, overwriting the `newperms` command above will allow the user to run
# serveral important commands, `shutdown`, `reboot`, updating, etc. without a password.
newperms "%wheel ALL=(ALL) ALL #i3install
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/packer -Syu,/usr/bin/packer -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/yay,/usr/bin/pacman -Syyuw --noconfirm"

dialog --title "All done!" --msgbox "Congrats! The process has finished, now you can reboot and enjoy :)" 12 80

clear