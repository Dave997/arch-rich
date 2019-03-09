# Dual-Boot with Arch Linux

This guide works with GRUB bootloader only.

## Arch as primary OS
In this case Arch is the first (and the only one OS installed on the pc).<br>
We want to install another os:

1. Mount the partition with the 2<sup>th</sup> OS
```bash
    #locate the partition with the os using lsblk
    sudo mount /dev/sdxY /mnt

    #check if everything is fine
    ls /mnt
```

2. Install os-prober, a tool to detect other os in the system
```bash
    sudo pacman -S os-prober

    #now we have to update GRUB config file
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    #at this point we should read in the output the new os found, if not step back and check again to have mounted the right partition
```

Now `reboot` and boot into the new OS.<br>
N.B. If your system is configured to skip the GRUB menu, then pres `esc` or `shift` or any other hot-key that works on your pc.

## Arch as secondary OS
In this case Arch is the second OS.<br>
The first can be win, which after arch install won't be listed in the grub menu.

Install os-prober, a tool to detect other os in the system
```bash
    sudo pacman -S os-prober

    #now we have to update GRUB config file
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    #at this point we should read in the output the new os found, if not step back and check again to have mounted the right partition
```

Now `reboot` and you should see the other OS.<br>
N.B. If your system is configured to skip the GRUB menu, then pres `esc` or `shift` or any other hot-key that works on your pc.

-------
Check forlder configs here<br>
https://www.howtogeek.com/howto/35807/how-to-harmonize-your-dual-boot-setup-for-windows-and-ubuntu/