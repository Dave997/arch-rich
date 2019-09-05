#!/bin/sh

#    Script for automation of arch linux post install
#
#    Author: Davide Ambrosi

PKGS=(
		'mesa'					# Open-source implementation of OpenGL
        'xorg-server'           # XOrg server
        'xorg-apps'             # XOrg apps group
		# Included in xorg-apps:
        #       'xorg-xwininfo'         # Allows querying information about windows
        #       'xorg-xdpyinfo'         # Aids with resolution determination and screen recording
        #       'xorg-xbacklight'       # Enables changing screen brightness levels
        #       'xorg-xprop'            # Tool for detecting window properties
		#		many others...
        'xorg-xinit'            # Allows to run startx command
		'xorg-twm'	            # XOrg twm, X11's window manager
		'xorg-xclock'           # Digital clock for X
		'xterm'		            # Terminal emulator for X
        'xcompmgr'              # For transparency and removing screen-tearing
        'xwallpaper'            # Sets the wallpaper
        'ttf-inconsolata'       # Font
        'ttf-linux-libertine'   # Font
        'i3-gaps'               # UI - Window manager
        'i3blocks'              # Status bar items
        'i3lock'                # Screen lock
		'i3status'              # Generates status bar
		'compton'			 	# screen composer manager
		'slim'					# Login manager
		'slim-themes'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done




aurinstall() { \
	dialog --title "LARBS Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
	echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
	sudo -u "$name" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
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
 

manualinstall $aurhelper || error "Failed to install AUR helper."

# AUR isntallations
AUR_PKGS=(
        'gtk-theme-arc-gruvbox-git'     # gives the dark GTK theme used in LARBS
        'ttf-emojione'                  # is a package that gives the system unicode symbols and emojis used in the status bar and elsewhere
        'ttf-symbola'                   # provides unicode and emoji symbols
        'unclutter-xfixes-git'          # hides an inactive mouse
)

# install yay
[ -z "$aurhelper" ] && aurhelper="yay"

[ -f "/usr/bin/$aurhelper" ] || (
	dialog --infobox "Installing \"$aurhelper\", an AUR helper..." 4 50
	cd /tmp || exit
	rm -rf /tmp/"$aurhelper"*
	curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$aurhelper".tar.gz &&
	sudo -u "$name" tar -xvf "$1".tar.gz >/dev/null 2>&1 &&
	cd "$aurhelper" &&
	sudo -u "$name" makepkg --noconfirm -si >/dev/null 2>&1
	cd /tmp || return
) 



# Configure SLiM
https://wiki.archlinux.org/index.php/SLiM

sudo systemctl enable slim.service

https://www.gnome-look.org/p/1237548/


# Configure i3lock
scrot /tmp/screen.png  
xwobf -s 11 /tmp/screen.png  
i3lock -i /tmp/screen.png  
rm /tmp/screen.png