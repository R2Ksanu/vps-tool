# 🚀 R2K VPS Tool

Welcome to the **R2K VPS Tool**, a robust, all-in-one solution for setting up and managing your Virtual Private Server (VPS) with ease

Designed for **speed**, **simplicity**, and **security**, this tool automates the installation of essential utilities like `tmate`, `fastfetch`, `Node.js`, `Docker`, `Nginx`, and more.

 With a sleek terminal interface featuring gradient ASCII art and loading spinners, it also supports Minecraft server panel installations like **Skyport**, **Draco**, 
 and **Pterodactyl**.

All actions are logged to `setup_log.txt` for transparency and troubleshooting.
---
Powered by r2K



## 🛠️ Installation

Launch the R2K VPS Tool with this simple command:

```bash
bash <(curl -s https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/Root/r2k-tools.sh)

🛡️ Security

Root Check: The script verifies root privileges to prevent unauthorized execution.
Firewall Configuration: Automatically sets up UFW with rules for OpenSSH, HTTP, and HTTPS.
Fail2Ban Protection: Installs and configures Fail2Ban to block malicious login attempts.
Port Validation: Checks for port availability before installing services like Minecraft panels.
