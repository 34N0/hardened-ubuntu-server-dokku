# 🐋 Hardened ubuntu server dokku

## 📃 Introduction

This repository contains scripts, configuration templates, and documentation used for the initial setup of a hardened Ubuntu 22.04 LTS server using the Dokku service to host websites in a secure production environment. This project aims to achieve the following goals:

- 👩🏻‍🍳 Key-Based SSH with TOTP 2FA
- ⛑️ CIS Level 2 Compliance
- 🐋 Dokku PaaS with automated SSL
- 🚧 Providing hardened NGINX and Firewall configurations
- 🚧 Open-Appsec WAF

## 🏗️ Setup

### 👩🏻‍🍳 Create "host" user

To create a new user called "host," use the adduser command:

```bash
adduser host
```
add to sudo group:
```bash
usermod -aG sudo host
```
copy root ssh keys:
```bash
rsync --archive --chown=host:host /root/.ssh /home/host
```
Login as the newly created "host" user now.

### 🍳 Run setup script

"Clone" this repo into the "host" user home:
```bash
git init
git remote add origin https://github.com/34N0/ubuntu-server-dokku
git fetch
git checkout origin/main -ft
```

run the setup script:
```bash
sudo bash scripts/setup.sh
```
## ⛑️ Hardening & Firewall

Follow the Steps in the [Hardening](Hardening.md) document.

## 🐋 Install Dokku

download the installation script:
```bash
wget -NP . https://dokku.com/bootstrap.sh
```
get the repo key:
```bash
wget -qO - https://packagecloud.io/dokku/dokku/gpgkey | sudo apt-key add -
```
run the installer:
```bash
sudo DOKKU_TAG=v0.32.0 bash bootstrap.sh
```
configure your server domain
```bash
dokku domains:set-global <server domain>
```
and your ssh key to the dokku user:
```bash
PUBLIC_KEY="your-public-key-contents-here"
echo "$PUBLIC_KEY" | dokku ssh-keys:add admin
```
For automatic SSL use [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt)

## 🚧 Configuration

### ✗ NGINX

This Repository provides a hardened NGINX configuration. It configures basic DOS protection through reqeuest timeout and size constraints. Additionally it sets security headers according to OWASP recommendations.

```Content-Security-Policy``` and ```Content-Type``` headers should be set at application level and are not configured.

### 🧱 Firewall

The CIS Standard creates a file in ```/etc/nftables.rules```. Load the file with:
```bash
nft -f /etc/nftables.rules
```
This repository contains an [updated configuration](../templates/nftables.rules.template) file allowing a specified SSH port, Http & Https.

## 🤝 Contribute

We welcome contributions from the community to improve and enhance this project.
