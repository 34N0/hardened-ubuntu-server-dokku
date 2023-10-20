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

### ⛑️ CIS Security Compliance

Make sure you read the [CIS Benchmark](CIS_Ubuntu_Linux_20.04_LTS_Benchmark_v1.1.0.pdf) first.

To achieve CIS Level 2 Compliance attach the machine to [Ubuntu Pro](https://ubuntu.com/pro/tutorial) and follow the instructions on [CIS setup](https://ubuntu.com/security/certifications/docs/usg/cis).

## 🤝 Contribute

We welcome contributions from the community to improve and enhance this project.