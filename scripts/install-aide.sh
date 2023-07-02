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

# Check if the script is being run with bash
if [[ -n "$BASH_VERSION" ]]; then
  print_success "This script is being run with bash."
else
  print_error "This script is not being run with bash."
  exit 1
fi

# Check if the script is being run with bash
if [[ -n "$BASH_VERSION" ]]; then
  print_success "This script is being run with bash."
else
  print_error "This script is not being run with bash."
  exit 1
fi

# Install AIDE package
print_info "Installing AIDE package..."
sudo yum install -y aide

# Initialize AIDE database
print_info "Initializing AIDE database..."
sudo aide --init

# Move AIDE database to the appropriate location
print_info "Moving AIDE database..."
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Check if AIDE configuration file permissions are secure
CONFIG_FILE="/etc/aide.conf"
if [[ $(stat -c %a "$CONFIG_FILE") -gt 600 ]]; then
  print_error "The AIDE configuration file ($CONFIG_FILE) permissions are not secure. Please set the file permissions to 600 or stricter."
  exit 1
fi

print_success "AIDE has been installed and configured successfully."
print_info "run aide --help for usage guide"
