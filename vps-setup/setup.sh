#!/bin/bash




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
NC='\033[0m' # No Color

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
    if [[ $exit_code -eq 0 ]]; then
        printf "\r\033[K[%s] %s\n" "$(echo -e "${GREEN}✔${NC}")" "Done!"
    else
        printf "\r\033[K[%s] %s (exit code: %d)\n" "$(echo -e "${RED_DARK}✗${NC}")" "Failed!" $exit_code
    fi
    return $exit_code
}


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
    echo -e "${CYAN}💻 Enhanced VPS Tool Setup by R2Ksanu${NC} - Automated & Menu-Driven"
    echo -e "${YELLOW}Features: One-shot APT optimization, New tools (Git, HTOP, Certbot, MongoDB), Animations & Gradients${NC}"
    echo ""
    animate_banner "🚀 Ready to boost your VPS! 🚀"
    sleep 1
}

command_exists() {
    command -v "$1" &> /dev/null
}

is_package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID$VERSION_ID"
    else
        echo "unknown"
    fi
}

optimize_apt() {
    echo -e "${CYAN}Optimizing APT (update, upgrade, install essentials, cleanup)...${NC}"
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


run_base_setup() {
    echo -e "${CYAN}Running base setup (deprecated: use option 1 for full optimize)...${NC}"
    optimize_apt
}

run_fastfetch() {
    if command_exists fastfetch; then
        echo -e "${GREEN}✔ Fastfetch already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing Fastfetch...${NC}"
    (
        sudo add-apt-repository -y ppa:fastfetch-cli/fastfetch >/dev/null 2>&1 || echo "PPA add failed, trying snap..."
        sudo apt update -qq >/dev/null
        sudo apt install -y fastfetch >/dev/null 2>&1 || sudo snap install fastfetch --classic
    ) & spinner "Installing Fastfetch..."
}

run_nodejs() {
    if command_exists node && node --version | grep -q "v22"; then
        echo -e "${GREEN}✔ Node.js v22 already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing Node.js v22 LTS via NodeSource...${NC}"
    (
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null 2>&1
        sudo apt install -y nodejs >/dev/null 2>&1
    ) & spinner "Installing Node.js..."
    echo -e "${GREEN}✔ Node.js v22 installed!${NC}"
}

run_sshx() {
    if command_exists sshx; then
        echo -e "${GREEN}✔ SSHX already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing SSHX...${NC}"
    (curl -sSf https://sshx.io/get | sh >/dev/null 2>&1) & spinner "Installing SSHX..."
}

run_docker() {
    if command_exists docker; then
        echo -e "${GREEN}✔ Docker already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing Docker...${NC}"
    (
        curl -fsSL https://get.docker.com -o get-docker.sh >/dev/null 2>&1
        sh get-docker.sh >/dev/null 2>&1
        rm get-docker.sh
        sudo usermod -aG docker "$USER"
        sudo newgrp docker >/dev/null 2>&1 || true
    ) & spinner "Installing Docker..."
    echo -e "${YELLOW}✔ Docker installed! Re-login or run 'newgrp docker' for group changes.${NC}"
}

run_firewall_fail2ban() {
    if command_exists ufw && sudo ufw status | grep -q "Status: active"; then
        echo -e "${GREEN}✔ UFW already active.${NC}"
    else
        echo -e "${CYAN}Setting up UFW...${NC}"
        (
            sudo apt install -y ufw >/dev/null 2>&1
            sudo ufw allow OpenSSH >/dev/null 2>&1
            sudo ufw allow 80/tcp >/dev/null 2>&1
            sudo ufw allow 443/tcp >/dev/null 2>&1
            sudo ufw --force enable >/dev/null 2>&1
        ) & spinner "Configuring UFW..."
    fi
    if sudo systemctl is-active --quiet fail2ban; then
        echo -e "${GREEN}✔ Fail2Ban already running.${NC}"
    else
        echo -e "${CYAN}Installing and starting Fail2Ban...${NC}"
        (
            sudo apt install -y fail2ban >/dev/null 2>&1
            sudo systemctl enable fail2ban >/dev/null 2>&1
            sudo systemctl start fail2ban >/dev/null 2>&1
        ) & spinner "Setting up Fail2Ban..."
    fi
    echo -e "${GREEN}✔ Firewall and Fail2Ban setup complete!${NC}"
}

run_pm2() {
    if command_exists pm2; then
        echo -e "${GREEN}✔ PM2 already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing PM2...${NC}"
    (sudo npm install -g pm2 >/dev/null 2>&1 && pm2 startup >/dev/null 2>&1) & spinner "Installing PM2..."
    echo -e "${GREEN}✔ PM2 installed!${NC}"
}

run_fastfetch_login() {
    if grep -q "fastfetch" ~/.bashrc; then
        echo -e "${GREEN}✔ Fastfetch already in .bashrc.${NC}"
    else
        echo "fastfetch" >> ~/.bashrc
        echo -e "${GREEN}✔ Fastfetch added to .bashrc.${NC}"
    fi
}

run_cleanup() {
    echo -e "${CYAN}Cleaning up system...${NC}"
    (sudo apt autoremove -y -qq >/dev/null 2>&1 && sudo apt autoclean -qq >/dev/null 2>&1 && sudo apt clean -qq >/dev/null 2>&1) & spinner "Cleaning..."
    echo -e "${GREEN}✔ System cleanup complete!${NC}"
}

run_sysinfo() {
    echo -e "${CYAN}System info:${NC}"
    if command_exists fastfetch; then
        fastfetch
    else
        echo -e "${YELLOW}Fastfetch not available. Run option 2 to install.${NC}"
        neofetch || uname -a && free -h && df -h
    fi
}

run_nginx() {
    if command_exists nginx; then
        echo -e "${GREEN}✔ Nginx already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing Nginx...${NC}"
    (
        sudo apt install -y nginx >/dev/null 2>&1
        sudo systemctl enable nginx >/dev/null 2>&1
        sudo systemctl start nginx >/dev/null 2>&1
    ) & spinner "Installing Nginx..."
    echo -e "${GREEN}✔ Nginx installed and started!${NC}"
}

run_google_idx() {
    echo -e "${CYAN}Setting up Google IDX (via GitHub one-liner)...${NC}"

    (
        curl -sL https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/Google-IDX/17-Google%20IDX-setup.sh | bash 2>&1 | tee /tmp/google-idx-setup.log
    ) & spinner "Running Google IDX setup..."
    echo -e "${YELLOW}✔ Google IDX setup initiated! Check /tmp/google-idx-setup.log for details.${NC}"
   
}

run_mongodb() {
    local distro=$(detect_distro)
    if command_exists mongod; then
        echo -e "${GREEN}✔ MongoDB already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing MongoDB (assuming Ubuntu; adjust for other distros)...${NC}"
    (
        
        wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor >/dev/null 2>&1
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc 2>/dev/null || echo jammy)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list >/dev/null 2>&1
        sudo apt update -qq >/dev/null 2>&1
        sudo apt install -y mongodb-org >/dev/null 2>&1
        sudo systemctl enable mongod >/dev/null 2>&1
        sudo systemctl start mongod >/dev/null 2>&1
    ) & spinner "Installing MongoDB..."
    if sudo systemctl is-active --quiet mongod; then
        echo -e "${GREEN}✔ MongoDB installed and started!${NC}"
    else
        echo -e "${RED_DARK}✗ MongoDB failed to start. Check journalctl -u mongod.${NC}"
    fi
}

run_certbot() {
    if command_exists certbot; then
        echo -e "${GREEN}✔ Certbot already installed.${NC}"
        return 0
    fi
    echo -e "${CYAN}Installing Certbot for SSL...${NC}"
    (sudo apt install -y certbot python3-certbot-nginx >/dev/null 2>&1) & spinner "Installing Certbot..."
    echo -e "${GREEN}✔ Certbot installed! Run 'sudo certbot --nginx' for SSL certs.${NC}"
}

run_python_env() {
    if [[ -d ~/venv ]]; then
        echo -e "${GREEN}✔ Python venv already exists.${NC}"
        return 0
    fi
    echo -e "${CYAN}Setting up Python 3 with venv...${NC}"
    (
        sudo apt install -y python3 python3-pip python3-venv >/dev/null 2>&1
        python3 -m venv ~/venv >/dev/null 2>&1
        source ~/venv/bin/activate >/dev/null 2>&1
        pip install --upgrade pip >/dev/null 2>&1
    ) & spinner "Setting up Python env..."
    echo -e "${GREEN}✔ Python environment setup complete! Activate with 'source ~/venv/bin/activate'${NC}"
}

show_banner

while true; do
    echo -e "${RED_LIGHT}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE_LIGHT}║ ${CYAN}=== VPS Setup Menu by R2Ksanu ===${NC} ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${ORANGE_MEDIUM}║ 1. Base Setup + APT Optimize (One-shot essentials)          ${ORANGE_MEDIUM}║${NC}"
    echo -e "${RED_LIGHT}║ 2. Fastfetch (System info tool)                            ${RED_LIGHT}║${NC}"
    echo -e "${ORANGE_LIGHT}║ 3. Node.js v22 LTS                                        ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}║ 4. SSHX (Collaborative SSH)                                ${RED_MEDIUM}║${NC}"
    echo -e "${ORANGE_MEDIUM}║ 5. Docker (Containerization)                              ${ORANGE_MEDIUM}║${NC}"
    echo -e "${RED_DARK}║ 6. Firewall + Fail2Ban (Security)                          ${RED_DARK}║${NC}"
    echo -e "${ORANGE_DARK}║ 7. PM2 (Process Manager)                                   ${ORANGE_DARK}║${NC}"
    echo -e "${RED_LIGHT}║ 8. Fastfetch on Login                                      ${RED_LIGHT}║${NC}"
    echo -e "${ORANGE_LIGHT}║ 9. System Cleanup                                         ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}║ 10. Sysinfo (Display info)                                 ${RED_MEDIUM}║${NC}"
    echo -e "${ORANGE_MEDIUM}║ 11. Nginx (Web Server)                                    ${ORANGE_MEDIUM}║${NC}"
    echo -e "${RED_DARK}║ 12. Google IDX Setup (GitHub one-liner)                      ${RED_DARK}║${NC}"
    echo -e "${ORANGE_DARK}║ 13. MongoDB (Database)                                     ${ORANGE_DARK}║${NC}"
    echo -e "${RED_LIGHT}║ 14. Certbot SSL (Certificates)                              ${RED_LIGHT}║${NC}"
    echo -e "${ORANGE_LIGHT}║ 15. Python Env (Virtual env)                              ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}║ 0. Exit                                                    ${RED_MEDIUM}║${NC}"
    echo -e "${ORANGE_MEDIUM}╚══════════════════════════════════════════════════════════════╝${NC}"
    read -p "$(echo -e ${CYAN}Enter your choice (0-15): ${NC})" choice

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

    read -p "$(echo -e ${GREEN}Run another script? (y/n): ${NC})" continue
    if [[ ! $continue =~ ^[Yy]$ ]]; then
        echo -e "${PURPLE}🎉 Full setup complete! Consider reboot: sudo reboot${NC}"
        echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
        exit 0
    fi
    echo ""
done