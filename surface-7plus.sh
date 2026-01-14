#!/bin/bash

# surface-7plus.sh
# script by chaslinux@gmail.com

# this script updates the Ubuntu system and installs the touch drivers for the
# Microsoft Surface Pro 7+
# This borrows from a couple of places, but most recently:
# https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup

# This surface directory should be the REPODIR
REPODIR=$(pwd)

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
cd iptsd

# build iptsd
meson build
ninja -C build install

# create a service file
if [ ! -f /lib/systemd/system/iptsd.service ]; then
        sudo cp $REPODIR/iptsd.service /lib/systemd/system/iptsd.service
fi

# enable service
sudo systemctl enable iptsd
sudo systemctl start iptsd

# Import the linux-surface driver and trust the key
wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg

# Add the repo to apt and update
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" \
	| sudo tee /etc/apt/sources.list.d/linux-surface.list
sudo apt update

# Install the surface kernel driver and dependencies
sudo apt install linux-image-surface linux-headers-surface libwacom-surface iptsd -y

# Set up a secureboot mok key, the password should be surface
sudo apt install linux-surface-secureboot-mok -y

# update grub
sudo update-grub

echo "when prompted for a MOK key, enroll the MOK key with the password shown earlier, it should be surface."

