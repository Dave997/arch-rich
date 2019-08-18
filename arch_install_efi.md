# Arch installation guide

## 1. Create a bootable USB
Plug in the usb key, and detect it with the ```lsblk``` command.<br> 
Once done, start the procedure to burn the img file:
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

    # OR

    efivar -l
```
if some files are displayed, it means that your pc has UEFI system

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

Let's assume that the hard disk is the **/dev/sda** device (you can have a different one, but most of the time this is the letters that you have). And disk size of 150GB.

For first, open the interactive tool ```cgdisk /dev/sda``` (you can check all disks available)

N.B. you can use **gdisk** (ex: type `x` and after `z` to erase the entire disk)

Check GUID codes: `https://askubuntu.com/questions/703443/gdisk-hex-codes`

|RAM size (GiB) | SWAP size (GiB) |
|--------|--------|
|   < 2   |   2 or 3 times RAM size   |
|  2 <-> 8 | equal to RAM size | 
|   8 >   |  0.5 times RAM size |

### Partitions:
* **Boot partition**: <br>
Size: 1GiB <br>
GUID: ef00 <br>
Name: boot <br>

* **Swap partition**: <br>
Size: 8GiB <br>
GUID: 8200 <br>
Name: swap <br>

* **Root partition**: <br>
Size: 41GiB <br>
GUID: 8300 <br>
Name: root <br>

* **Home partition**: <br>
Size: 100GiB <br>
GUID: 8302 <br>
Name: home <br>

Now you can check the partitions with ```lsblk```.

## 4. Set up File system
N.B. The tipycal file system in linux is **ext4**.

*EFI partition file system*
``` bash
    mkfs.vfat -F32 /dev/sda1
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
    mkdir /mnt/boot /mnt/home

    mount /dev/sda3 /mnt
    mount /dev/sda1 /mnt/boot
    mount /dev/sda4 /mnt/home
    #now you can check with "ls /mnt" if everything is fine
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

    export LANG=en_US.UTF-8
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

Add 32-bit app compatibility in pacman:
```bash
vim /etc/pacman.conf

# Uncomment:
#
#   [multilib]
#   Include = /etc/pacman.d/mirrorlist

pacman -Syy 
```

Create an initial ramdisk based on the 'linux' preset.
<br>For more info check the manual page:<br>https://git.archlinux.org/mkinitcpio.git/tree/man/mkinitcpio.8.txt<br>https://wiki.archlinux.org/index.php/mkinitcpio
``` bash
    mkinitcpio -p linux
``` 

### (Optional) Add user
```bash
useradd -m -g users -G wheel,storage,power -s /bin/bash <username>
passwd <username>

# add user to sudoers
EDITOR=vim visudo
# Uncomment:
# %wheel ALL=(ALL) ALL
``` 

## 7. Install Bootloader
(Optional) Get commands completion:
``` bash
    pacman -S bash-completion
```

For first install grub
``` bash
# Initial check:
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars
    # this should give already mounted error
    
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

    #confirm that grub has installed
    ls -l /boot/EFI/arch
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