# 🚧 Ubuntu Server Dokku

This repository scripts used for an initial set up a hardened ubuntu 22.04 LTS server using the dokku service to host websites in a production environment.

## 📃 Introduction

Setting up a secure web hosting environment involves configuring various components such as web servers, reverse proxies, and scripts for automation. This repository provides a standardized structure for managing these components using Docker containers and scripts. 

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
sudo bash setup.sh
```

## 🐋 Install Dokku

download the installation script:
```bash
wget -NP . https://dokku.com/bootstrap.sh
```
run the installer:
```bash
sudo DOKKU_TAG=v0.32.0 bash bootstrap.sh
```
configure your server domain
```bash
dokku domains:set-global dokku.me
```
and your ssh key to the dokku user:
```bash
PUBLIC_KEY="your-public-key-contents-here"
echo "$PUBLIC_KEY" | dokku ssh-keys:add admin
```

For automatic SSL use [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt)

## 🚧 Configuration

### Hardening

Follow the Steps in the [Harden](Harden.md) document.

## 🤝 Contribute

We welcome contributions from the community to improve and enhance this project.