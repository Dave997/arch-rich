#!/usr/bin/env bash

PKGS=(
        'wpa_supplicant'            # Key negotiation for WPA wireless networks
        'dialog'                    # Enables shell scripts to trigger dialog boxex
        'networkmanager'            # Network connection manager
        'openvpn'                   # Open VPN support
        'networkmanager-openvpn'    # Open VPN plugin for NM
        'networkmanager-vpnc'       # Open VPN plugin for NM. Probably not needed if networkmanager-openvpn is installed.
        'network-manager-applet'    # System tray icon/utility for network connectivity
        'dhclient'                  # DHCP client
        'libsecret'                 # Library for storing passwords
        'wireless_tools'            # Tools allowing to manipulate the Wireless Extensions
)

n=1
for PKG in "${PKGS[@]}"; do
    dialog --title "Network components Installation" --infobox "Installing \`$PKG\` ($n of ${#PKGS[@]}) from pacman." 5 70
    sudo pacman -S "$PKG" --noconfirm --needed >/dev/null 2>&1
    n=$((n+1))
done