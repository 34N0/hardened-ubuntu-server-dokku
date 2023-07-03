#!/bin/bash

# Function to print colored messages
print_success() {
  echo -e "\e[32m[SUCCESS]\e[39m $1"
}

print_info() {
  echo -e "\e[33m[INFO]\e[39m $1"
}

print_error() {
  echo -e "\e[31m[PROBLEM]\e[39m $1"
}

# Check if the script is being run with sudo
if [[ $EUID -ne 0 ]]; then
  print_error "This script must be run with sudo or as root"
  exit 1
fi

# Install Certbot dependencies
print_info "Installing Certbot dependencies..."
yum install -y epel-release > /dev/null 2>&1
yum install -y certbot python2-certbot-nginx > /dev/null 2>&1


print_success "Certbot has been installed successfully."
