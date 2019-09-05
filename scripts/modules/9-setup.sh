#!/usr/bin/env bash


dialog --title "Final setup and configuration" --infobox "Generating .xinitrc file" 5 70

# Generate the .xinitrc file so we can launch i3 from the
# terminal using the "startx" command
cat <<EOF > ${HOME}/.xinitrc
#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "\$f" ] && . "\$f"
    done
    unset f
fi

exec i3
exit 0
EOF

# cp ${HOME}/.xinitrc root/

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Updating /bin/startx to use the correct path" 5 70

# By default, startx incorrectly looks for the .serverauth file in our HOME folder.
sudo sed -i 's|xserverauthfile=\$HOME/.serverauth.\$\$|xserverauthfile=\$XAUTHORITY|g' /bin/startx

# ------------------------------------------------------------------------

#echo
#echo "Configuring LTS Kernel as a secondary boot option"
#
#sudo cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-lts.conf
#sudo sed -i 's|Arch Linux|Arch Linux LTS Kernel|g' /boot/loader/entries/arch-lts.conf
#sudo sed -i 's|vmlinuz-linux|vmlinuz-linux-lts|g' /boot/loader/entries/arch-lts.conf
#sudo sed -i 's|initramfs-linux.img|initramfs-linux-lts.img|g' /boot/loader/entries/arch-lts.conf

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Configuring MAKEPKG to use all 8 cores" 5 70

sudo sed -i -e 's|[#]*MAKEFLAGS=.*|MAKEFLAGS="-j$(nproc)"|g' makepkg.conf
sudo sed -i -e 's|[#]*COMPRESSXZ=.*|COMPRESSXZ=(xz -c -T 8 -z -)|g' makepkg.conf

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Setting laptop lid close to suspend" 5 70

sudo sed -i -e 's|[# ]*HandleLidSwitch[ ]*=[ ]*.*|HandleLidSwitch=suspend|g' /etc/systemd/logind.conf

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Disabling buggy cursor inheritance" 5 70

# When you boot with multiple monitors the cursor can look huge. This fixes it.
sudo cat <<EOF > /usr/share/icons/default/index.theme
[Icon Theme]
#Inherits=Theme
EOF

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Increasing file watcher count" 5 70

# This prevents a "too many files" error in Visual Studio Code
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Disabling Pulse .esd_auth module" 5 70

# Pulse audio loads the `esound-protocol` module, which best I can tell is rarely needed.
# That module creates a file called `.esd_auth` in the home directory which I'd prefer to not be there. So...
sudo sed -i 's|load-module module-esound-protocol-unix|#load-module module-esound-protocol-unix|g' /etc/pulse/default.pa

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox  "Enabling bluetooth daemon and setting it to auto-start" 5 70

sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox  "Enabling the cups service daemon so we can print" 5 70

systemctl enable org.cups.cupsd.service
systemctl start org.cups.cupsd.service

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Enabling Network Time Protocol so clock will be set via the network" 5 70

sudo ntpd -qg
sudo systemctl enable ntpd.service
sudo systemctl start ntpd.service

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Enable SLiM DM" 5 70

sudo systemctl enable slim.service

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox  "Getting rid of the error beep sound..." 5 70
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

# ------------------------------------------------------------------------

dialog --title "Final setup and configuration" --infobox "Network Setup" 5 70
echo
echo "Find your IP Link name:"
echo

ip link

echo
read -p "ENTER YOUR IP LINK: " LINK

echo
echo "Disabling DHCP and enabling Network Manager daemon"
echo

sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
sudo ip link set dev ${LINK} down
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
sudo ip link set dev ${LINK} up