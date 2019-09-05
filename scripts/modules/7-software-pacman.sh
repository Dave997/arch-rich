#!/usr/bin/env bash

PKGS=(

    # SYSTEM --------------------------------------------------------------

    # 'linux-lts'             # Long term support kernel

    # TERMINAL UTILITIES --------------------------------------------------

    'bash-completion'       # Tab completion for Bash
    'bc'                    # Precision calculator language
    'bleachbit'             # File deletion utility
    'curl'                  # Remote content retrieval
    'elinks'                # Terminal based web browser
    'feh'                   # Terminal-based image viewer/manipulator
    'file-roller'           # Archive utility
    'gnome-keyring'         # System password storage
    'gtop'                  # System monitoring via terminal
    'gufw'                  # Firewall manager
    'hardinfo'              # Hardware info app
    'htop'                  # Process viewer
    'inxi'                  # System information utility
    'jq'                    # JSON parsing library
    'jshon'                 # JSON parsing library
    'neofetch'              # Shows system info when you launch terminal
    'ntp'                   # Network Time Protocol to set time via network.
    'numlockx'              # Turns on numlock in X11
    'openssh'               # SSH connectivity tools
    'rsync'                 # Remote file sync utility
    'speedtest-cli'         # Internet speed via terminal
    'terminus-font'         # Font package with some bigger fonts for login terminal
    'tlp'                   # Advanced laptop power management
    'unrar'                 # RAR compression program
    'unzip'                 # Zip compression program
    'wget'                  # Remote content retrieval
    'xfce4-terminal'        # Terminal emulator
    'zenity'                # Display graphical dialog boxes via shell scripts
    'zip'                   # Zip compression program
    'zsh'                   # ZSH shell
    'zsh-completions'       # Tab completion for ZSH
    'texlive-most'          # LaTeX pacakges
    'biber'                 # Package to handle latex bibliography

    # DISK UTILITIES ------------------------------------------------------

    'autofs'                # Auto-mounter
    'exfat-utils'           # Mount exFat drives
    'gparted'               # Disk utility
    'gnome-disks'           # Disk utility
    'ntfs-3g'               # Open source implementation of NTFS file system
    'parted'                # Disk utility
    'dosfstools'            # Allows your computer to access dos-like filesystems
    'simple-mtpfs'	        # Enables the mounting of cell phones

    # GENERAL UTILITIES ---------------------------------------------------

    'catfish'               # Filesystem search
    'conky'                 # System information viewer
    'nemo'                  # Filesystem browser
    #'veracrypt'             # Disc encryption utility
    'variety'               # Wallpaper changer
    'xfburn'                # CD burning application
    'ranger'                # Terminal file explorer
    'dunst'                 # Suckless notification system
    'libnotify'             # Allows desktop notifications.
    'arandr'                # UI for screen adjustment
    'unclutter'             # Hides an inactive mouse

    # DEVELOPMENT ---------------------------------------------------------

    'atom'                  # Text editor
    'apache'                # Apache web server
    'clang'                 # C Lang compiler
    'cmake'                 # Cross-platform open-source make system
    'electron'              # Cross-platform development using Javascript
    'git'                   # Version control system
    'gcc'                   # C/C++ compiler
    'glibc'                 # C libraries
    'mariadb'               # Drop-in replacement for MySQL
    'meld'                  # File/directory comparison
    'nodejs'                # Javascript runtime environment
    'npm'                   # Node package manager
    'php'                   # Web application scripting language
    'php-apache'            # Apache PHP driver
    'postfix'               # SMTP mail server
    'python'                # Scripting language
    'qtcreator'             # C++ cross platform IDE
    'qt5-examples'          # Project demos for Qt
    'yarn'                  # Dependency management (Hyper needs this)

    # WEB TOOLS -----------------------------------------------------------

    'chromium'              # Web browser
    'firefox'               # Web browser
    'filezilla'             # FTP Client
    'flashplugin'           # Flash

    # COMMUNICATIONS ------------------------------------------------------

    'hexchat'               # Multi format chat
    'irssi'                 # Terminal based IIRC

    # MEDIA ---------------------------------------------------------------

    'lollypop'              # Music player
    'simplescreenrecorder'  # Record your screen
    'vlc'                   # Video player
    'scrot'                 # Screen capture.

    # GRAPHICS AND DESIGN -------------------------------------------------

    'gcolor2'               # Colorpicker
    'gimp'                  # GNU Image Manipulation Program
    'inkscape'              # Vector image creation app
    'imagemagick'           # Command line image manipulation tool
    'nomacs'                # Image viewer
    'pngcrush'              # Tools for optimizing PNG images
    'ristretto'             # Multi image viewer
    'xwobf'                 # Image pixel maker

    # PRODUCTIVITY --------------------------------------------------------

    'galculator'            # Gnome calculator
    'hunspell'              # Spellcheck libraries
    'hunspell-en'           # English spellcheck library
    'libreoffice-fresh'     # Libre office with extra features
    'mousepad'              # XFCE simple text editor
    'xpdf'                  # PDF viewer

    # VIRTUALIZATION ------------------------------------------------------

    'virtualbox'
    'virtualbox-host-modules-arch'
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "Software suite Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from pacman" 5 70
    sudo pacman -S "$PKG" --noconfirm --needed >/dev/null 2>&1
    n=$((n+1))
done