#!/bin/bash

# 1. Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges."
    exit 1
fi

# 2. Set APT repository location to the United States
echo "Setting APT repository location to the United States..."
sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/us.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list

# 3. Update APT package lists and upgrade installed packages
echo "Running apt update and upgrade..."
apt update
apt upgrade -y

# 4. Remove the public key for 'root'
echo "Removing the public key for 'root'..."
rm /root/.ssh/authorized_keys

echo "Initial setup completed successfully."
