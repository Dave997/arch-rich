# install wget
pacman -S wget

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