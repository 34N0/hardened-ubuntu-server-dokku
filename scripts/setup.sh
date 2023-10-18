#!/bin/bash

# 1. Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# 2. Set APT repository location to the United States
echo "Setting APT repository location to the United States..."
sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/us.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list

# 3. Update APT package lists and upgrade installed packages
echo "Running apt update and upgrade..."
apt update
apt upgrade -y

# 4. Create a new user called 'host'
echo "Creating a new user 'host'..."
adduser host

# 5. Copy the public key of 'root' to 'host'
echo "Copying the public key of 'root' to 'host'..."
sudo -u host sh -c "mkdir -p /home/host/.ssh && cp /root/.ssh/authorized_keys /home/host/.ssh/authorized_keys && chown host:host /home/host/.ssh/authorized_keys"

# 6. Remove the public key for 'root'
echo "Removing the public key for 'root'..."
rm /root/.ssh/authorized_keys

echo "Initial setup completed successfully."
