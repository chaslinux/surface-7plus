#!/bin/bash

# surface-7plus.sh
# script by chaslinux@gmail.com

# this script updates the Ubuntu system and installs the touch drivers for the 
# Microsoft Surface Pro 7+

# install updates
sudo apt update && sudo apt upgrade -y

# install basic build dependencies
sudo apt install git meson build-essential dkms pkg-config cmake systemd -y

# install dependencies for iptsd
sudo apt install libgles-dev libxext-dev libxi-dev libxrandr-dev -y 
sudo apt install libxcursor-dev libcairomm-1.16-dev -y

# Make a directory to hold the touch code and pull the repository
mkdir ~/Code
cd ~/Code
git clone https://github.com/linux-surface/iptsd

# build iptsd
cd iptsd
meson build
ninja -C build install

# create a service file
if [ ! -f /lib/systemd/system/iptsd.service ]; then
	sudo touch /lib/systemd/system/iptsd.service
	sudo echo "[Unit]" >> /lib/systemd/system/iptsd.service
	sudo echo "Description=Intel Precise Touch & Stylus Daemon" >> /lib/systemd/system/iptsd.service
	sudo echo "Documentation=https://github.com/linux-surface/iptsd" >> /lib/systemd/system/iptsd.service
	sudo printf '%s\n' >> /lib/systemd/system/iptsd.service
	sudo echo "[Service]" >> /lib/systemd/system/iptsd.service
	sudo echo "Type=simple" >> /lib/systemd/system/iptsd.service
	sudo echo "ExecStart=/usr/local/bin/iptsd" >> /lib/systemd/system/iptsd.service
	sudo printf '%s\n' >> /lib/systemd/system/iptsd.service
	sudo echo "[Install]" >> /lib/systemd/system/iptsd.service
	sudo echo "WantedBy=default.target" >> /lib/systemd/system/iptsd.service
fi

# enable service
sudo systemctl enable iptsd
sudo systemctl start iptsd
