# ⛑️ Hardening Ubuntu Server

## 🪂 CIS Security Compliance

Make sure you read the [CIS Benchmark](CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0.pdf) first.

To achieve CIS Level 2 Compliance attach the machine to [Ubuntu Pro](https://ubuntu.com/pro/tutorial) and follow the instructions on [CIS setup](https://ubuntu.com/security/certifications/docs/usg/cis).

## 📱 SSH

Additional SSH Configuration which is not part of CIS Level 2:

1. Open the /etc/ssh/sshd_config 

2. Set the following:
custom port:
```bash
Port <port_number>
```
(assuming you're using key auth) disable passwort auth:
```bash
PasswordAuthentication no
```
3. restart sshd
```bash
systemctl restart sshd
```

### 2FA

Follow the official [Ubuntu Guide](https://ubuntu.com/tutorials/configure-ssh-2fa#2-installing-and-configuring-required-packages).