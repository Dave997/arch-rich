





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