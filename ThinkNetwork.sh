#!/bin/bash

# Verificăm dacă scriptul este rulat cu privilegii de root
if [[ $EUID -ne 0 ]]; then
   echo "Acest script trebuie să fie rulat cu privilegii de root." 
   exit 1
fi

echo "Dezinstalăm NetworkManager..."
pacman -Rns networkmanager

echo "Instalăm systemd-networkd și systemd-resolved..."
pacman -S systemd-networkd systemd-resolved

echo "Oprim și dezactivăm serviciile NetworkManager..."
systemctl stop NetworkManager
systemctl disable NetworkManager

echo "Dezactivăm NetworkManager-wait-online.service..."
systemctl disable NetworkManager-wait-online.service

echo "Configurăm systemd-networkd pentru conexiunea Ethernet..."

# Exemplu de configurare pentru o conexiune Ethernet
cat <<EOT > /etc/systemd/network/20-wired.network
[Match]
Name=enp*

[Network]
DHCP=yes
EOT

echo "Configurăm systemd-networkd pentru conexiunea wireless..."

# Exemplu de configurare pentru o conexiune wireless
cat <<EOT > /etc/systemd/network/25-wireless.network
[Match]
Name=wlp*

[Network]
DHCP=yes
EOT

echo "Configurăm systemd-resolved..."
systemctl enable systemd-resolved
systemctl start systemd-resolved

echo "Actualizăm setările DNS în /etc/resolv.conf..."
rm /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo "Activăm și pornim systemd-networkd..."
systemctl enable systemd-networkd
systemctl start systemd-networkd

echo "Repornim sistemul pentru aplicarea schimbărilor..."
reboot

