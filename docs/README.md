# ⛑️ Ubuntu Server Dokku

This repository scripts used for an initial set up a hardened ubuntu server using the dokku service to host websites in a production environment.

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

Clone this repo into the "host" user home:
```bash
git clone https://github.com/34N0/ubuntu-server-dokku
```
run the setup script:
```bash
sudo bash scripts/setup.sh
```

### ⛑️ Harden System

follow the instructions in scripts/hardening

### 🔭 Auditing

install bats:
```bash
sudo apt-get install bats
```
run tests:
```bash
sudo bats hardening/tests/*.bats
```

#### Lynis

install lynis:
```bash
sudo apt-get install lynis
```
audit:
```bash
sudo lynis audit system
```

*act according to the bats & lynis audit reports*

## 🤝 Contribute

We welcome contributions from the community to improve and enhance this project.