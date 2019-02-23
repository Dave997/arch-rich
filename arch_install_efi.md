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
This guide is only for UEFI systems (with GPT).

To be sure that is uefi check if that folder exists
``` bash 
    ls /sys/firmware/efi/efivars
    # if some files are displayed, it means that your pc has UEFI system
```
------

Now reboot and begin the installation process

## 3. Create partitions
Let's make some checks before start:
* Check partitions with ```lsblk```
* Check for internet connection with ```ping```, if it fails, use ```wifi-menu``` to search all possibile wifi connections. (If this doens't work stop the dhcp service with `systemctl stop dhcp@<interface>`, where the interface could be tab-completed)
* Check if the time is correctly working
    ```timedatectl set-ntp true``` (this should give no errors)
* Check the keyboard `https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration`  (to set italian keyboard `loadkeys it`)
* Check the clock with `timedate stuatus` or set it with `timedate set-ntp true`

N.B. now if you don't know your file system (UEFI or not), it's the last chance to check it.

Let's assume that the hard disk is the **/dev/sda** device (you can have a different one, but most of the time this is the letters that you have). And disk size of 15GB.

For first, open the interactive tool ```fdisk /dev/sda``` (you can check all disks avai)

(If there is any useless partition, you can use ```d``` command to delete it)

Let's create partitions:

N.B If you have some oddments of old partitions, this tool will ask you to remove the signature, so you can just type ```Y```.

*EFI partition*
```bash
    n #create new partition
    p #or just enter
    #now just enter to assign 1
    #enter again to let the partition start from the beginning
    +512M #in this case I gave 512megabytes to the first partition
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

*EFI partition file system*
``` bash
    mkfs.fat -F32 /dev/sda1
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
    #now you can check with "ls /mnt" if everything is fine

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
    genfstab -U -p /mnt >> /mnt/etc/fstab
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

Set a root password ```passwd```.

Set language
``` bash
    vim /etc/locale.gen #uncomment languages that you prefer
    locale-gen

    vim /etc/locale.conf #create new file
    #and type
        LANG=en_US.UTF-8
``` 

(optional) Set keyboard 
```bash
    vim /etc/vconsole.conf
    KEYMAP=it
```

Set timezone
``` bash
    ls /usr/share/zoneinfo #to see all timezones available
    # now we have to link /etc/localtime to the correct timezone

    ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
``` 

Network configuration
``` bash
    ## Set hostname
    vim /etc/hostname 
    #type whatever name you prefer

    ## Set hosts
    vim /etc/hosts
    #and type:
    127.0.0.1   localhost
    ::1         locahost
    <whateverip  myhostname.localdomain myhostname>
```

## 7. Install Bootloader
For first install grub
``` bash
    pacman -S grub efibootmgr
``` 

Now we have to create the efi directory
``` bash
    mkdir /boot/efi
    mount /dev/sda1 /boot/efi
``` 

Now we can check if everything is fine with `lsblk`.<br>
If yes, we can proceed with the grub configuration:
``` bash
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
    grub-mkconfig -o /boot/grub/grub.cfg
```
``` bash
    #at this poit the system should be ready to go, but this step will be useful to avoid possibile efi errors
    mkdir /boot/efi/EFI/BOOT
    cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
    #now we should create a startup script fot efi
    vim /boot/efi/startup.nsh

    #and write
    bcf boot add 1 fs0:\EFI\GRUB\grubx64.efi "My GRUB bootloader"
    exit
```

Now we can go back to the usb key with `exit` command and then `umount -R /mnt`, so we can safely `reboot`.
