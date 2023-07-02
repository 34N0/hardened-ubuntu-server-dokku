#!/bin/bash

# Color codes for fancy output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Function to print colored messages
print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
  echo -e "${RED}[PROBLEM]${NC} $1"
}

if [ -n "$SUDO_USER" ]; then
  print_success "Script executed with sudo by user: $SUDO_USER"
else
  print_error "Script must be executed with sudo"
  exit 1
fi
if [ -n "$SUDO_USER" ]; then
  echo "Script executed with sudo by user: $SUDO_USER"
else
  echo "Script must be executed with sudo"
  exit 1
fi

# Check if the script is being run with bash
if [[ -n "$BASH_VERSION" ]]; then
  print_success "This script is being run with bash."
else
  print_error "This script is not being run with bash."
  exit 1
fi

# Update the system
print_info "Updating the system..."
sudo yum update -y --allowerasing

# Install prerequisite packages
print_info "Installing prerequisite packages..."
sudo yum install -y --allowerasing yum-utils device-mapper-persistent-data lvm2

# Add the Docker repository
print_info "Adding the Docker repository..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
print_info "Installing Docker Engine..."
sudo yum install -y --allowerasing docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Docker Compose
print_info "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add the current user to the docker group
print_info "Adding the current user to the docker group..."
sudo usermod -aG docker $USER

# Start and enable the Docker service
print_info "Starting and enabling the Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
print_success "Docker has been installed successfully."
docker --version

# Prompt the user to reboot for changes to take effect
read -p "$(print_info "Do you want to reboot the system now?${NC} (y/n): ")" choice
if [[ $choice =~ ^[Yy]$ ]]; then
  print_success "Rebooting the system..."
  sudo reboot
else
  echo -e "${YELLOW}Please reboot the system to apply the changes.${NC}"
fi
