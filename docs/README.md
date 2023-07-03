# ⛑️ Hardened Hosting VPS

```
██╗  ██╗      ██╗  ██╗      ██╗   ██╗██████╗ ███████╗
██║  ██║      ██║  ██║      ██║   ██║██╔══██╗██╔════╝
███████║█████╗███████║█████╗██║   ██║██████╔╝███████╗
██╔══██║╚════╝██╔══██║╚════╝╚██╗ ██╔╝██╔═══╝ ╚════██║
██║  ██║      ██║  ██║       ╚████╔╝ ██║     ███████║
╚═╝  ╚═╝      ╚═╝  ╚═╝        ╚═══╝  ╚═╝     ╚══════╝
                                                     
```

This repository contains Dockerfiles and scripts used to set up a secure web hosting environment on an Centos based VPS.

## 📃 Introduction

Setting up a secure web hosting environment involves configuring various components such as web servers, reverse proxies, and scripts for automation. This repository provides a standardized structure for managing these components using Docker containers and scripts. 

## ⚒️ Test locally (without SSL)

1. Create a centos 7 based server VM
2. Connect to your VM via SSH.
3. Clone this repository onto your VM.
2. Clone this repository onto your VPS.
4. Navigate to the repository directory.
5. Review and run the setup scripts:
```
bash scripts/setup.bash
```
5.1. *Optional* Review and run the features scripts:
```
# general harden steps
bash scripts/harden/harden-centos.bash

# install [AIDE](https://aide.github.io/)
bash scripts/harden/install-aide.bash
```
6. Compose the reverse proxy via the ```reverse_proxy/docker-compose.ym```` file.
7. Compose the helloworld service via the ```services/helloworld/docker-compose.yml``` file.
8. Add the following to your main/host machines ```/etc/hosts``` file:
```
<ip.of.vm> helloworld.com
```
9. 💫 Test & Hack 💫

### Certbot
files will be stored at ``/etc/letsencrypt/live/yourdomain.com``
```
# create certificate
sudo certbot certonly

# configure autorenewal
sudo certbot renew --dry-run
```

## 🥪 Dependencies

- [Certbot](https://github.com/certbot/certbot)
- [Modsecurity](https://hub.docker.com/r/owasp/modsecurity-crs/)

## ⚠️ Disclaimer

**Please note that the scripts, configurations, and any accompanying documentation provided in this repository are for personal research use only. They should be used with caution and at your own risk.**

While the scripts and configurations provided here are designed to set up a secure web hosting environment, they may not cover all possible security vulnerabilities or account for specific use cases. It is crucial to thoroughly review and understand the scripts and configurations before deploying them in a production environment.

Additionally, it is important to note that the security landscape is constantly evolving, and new vulnerabilities or best practices may emerge. Therefore, it is highly recommended to stay informed about the latest security practices, regularly update your systems and dependencies, and perform thorough testing and monitoring to ensure the security and stability of your web hosting environment.

The author of this repository disclaim any responsibility for any damages, losses, or risks incurred by the use or misuse of the scripts, configurations, or any other contents of this repository. It is your responsibility to assess the suitability and applicability of the provided materials to your specific use case and to implement appropriate security measures.

Always exercise caution, adhere to security best practices, and seek professional advice if needed when deploying scripts or making changes to your production environment.
