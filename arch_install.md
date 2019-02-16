# Arch installation guide

## 1. Create a bootable USB
Plug in the usb key, and detect it with the ```lsblk``` command, 
Once done, start the procedure to burn the img file
``` bash
    sudo su
    dd if=<arch iso path> of=<usb key, e.g. /dev/sdb> status="progress"
```
Now we have a bootable hard-drive (check it again with ```lsblk```)

Executing "sync" before unplugging drive is a good practice methinks, or eject /dev/sdwhatever

## 2. Check file system
N.B. If you are using a system that requires UEFI, this guide won't be suitable
This guide works only on traditions bioses.

``` bash 
    ls /sys/firmware/efi/efivars
    # if some files are displayed, it means that your pc has UEFI system
```
If your system is UEFI, you need to take care about partitions and bootloader `https://wiki.archlinux.org/index.php/GRUB`, which have a different installation process (the other parts will be exactly the same)

I would recommend making the partitions with fdisk, but if you decide to only use legacy BIOS then I think you need to mark the boot partition as "BIOS boot" or else it won't boot. MAKE SURE TO WRITE THE PARTITIONS FIRST, then edit. From the fdisk wiki: "GRUB requires a BIOS boot partition with code ef02 with gdisk and BIOS boot with fdisk when installing GRUB to a disk." I didn't see the option for BIOS boot in fdisk, so did that in gdisk. This is only if you are not using UEFI.

------

Now reboot and begin the installation process

## 3. Create partitions
Let's make some checks before start:
* Check partitions with ```lsblk```
* Check for internet connection with ```ping```, if it fails, use ```wifi-menu``` to search all possibile wifi connections.
* Check if the time is correctly working
    ```timedatectl set-ntp true``` (this should give no errors)
* Check the keyboard `https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration`  (to set italian keyboard `loadkeys it`)

N.B. now if you don't know your file system (UEFI or not), it's the last chance to check it.

Let's assume that the hard disk is the **/dev/sda** device (you can have a different one, but most of the time this is the letters that you have). And disk size of 15GB.

For first, open the interactive tool ```fdisk /dev/sda```

(If there is any useless partition, you can use ```d``` command to delete it)

Let's create partitions:

N.B If you have some oddments of old partitions, this tool will ask you to remove the signature, so you can just type ```Y```.

*boot partition*
```bash
    n #create new partition
    p #or just enter
    #now just enter to assign 1
    #enter again to let the partition start from the beginning
    +200M #in this case I gave 200megabytes to the first partition
```

*swap partition*
``` bash
    n
    p #or enter
    2 #or enter
    #enter
    +2G #tip: the recommended amount of swap is usually 150% of the RAM size
```

Check partitions with ```p```

*root partition*
``` bash
    n
    p #or enter
    3 #or enter
    #enter
    +7G # in that partition will be stored all the applications
```

*home partition*
``` bash
    n
    p 
    3 #or enter
    #enter
    # enter to fill it up with all the rest of the space (or just type the size)
    # in that partition will be stored all your files
```

Check partitions with ```p```.
If it's everything fine, type ```w``` to write changes.

Now you can check the partitions with ```lsblk```.

## 4. Set up File system
N.B. The tipycal file system in linux is **ext4**.

*Boot partition file system*
``` bash
    mkfs.ext4 /dev/sda1
```

*Root partition file system*
``` bash
    mkfs.ext4 /dev/sda3
```

*Home partition file system*
``` bash
    mkfs.ext4 /dev/sda4
```

Now we can set up the swap

``` bash
    mkswap /dev/sda2
    swapon /dev/sda2
```

At this point we have to mount all the partitions, in order to be used, otherwise we won't be able to install anything

``` bash
    mount /dev/sda3 /mnt
    mkdir /mnt/home
    mkdir /mnt/boot
    #now you can check with "ls /mnt" if everything is fine

    mount /dev/sda1 /mnt/boot
    mount /dev/sda4 /mnt/home
```

Check with ```lsblk``` that everything is mounted fine.

## 5. Install Arch
Install all base packages in /mnt

``` bash
    pacstrap /mnt base
    pacstrap /mnt base-devel vim
```

## 6. Set-up Arch
Basically we have to create an fstab file, which automatically mount all the partitions.

``` bash
    genfstab -U /mnt >> /mnt/etc/fstab
``` 

Now we have to let arch start on the /mnt folder
``` bash
    arch-chroot /mnt
``` 
With this command now we've switched from our usb key to the new arch system.

Arch linux by default doesn't have a network manager, so we install it
``` bash
    pacman -S networkmanager
    systemctl enable NetworkManager
``` 

Install grub
``` bash
    pacman -S grub

    #generate configuration
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
``` 

Set a root password ```passwd```.

Set language
``` bash
    vim /etc/locale.gen #uncomment languages that you prefer
    locale-gen

    vim /etc/locale.conf #create new file
    #and type
        LANG=en_US.UTF-8
``` 

Set timezone
``` bash
    ls /usr/share/zoneinfo #to see all timezones available
    # now we have to link /etc/localtime to the correct timezone

    ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
``` 

Set hostname
``` bash
    vim /etc/hostname #and type whatever name you prefer
```

Now we can go back to the usb key with `exit` command and then `unmount -R /mnt`, so we can safely reboot.
