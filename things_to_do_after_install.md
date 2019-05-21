# After installation useful tips

## 1. Install a LTS kernel
> This kernel is useful if you prefer the stability of less-frequent kernel updates or if you want a fallback kernel in case a new kernel version causes problem.
https://www.youtube.com/watch?v=b-H3jURTgqk

Check your current kernel `uname -r`.<br>
Install the lts kernel `pacman -S linux-lts`.<br>Reconfigure grub `grub-mkconfig -o /boot/grub/grub.cfg`

Some applications (like virtualbox) require headers, so we should install them: `pacman -S linux-lts-headers`

Now reboot and check kernel version.<br>If everything worked fine we can remove the old one: `pacman -Rs linux`

## 2. Install Microcode

Check [arch wiki](<https://wiki.archlinux.org/index.php/Microcode>) for more info.

For intel CPU: `pacman -S intel-ucode`<br>For AMD CPU: `pacman -S linux-firmware`

Reconfigure grub `grub-mkconfig -o /boot/grub/grub.cfg`

## 3. Install some other key packages (optional)

``` bash
sudo pacman -S adobe-source-sans-pro-fonts aspell-en enchant gst-libav gst-plugins-good hunspell-en icedtea-web jre8-openjdk languagetool libmythes mythes-en pkgstats ttf-anonymous-pro ttf-bitstream-vera ttf-dejavu ttf-droid ttf-gentium ttf-liberation ttf-ubuntu-font-family
```

## 4. Set up firewall (instead of iptables)

`pacman -S ufw`

enable it: `ufw enable` <br>check the status: `ufw status verbose`<br>Add to startup services: `systemctl enable uwf.service`

Now reboot and check the status again

## 5. Remove Orphans

This will remove unused packages (used during system installation)

`pacman -Rns $(pacman -Qtdq)`

## 6. Optimize pacman access speed

`pacman-optimize`

## 7. Check for errors

`systemctl --failed`<br>`sudo journalctl -p 3 -xb`

if there are some errors google them and try to fix them.

https://www.youtube.com/watch?v=jW4GFGOIUjc