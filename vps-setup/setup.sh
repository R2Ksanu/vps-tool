#!/bin/bash

# ================================
# VPS Setup Tool by R2Ksanu
# ================================

# Colors
RED_LIGHT='\033[1;91m'
ORANGE_LIGHT='\033[1;93m'
RED_MEDIUM='\033[1;31m'
ORANGE_MEDIUM='\033[1;33m'
RED_DARK='\033[0;31m'
ORANGE_DARK='\033[0;33m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ================================
# Banner Display
# ================================
animate_banner() {
    local text="$1"
    local delay=0.03
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

show_banner() {
    clear
    echo -e "${RED_LIGHT}  ██████╗ ██████╗  ██████╗██╗  ██╗     ██████╗ ██╗  ██╗███████╗${NC}"
    echo -e "${ORANGE_LIGHT}██╔════╝██╔═══██╗██╔════╝██║ ██╔╝     ██╔══██╗██║  ██║██╔════╝${NC}"
    echo -e "${RED_MEDIUM}██║     ██║   ██║██║     █████╔╝█████╗██║  ██║███████║█████╗  ${NC}"
    echo -e "${ORANGE_MEDIUM}██║     ██║   ██║██║     ██╔═██╗╚════╝██║  ██║██╔══██║██╔══╝  ${NC}"
    echo -e "${RED_DARK}╚██████╗╚██████╔╝╚██████╗██║  ██╗     ██████╔╝██║  ██║███████╗${NC}"
    echo -e "${ORANGE_DARK} ╚═════╝ ╚════╝  ╚═════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚══════╝${NC}"
    echo ""
    echo -e "${CYAN}💻 Enhanced VPS Tool Setup by R2Ksanu${NC}"
    animate_banner "🚀 Ready to boost your VPS! 🚀"
    sleep 1
}

# ================================
# Utility Functions
# ================================
command_exists() { command -v "$1" &>/dev/null; }
is_package_installed() { dpkg -l | grep -q "^ii  $1 "; }

# ================================
# Core Tasks
# ================================
optimize_apt() {
    echo -e "${CYAN}>>> Optimizing APT...${NC}"
    sudo apt update && sudo apt upgrade -y
    local pkgs=(sudo tmate htop git curl wget unzip ufw fail2ban nginx python3 python3-pip python3-venv certbot python3-certbot-nginx)
    for pkg in "${pkgs[@]}"; do
        if ! is_package_installed "$pkg"; then
            echo -e "${ORANGE_LIGHT}Installing: $pkg${NC}"
            sudo apt install -y "$pkg"
        fi
    done
    sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
}

run_fastfetch() {
    echo -e "${CYAN}>>> Installing Fastfetch...${NC}"
    if command_exists fastfetch; then 
        echo -e "${GREEN}✔ Fastfetch already installed.${NC}"; 
        return; 
    fi
    sudo add-apt-repository -y ppa:fastfetch-cli/fastfetch || true
    sudo apt update
    sudo apt install -y fastfetch || sudo snap install fastfetch --classic
}

run_nodejs() {
    echo -e "${CYAN}>>> Installing Node.js v22...${NC}"
    if command_exists node && node --version | grep -q "v22"; then
        echo -e "${GREEN}✔ Node.js v22 already installed.${NC}"
        return
    fi
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
}

run_sshx() {
    echo -e "${CYAN}>>> Installing SSHX...${NC}"
    curl -sSf https://sshx.io/get | sh
}

run_docker() {
    echo -e "${CYAN}>>> Installing Docker...${NC}"
    if command_exists docker; then 
        echo -e "${GREEN}✔ Docker already installed.${NC}"; 
        return
    fi
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "$USER"
}

run_firewall_fail2ban() {
    echo -e "${CYAN}>>> Configuring Firewall & Fail2Ban...${NC}"
    sudo apt install -y ufw fail2ban
    sudo ufw allow OpenSSH
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
}

run_pm2() {
    echo -e "${CYAN}>>> Installing PM2...${NC}"
    sudo npm install -g pm2
    pm2 startup
}

run_fastfetch_login() {
    echo -e "${CYAN}>>> Adding Fastfetch to .bashrc...${NC}"
    grep -q fastfetch ~/.bashrc || echo "fastfetch" >>~/.bashrc
    echo -e "${GREEN}✔ Added Fastfetch to .bashrc${NC}"
}

run_cleanup() {
    echo -e "${CYAN}>>> Cleaning System...${NC}"
    sudo apt autoremove -y
    sudo apt autoclean -y
    sudo apt clean -y
}

run_sysinfo() {
    echo -e "${CYAN}>>> Displaying System Info...${NC}"
    command_exists fastfetch && fastfetch || (neofetch || uname -a && free -h && df -h)
}

run_nginx() {
    echo -e "${CYAN}>>> Installing Nginx...${NC}"
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
}

run_google_idx() {
    echo -e "${CYAN}>>> Launching Google IDX Toolkit...${NC}"
    curl -sL https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/Google-IDX/google-idx.sh | bash
}

run_mongodb() {
    echo -e "${CYAN}>>> Installing MongoDB...${NC}"
    if command_exists mongod; then 
        echo -e "${GREEN}✔ MongoDB already installed.${NC}"
        return
    fi
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] \
    https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc 2>/dev/null || echo jammy)/mongodb-org/7.0 multiverse" \
    | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt update && sudo apt install -y mongodb-org
    sudo systemctl enable mongod
    sudo systemctl start mongod
}

run_certbot() {
    echo -e "${CYAN}>>> Installing Certbot...${NC}"
    sudo apt install -y certbot python3-certbot-nginx
}

run_python_env() {
    echo -e "${CYAN}>>> Setting up Python Virtual Environment...${NC}"
    sudo apt install -y python3 python3-pip python3-venv
    python3 -m venv ~/venv
}

# ================================
# Main Menu
# ================================
show_banner

while true; do
    echo -e "${RED_LIGHT}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE_LIGHT}║ ${CYAN}=== VPS Setup Menu by R2Ksanu ===${NC} ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${ORANGE_MEDIUM}║ 1. Base Setup + APT Optimize                                 ║${NC}"
    echo -e "${RED_LIGHT}║ 2. Fastfetch (System info tool)                              ║${NC}"
    echo -e "${ORANGE_LIGHT}║ 3. Node.js v22 LTS                                           ║${NC}"
    echo -e "${RED_MEDIUM}║ 4. SSHX (Collaborative SSH)                                  ║${NC}"
    echo -e "${ORANGE_MEDIUM}║ 5. Docker (Containerization)                                 ║${NC}"
    echo -e "${RED_DARK}║ 6. Firewall + Fail2Ban (Security)                            ║${NC}"
    echo -e "${ORANGE_DARK}║ 7. PM2 (Process Manager)                                     ║${NC}"
    echo -e "${RED_LIGHT}║ 8. Fastfetch on Login                                        ║${NC}"
    echo -e "${ORANGE_LIGHT}║ 9. System Cleanup                                            ║${NC}"
    echo -e "${RED_MEDIUM}║ 10. Sysinfo (Display info)                                   ║${NC}"
    echo -e "${ORANGE_MEDIUM}║ 11. Nginx (Web Server)                                       ║${NC}"
    echo -e "${RED_DARK}║ 12. Google IDX Setup (GitHub one-liner)                      ║${NC}"
    echo -e "${ORANGE_DARK}║ 13. MongoDB (Database)                                       ║${NC}"
    echo -e "${RED_LIGHT}║ 14. Certbot SSL (Certificates)                               ║${NC}"
    echo -e "${ORANGE_LIGHT}║ 15. Python Env (Virtual Env)                                 ║${NC}"
    echo -e "${RED_MEDIUM}║ 0. Exit                                                      ║${NC}"
    echo -e "${ORANGE_MEDIUM}╚══════════════════════════════════════════════════════════════╝${NC}"

    echo -ne "${CYAN}Enter your choice (0-15): ${NC}"
    read choice

    case $choice in
        1) optimize_apt ;;
        2) run_fastfetch ;;
        3) run_nodejs ;;
        4) run_sshx ;;
        5) run_docker ;;
        6) run_firewall_fail2ban ;;
        7) run_pm2 ;;
        8) run_fastfetch_login ;;
        9) run_cleanup ;;
        10) run_sysinfo ;;
        11) run_nginx ;;
        12) run_google_idx ;;
        13) run_mongodb ;;
        14) run_certbot ;;
        15) run_python_env ;;
        0) echo -e "${GREEN}Exiting VPS Setup Tool. Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED_DARK}Invalid choice! Please try again.${NC}"; sleep 1 ;;
    esac

    echo -ne "${GREEN}Run another script? (y/n): ${NC}"
    read continue
    [[ ! $continue =~ ^[Yy]$ ]] && {
        echo -e "${PURPLE}🎉 Full setup complete! Consider reboot: sudo reboot${NC}"
        echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
        exit 0
    }
done
