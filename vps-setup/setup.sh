#!/bin/bash

# ================================
# VPS Setup Tool by R2Ksanu
# ================================

# Colors
RED_LIGHT='\033[1;91m'
RED_MEDIUM='\033[1;31m'
RED_DARK='\033[0;31m'
ORANGE_LIGHT='\033[1;93m'
ORANGE_MEDIUM='\033[1;33m'
ORANGE_DARK='\033[0;33m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ================================
# Spinner function (fixed cleanup)
# ================================
spinner() {
    local pid=$1
    local msg=${2:-"Processing..."}
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        local char="${spinstr:$i:1}"
        printf "\r\033[K[%s] %s" "$char" "$msg"
        ((i = (i + 1) % ${#spinstr}))
        sleep $delay
    done
    wait $pid
    local exit_code=$?
    printf "\r\033[K"
    if [[ $exit_code -eq 0 ]]; then
        echo -e "[${GREEN}✔${NC}] Done!"
    else
        echo -e "[${RED_DARK}✗${NC}] Failed! (exit $exit_code)"
    fi
    return $exit_code
}

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
detect_distro() {
    [[ -f /etc/os-release ]] && . /etc/os-release && echo "$ID$VERSION_ID" || echo "unknown"
}

# ================================
# Core Tasks
# ================================
optimize_apt() {
    echo -e "${CYAN}Optimizing APT...${NC}"
    (
        sudo apt update -qq
        sudo apt upgrade -y -qq
        local pkgs=(sudo tmate htop git curl wget unzip ufw fail2ban nginx python3 python3-pip python3-venv certbot python3-certbot-nginx)
        for pkg in "${pkgs[@]}"; do
            if ! is_package_installed "$pkg"; then
                sudo apt install -y -qq "$pkg"
            fi
        done
        sudo apt autoremove -y -qq
        sudo apt autoclean -qq
        sudo apt clean -qq
    ) & spinner "Optimizing packages..."
}

run_fastfetch() {
    if command_exists fastfetch; then echo -e "${GREEN}✔ Fastfetch already installed.${NC}"; return; fi
    (
        sudo add-apt-repository -y ppa:fastfetch-cli/fastfetch >/dev/null 2>&1 || true
        sudo apt update -qq
        sudo apt install -y fastfetch >/dev/null 2>&1 || sudo snap install fastfetch --classic
    ) & spinner "Installing Fastfetch..."
}

run_nodejs() {
    if command_exists node && node --version | grep -q "v22"; then
        echo -e "${GREEN}✔ Node.js v22 already installed.${NC}"; return
    fi
    (
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null 2>&1
        sudo apt install -y nodejs >/dev/null 2>&1
    ) & spinner "Installing Node.js..."
}

run_sshx() { (curl -sSf https://sshx.io/get | sh >/dev/null 2>&1) & spinner "Installing SSHX..."; }
run_docker() {
    if command_exists docker; then echo -e "${GREEN}✔ Docker already installed.${NC}"; return; fi
    (
        curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh >/dev/null 2>&1 && rm get-docker.sh
        sudo usermod -aG docker "$USER"
    ) & spinner "Installing Docker..."
}

run_firewall_fail2ban() {
    (
        sudo apt install -y ufw fail2ban >/dev/null 2>&1
        sudo ufw allow OpenSSH >/dev/null 2>&1
        sudo ufw allow 80/tcp >/dev/null 2>&1
        sudo ufw allow 443/tcp >/dev/null 2>&1
        sudo ufw --force enable >/dev/null 2>&1
        sudo systemctl enable fail2ban >/dev/null 2>&1
        sudo systemctl start fail2ban >/dev/null 2>&1
    ) & spinner "Configuring Firewall & Fail2Ban..."
}

run_pm2() { (sudo npm install -g pm2 >/dev/null 2>&1 && pm2 startup >/dev/null 2>&1) & spinner "Installing PM2..."; }
run_fastfetch_login() { grep -q fastfetch ~/.bashrc || echo "fastfetch" >>~/.bashrc; echo -e "${GREEN}✔ Added Fastfetch to .bashrc${NC}"; }
run_cleanup() { (sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y) & spinner "Cleaning system..."; }
run_sysinfo() { command_exists fastfetch && fastfetch || (neofetch || uname -a && free -h && df -h); }
run_nginx() { (sudo apt install -y nginx >/dev/null 2>&1 && sudo systemctl enable nginx && sudo systemctl start nginx) & spinner "Installing Nginx..."; }

run_google_idx() {
    echo -e "${CYAN}Launching Google IDX Toolkit...${NC}"
    (
        curl -sL https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/Google-IDX/google-idx.sh | bash
    ) & spinner "Launching Google IDX Toolkit..."
}

run_mongodb() {
    if command_exists mongod; then echo -e "${GREEN}✔ MongoDB already installed.${NC}"; return; fi
    (
        wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
        echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] \
        https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc 2>/dev/null || echo jammy)/mongodb-org/7.0 multiverse" \
        | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list >/dev/null
        sudo apt update -qq && sudo apt install -y mongodb-org >/dev/null
        sudo systemctl enable mongod && sudo systemctl start mongod
    ) & spinner "Installing MongoDB..."
}

run_certbot() { (sudo apt install -y certbot python3-certbot-nginx >/dev/null 2>&1) & spinner "Installing Certbot..."; }
run_python_env() { (sudo apt install -y python3 python3-pip python3-venv >/dev/null 2>&1 && python3 -m venv ~/venv) & spinner "Setting up Python Env..."; }

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
