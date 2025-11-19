#!/bin/bash
# PassWall2 Installer for OpenWrt 22.03 aarch64
# English UI, Xray-core, auto-start, auto-echo IP

set -e

echo "Updating package list..."
opkg update

echo "Installing required dependencies..."
opkg install bash curl ca-certificates coreutils-base64 wget unzip luci-base luci-lib-base luci-mod-admin-full

# Download PassWall2 English IPK
PASSWALL_IPK="https://sourceforge.net/projects/openwrt-passwall-build/files/releases/packages-22.03/aarch64_cortex-a53/passwall2/luci-app-passwall2_25.8.9_all.ipk/download"

echo "Downloading PassWall2..."
wget -O /tmp/luci-app-passwall2.ipk "$PASSWALL_IPK"

echo "Installing PassWall2..."
opkg install /tmp/luci-app-passwall2.ipk

# Install Xray-core package
echo "Installing Xray-core..."
opkg install xray-core

# Enable PassWall2 service
echo "Enabling PassWall2 service..."
/etc/init.d/passwall enable
/etc/init.d/passwall start

# Get router IP (LAN)
router_ip=$(ip -4 addr show br-lan | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

echo -e "\nPassWall2 successfully installed!"
echo -e "Access UI at: http://${router_ip}/cgi-bin/luci/admin/services/passwall"
echo -e "Default UI Language: English"
