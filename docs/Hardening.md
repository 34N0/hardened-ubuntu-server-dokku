# ⛑️ Hardening Ubuntu Server

## 🪂 CIS Security Compliance

Make sure you read the [CIS Benchmark](CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0.pdf) first.

To achieve CIS Level 2 Compliance attach the machine to [Ubuntu Pro](https://ubuntu.com/pro/tutorial) and follow the instructions on [CIS setup](https://ubuntu.com/security/certifications/docs/usg/cis).

after you followed the documentation you should audit the system:
```bash
sudo usg audit cis_level2_server
```
copy the report to host user home, make host the owner and download with:
```bash
scp -P <port> host@<hostname>:~/usg-report-<...>.html .
```

## 🏴 Without Ubuntu PRO

Alternativelly this repository contains the script [cis-level2-server.sh](../scripts/cis-level2-server.sh) which automates fixing compliance issues without having a Ubuntu Server subscription. This is not recommended since you loose the audit capabilities. Running this script blind is a bad idea so make sure you understand what it does!

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

Follow this [Digital Ocean Guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-20-04).

## 🏝️ Open-Appsec

Open-Appsec is a ml base WAF. From [openappsec.io](https://www.openappsec.io/): 

> Prevents OWASP-Top-10 and zero-day threats against Web App & APIs by using ML-based security without signature updates (e.g. blocked Log4Shell and Spring4Shell with no updates)

It integrates nicely with the local NGINX reverse proxy used by Dokku. To install the WAF follow this [documentation](https://docs.openappsec.io/getting-started/start-with-linux).