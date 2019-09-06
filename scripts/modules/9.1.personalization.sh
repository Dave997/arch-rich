#!/usr/bin/env bash


dialog --title "Personalization" --infobox "Make pacman and yay colorful and adds eye candy on the progress bar" 5 70

grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color/Color/" /etc/pacman.conf
grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

# ------------------------------------------------------------------------

dialog --title "Personalization" --infobox "Install the LARBS Firefox profile in ~/.mozilla/firefox/" 5 70 #TODO
#putgitrepo "https://github.com/LukeSmithxyz/mozillarbs.git" "${HOME}/.mozilla/firefox"

# ------------------------------------------------------------------------

dialog --title "Personalization" --infobox  "Applying Poly-Dark theme to GRUB" 5 70

THEME='poly-dark'

# Detect distro and set GRUB location and update method
GRUB_DIR='grub'
UPDATE_GRUB=''

if [ -e /etc/os-release ]; then

    source /etc/os-release

    if [[ "$ID" =~ (debian|ubuntu|solus) || \
          "$ID_LIKE" =~ (debian|ubuntu) ]]; then

        UPDATE_GRUB='update-grub'

    elif [[ "$ID" =~ (arch|gentoo) || \
            "$ID_LIKE" =~ (archlinux|gentoo) ]]; then

        UPDATE_GRUB='grub-mkconfig -o /boot/grub/grub.cfg'

    elif [[ "$ID" =~ (centos|fedora|opensuse) || \
            "$ID_LIKE" =~ (fedora|rhel|suse) ]]; then

        GRUB_DIR='grub2'
        UPDATE_GRUB='grub2-mkconfig -o /boot/grub2/grub.cfg'
    fi
fi

dialog --title "Personalization" --infobox  'Creating GRUB themes directory' 5 70
sudo mkdir -p /boot/${GRUB_DIR}/themes/${THEME}

dialog --title "Personalization" --infobox  'Copying theme to GRUB themes directory' 5 70
sudo cp -r themes/${THEME}/* /boot/${GRUB_DIR}/themes/${THEME}

dialog --title "Personalization" --infobox  'Removing other themes from GRUB config' 5 70
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub

dialog --title "Personalization" --infobox  'Making sure GRUB uses graphical output' 5 70
sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub

dialog --title "Personalization" --infobox  'Removing empty lines at the end of GRUB config' 5 70 # optional
sudo sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' /etc/default/grub

dialog --title "Personalization" --infobox  'Adding new line to GRUB config just in case' 5 70 # optional
echo | sudo tee -a /etc/default/grub

dialog --title "Personalization" --infobox  'Adding theme to GRUB config' 5 70
echo "GRUB_THEME=/boot/${GRUB_DIR}/themes/${THEME}/theme.txt" | sudo tee -a /etc/default/grub

dialog --title "Personalization" --infobox  'Updating GRUB' 5 70
if [[ $UPDATE_GRUB ]]; then
    eval sudo "$UPDATE_GRUB"
else
    dialog --title "Personalization" --msgbox  "Cannot detect your distro, you will need to run \"grub-mkconfig -o /boot/grub/grub.cfg\" manually." 5 70
fi

# ------------------------------------------------------------------------

dialog --title "Personalization" --infobox "Applying Overlay theme to SLiM" 5 70

sudo cp -r themes/slim_themes-master/themes/* /usr/share/slim/themes

sed -i 's/current_theme       default/current_theme       overlay/g' /etc/slim.conf

# ------------------------------------------------------------------------

#TODO:  Clone and copy dot files