# ⛑️ Hardening Ubuntu Server

## 📱 SSH

1. Open the /etc/ssh/sshd_config 

2. Set the following:
custom port:
```bash
Port <port_number>
```
restrict the maximum aut tries to 4:
```bash
MaxAuthTries 4
```
disalbe host based auth:
```bash
IgnoreRhosts yes
```
disalbe root login:
```bash
PermitRootLogin no
```
(assuming you're using key auth) disable passwort auth:
```bash
PasswordAuthentication no
```
disable challenge response:
```bash
ChallengeResponseAuthentication no
```
set max idle connections to 5min:
```bash
ClientAliveInterval 300
ClientAliveCountMax 0
```
3. restart sshd
```bash
systemctl restart sshd
```

### 2FA

Follow the official [Ubuntu Guide](https://ubuntu.com/tutorials/configure-ssh-2fa#2-installing-and-configuring-required-packages).

## 🧱 UFW

Set default policies:
```bash
sudo ufw default deny incoming
sudo ufw default deny outgoing
```
Allow Connections:
```bash
sudo ufw allow <ssh port>
sudo ufw allow http
sudo ufw allow https
```

## ⛑️ CIS Security Compliance

Make sure you read the [CIS Benchmark](CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0.pdf) first.

To achieve CIS Level 2 Compliance attach the machine to [Ubuntu Pro](https://ubuntu.com/pro/tutorial) and follow the instructions on [CIS setup](https://ubuntu.com/security/certifications/docs/usg/cis).
