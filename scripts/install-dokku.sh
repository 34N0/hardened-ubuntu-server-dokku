#!/bin/bash

echo "download the installation script"
wget -NP . https://dokku.com/install/v0.32.0/bootstrap.sh

echo "run the installer"
sudo DOKKU_TAG=v0.32.0 bash bootstrap.sh

echo "dokku installed. You still need to configure your server domain & add your ssh key to dokku user"