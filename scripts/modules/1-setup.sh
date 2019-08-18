#!/bin/sh

#    Script for automation of arch linux post install
#
#    Author: Davide Ambrosi

# DEFAULTS:
[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/lukesmithxyz/voidrice.git" && repobranch="archi3"
[ -z "$progsfile" ] && progsfile="progs.csv"
[ -z "$aurhelper" ] && aurhelper="yay"
[ -z "$repobranch" ] && repobranch="master"

### FUNCTIONS ###

error() { \
    clear;
    printf "ERROR:\\n%s\\n" "$1"
    exit
}

getuserandpass() { \
	# Request username
	name=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! echo "$name" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done

    # Request passowrds
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)

    # Check passwords
	while ! [ "$pass1" = "$pass2" ]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
}

usercheck() { \
    # Keep asking username if it already exists
	while (id -u "$name" >/dev/null 2>&1); do 
		dialog --colors --title "WARNING!" --msgbox "User $name already existing, insert a different name!" 14 60
		getuserandpass
	done ;
}

adduserandpass() { \
	# Adds user `$name` with password $pass1.
	dialog --infobox "Adding user \"$name\"..." 4 50
	useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
	usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
	echo "$name:$pass1" | chpasswd  # update passowrd in batch mode
	unset pass1 pass2
}

refreshkeys() { \
	dialog --infobox "Refreshing Arch Keyring..." 4 40
	pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
}

newperms() { # Set special sudoers settings for install (or after).
	sed -i "/#LARBS/d" /etc/sudoers
	echo "$* #LARBS" >> /etc/sudoers ;}

manualinstall() { # Installs $1 manually if not installed. Used only for AUR helper here.
	[ -f "/usr/bin/$1" ] || (
	dialog --infobox "Installing \"$1\", an AUR helper..." 4 50
	cd /tmp || exit
	rm -rf /tmp/"$1"*
	curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
	sudo -u "$name" tar -xvf "$1".tar.gz >/dev/null 2>&1 &&
	cd "$1" &&
	sudo -u "$name" makepkg --noconfirm -si >/dev/null 2>&1
	cd /tmp || return) ;}

maininstall() { # Installs all needed programs from main repo.
	dialog --title "LARBS Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
	}

gitmakeinstall() {
	dir=$(mktemp -d)
	dialog --title "LARBS Installation" --infobox "Installing \`$(basename "$1")\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2" 5 70
	git clone --depth 1 "$1" "$dir" >/dev/null 2>&1
	cd "$dir" || exit
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return ;}

aurinstall() { \
	dialog --title "LARBS Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
	echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
	sudo -u "$name" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
	}

pipinstall() { \
	dialog --title "LARBS Installation" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
	command -v pip || pacman -S --noconfirm --needed python-pip >/dev/null 2>&1
	yes | pip install "$1"
	}

installationloop() { \
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
			"P") pipinstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv
}

putgitrepo() { # Downlods a gitrepo $1 and places the files in $2 only overwriting conflicts
	dialog --infobox "Downloading and installing config files..." 4 60
	[ -z "$3" ] && branch="master" || branch="$repobranch"
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2" && chown -R "$name:wheel" "$2"
	chown -R "$name:wheel" "$dir"
	sudo -u "$name" git clone -b "$branch" --depth 1 "$1" "$dir/gitrepo" >/dev/null 2>&1 &&
	sudo -u "$name" cp -rfT "$dir/gitrepo" "$2"
}

serviceinit() { for service in "$@"; do
	dialog --infobox "Enabling \"$service\"..." 4 40
	systemctl enable "$service"
	systemctl start "$service"
	done
}

systembeepoff() { dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
	rmmod pcspkr
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
}

resetpulse() { dialog --infobox "Reseting Pulseaudio..." 4 50
	killall pulseaudio
	sudo -n "$name" pulseaudio --start
}

#=================#

# Create the new user
getuserandpass || error "User exited."
usercheck || error "User exited."
adduserandpass || error "Error adding username and/or password."

# Refresh Arch keyrings.
refreshkeys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

dialog --title "Basic SW Installation" --infobox "Installing \`basedevel\` and \`git\` for installing other software." 5 70
pacman --noconfirm --needed -S base-devel git >/dev/null 2>&1
[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers # Just in case

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
newperms "%wheel ALL=(ALL) NOPASSWD: ALL"

# Make pacman and yay colorful and adds eye candy on the progress bar because why not.
grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color/Color/" /etc/pacman.conf
grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

manualinstall $aurhelper || error "Failed to install AUR helper."

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

# Install the dotfiles in the user's home directory
putgitrepo "$dotfilesrepo" "/home/$name" "$repobranch"
rm -f "/home/$name/README.md" "/home/$name/LICENSE"

# Install the LARBS Firefox profile in ~/.mozilla/firefox/
putgitrepo "https://github.com/LukeSmithxyz/mozillarbs.git" "/home/$name/.mozilla/firefox"

# Pulseaudio, if/when initially installed, often needs a restart to work immediately.
[ -f /usr/bin/pulseaudio ] && resetpulse

# Enable services here.
serviceinit NetworkManager cronie

# Most important command! Get rid of the beep!
systembeepoff

# This line, overwriting the `newperms` command above will allow the user to run
# serveral important commands, `shutdown`, `reboot`, updating, etc. without a password.
newperms "%wheel ALL=(ALL) ALL #LARBS
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/packer -Syu,/usr/bin/packer -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/yay,/usr/bin/pacman -Syyuw --noconfirm"

clear