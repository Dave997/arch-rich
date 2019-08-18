#!/bin/sh

#    Script for automation of arch linux post install
#
#    Author: Davide Ambrosi

PKGS=(
    'xf86-video-intel'      # 2D/3D video driver
    'mesa'                  # Open source version of OpenGL
    'xf86-input-libinput'   # Trackpad driver for Dell XPS
)



#optional
pacman -S acpid #deamon for ACPI events https://wiki.archlinux.org/index.php/Acpid
pacman -S dbus #message bus system that provides an easy way for inter-process communication https://wiki.archlinux.org/index.php/D-Bus
pacman -S avahi #find devices in a network https://wiki.archlinux.org/index.php/avahi
pacman -S ntp #time manager
pacman -S cups #manage printers
pacman -S cronie #crontab jobs
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service