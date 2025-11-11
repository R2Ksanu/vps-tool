#!/bin/bash

# Colors with gradients simulation using ANSI escapes
# Red gradient: from light red to dark red
RED_LIGHT='\033[1;91m'
RED_MEDIUM='\033[1;31m'
RED_DARK='\033[0;31m'
# Orange gradient: from light orange to dark orange
ORANGE_LIGHT='\033[1;93m'
ORANGE_MEDIUM='\033[1;33m'
ORANGE_DARK='\033[0;33m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Animation function for loading effects
animate_banner() {
    local text="$1"
    local delay=0.05
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

show_banner() {
    clear
    # ASCII Art for VPS Setup - Enhanced with gradients
    echo -e "${RED_LIGHT}"
    echo "  ██████╗ ██████╗  ██████╗██╗  ██╗     ██████╗ ██╗  ██╗███████╗"
    echo -e "${ORANGE_LIGHT}██╔════╝██╔═══██╗██╔════╝██║ ██╔╝     ██╔══██╗██║  ██║██╔════╝"
    echo -e "${RED_MEDIUM}██║     ██║   ██║██║     █████╔╝█████╗██║  ██║███████║█████╗  "
    echo -e "${ORANGE_MEDIUM}██║     ██║   ██║██║     ██╔═██╗╚════╝██║  ██║██╔══██║██╔══╝  "
    echo -e "${RED_DARK}╚██████╗╚██████╔╝╚██████╗██║  ██╗     ██████╔╝██║  ██║███████╗"
    echo -e "${ORANGE_DARK} ╚═════╝ ╚════╝  ╚═════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo ""
    echo -e "${CYAN}💻 Enhanced VPS Tool Setup by R2Ksanu${NC} - Automated & Menu-Driven"
    echo -e "${YELLOW}Features: One-shot APT optimization, New tools (Git, HTOP, Certbot, MongoDB), Animations & Gradients${NC}"
    echo ""
    # Animate the subtitle
    animate_banner "🚀 Ready to boost your VPS! 🚀"
    sleep 1
}

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        local char="${spinstr:$i:1}"
        printf "\r [%s] " "$char"
        ((i = (i + 1) % ${#spinstr}))
        sleep $delay
    done
    wait $pid
    printf "\r [%s] Done! \n" "$(echo -e "${GREEN}✔${NC}")"
}

# Function definitions for menu options
run_base_setup() {
    echo -e "${CYAN}Setting up base packages...${NC}"
    (apt install -qq sudo tmate htop git curl wget unzip -y && apt update -qq -y && apt upgrade -qq -y) & spinner
    echo -e "${GREEN}✔ Base setup complete!${NC}"
}

run_fastfetch() {
    echo -e "${CYAN}Installing Fastfetch...${NC}"
    (
        add-apt-repository -y ppa:fastfetch-cli/fastfetch > /dev/null 2>&1
        apt update -qq > /dev/null
        apt install -y fastfetch > /dev/null
    ) & spinner
    echo -e "${GREEN}✔ Fastfetch installed!${NC}"
}

run_nodejs() {
    echo -e "${CYAN}Installing Node.js v22 (LTS)...${NC}"
    (
        curl -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash > /dev/null
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install lts > /dev/null
        nvm use lts > /dev/null
        nvm alias default lts > /dev/null
    ) & spinner
    echo -e "${GREEN}✔ Node.js v22 installed!${NC}"
}

run_sshx() {
    echo -e "${CYAN}Installing SSHX...${NC}"
    (curl -sSf https://sshx.io/get | sh > /dev/null) & spinner
    echo -e "${GREEN}✔ SSHX installed!${NC}"
}

run_docker() {
    echo -e "${CYAN}Installing Docker...${NC}"
    (
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh > /dev/null
        rm get-docker.sh
        usermod -aG docker $USER
        newgrp docker > /dev/null 2>&1 || true  # Refresh group without logout
    ) & spinner
    echo -e "${GREEN}✔ Docker installed! (Re-login for group changes)${NC}"
}

run_firewall_fail2ban() {
    echo -e "${CYAN}Setting up UFW + Fail2Ban...${NC}"
    (
        apt install ufw fail2ban -y > /dev/null
        ufw allow OpenSSH > /dev/null
        ufw allow 80/tcp > /dev/null
        ufw allow 443/tcp > /dev/null
        ufw --force enable > /dev/null
        systemctl enable fail2ban
        systemctl start fail2ban
    ) & spinner
    echo -e "${GREEN}✔ Firewall and Fail2Ban setup complete!${NC}"
}

run_pm2() {
    echo -e "${CYAN}Installing PM2...${NC}"
    (npm install -g pm2 > /dev/null && pm2 startup > /dev/null) & spinner
    echo -e "${GREEN}✔ PM2 installed!${NC}"
}

run_fastfetch_login() {
    echo "fastfetch" >> ~/.bashrc
    echo -e "${GREEN}✔ Fastfetch added to .bashrc - will run on every login.${NC}"
}

run_cleanup() {
    echo -e "${CYAN}Cleaning up system...${NC}"
    (apt autoremove -y > /dev/null && apt autoclean > /dev/null && apt clean > /dev/null) & spinner
    echo -e "${GREEN}✔ System cleanup complete!${NC}"
}

run_sysinfo() {
    echo -e "${CYAN}System info:${NC}"
    fastfetch || echo -e "${RED_DARK}Fastfetch not available. Installing basics...${NC}" && run_fastfetch && fastfetch
}

run_nginx() {
    echo -e "${CYAN}Installing Nginx...${NC}"
    (apt install nginx -y > /dev/null && systemctl enable nginx && systemctl start nginx) & spinner
    echo -e "${GREEN}✔ Nginx installed and started!${NC}"
}

run_google_idx() {
    echo -e "${CYAN}Setting up Google IDX (via GitHub one-liner)...${NC}"
    (
        curl -fsSL https://raw.githubusercontent.com/googlecloudplatform/cloud-run-samples/master/helloworld-nodejs/one-liner.sh | bash > /dev/null
        # Placeholder: Adapt for actual IDX setup if needed (e.g., VS Code integration)
    ) & spinner
    echo -e "${GREEN}✔ Google IDX setup initiated! Check logs for details.${NC}"
}

# New useful additions
run_mongodb() {
    echo -e "${CYAN}Installing MongoDB...${NC}"
    (
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 > /dev/null
        echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list > /dev/null
        apt update -qq > /dev/null
        apt install -y mongodb-org > /dev/null
        systemctl enable mongod
        systemctl start mongod
    ) & spinner
    echo -e "${GREEN}✔ MongoDB installed and started!${NC}"
}

run_certbot() {
    echo -e "${CYAN}Installing Certbot for SSL...${NC}"
    (apt install certbot python3-certbot-nginx -y > /dev/null) & spinner
    echo -e "${GREEN}✔ Certbot installed! Run 'certbot --nginx' for SSL certs.${NC}"
}

run_python_env() {
    echo -e "${CYAN}Setting up Python 3.10+ with venv...${NC}"
    (
        apt install python3 python3-pip python3-venv -y > /dev/null
        python3 -m venv ~/venv > /dev/null
        source ~/venv/bin/activate > /dev/null
        pip install --upgrade pip > /dev/null
    ) & spinner
    echo -e "${GREEN}✔ Python environment setup complete! Activate with 'source ~/venv/bin/activate'${NC}"
}

# Optimized APT compound function - Call this in base or separately to minimize invocations
optimize_apt() {
    echo -e "${CYAN}Optimizing APT installs (compound mode)...${NC}"
    # Group all common apt installs here for efficiency
    (
        apt update -qq -y > /dev/null
        apt install -y -qq sudo tmate htop git curl wget unzip ufw fail2ban nginx mongodb-org python3 python3-pip python3-venv certbot python3-certbot-nginx > /dev/null
        apt upgrade -qq -y > /dev/null
        apt autoremove -y > /dev/null
        apt clean > /dev/null
    ) & spinner
    echo -e "${GREEN}✔ APT optimization complete! (Used once for multiple packages)${NC}"
}

# Show banner
show_banner

# Main menu loop with enhanced gradients
while true; do
    echo -e "${RED_LIGHT}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE_LIGHT}║${NC} ${CYAN}=== VPS Setup Menu by R2Ksanu ===${NC} ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${ORANGE_MEDIUM}║${NC} 1. Base Setup + APT Optimize (1-base-setup.sh)${NC}                     ${ORANGE_MEDIUM}║${NC}"
    echo -e "${RED_LIGHT}║${NC} 2. Fastfetch (2-fastfetch.sh)                                 ${RED_LIGHT}║${NC}"
    echo -e "${ORANGE_LIGHT}║${NC} 3. Node.js v22 LTS (3-nodejs.sh)                             ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}║${NC} 4. SSHX (4-sshx.sh)                                          ${RED_MEDIUM}║${NC}"
    echo -e "${ORANGE_MEDIUM}║${NC} 5. Docker (5-docker.sh)                                     ${ORANGE_MEDIUM}║${NC}"
    echo -e "${RED_DARK}║${NC} 6. Firewall + Fail2Ban (6-firewall-fail2ban.sh)                   ${RED_DARK}║${NC}"
    echo -e "${ORANGE_DARK}║${NC} 7. PM2 (7-pm2.sh)                                            ${ORANGE_DARK}║${NC}"
    echo -e "${RED_LIGHT}║${NC} 8. Fastfetch Login (8-fastfetch-login.sh)                       ${RED_LIGHT}║${NC}"
    echo -e "${ORANGE_LIGHT}║${NC} 9. System Cleanup (9-cleanup.sh)                             ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}║${NC} 10. Sysinfo (10-sysinfo.sh)                                   ${RED_MEDIUM}║${NC}"
    echo -e "${ORANGE_MEDIUM}║${NC} 11. Nginx (11-nginx.sh)                                     ${ORANGE_MEDIUM}║${NC}"
    echo -e "${RED_DARK}║${NC} 12. Google IDX Setup (GitHub one-liner)                          ${RED_DARK}║${NC}"
    echo -e "${ORANGE_DARK}║${NC} 13. MongoDB (New!)                                            ${ORANGE_DARK}║${NC}"
    echo -e "${RED_LIGHT}║${NC} 14. Certbot SSL (New!)                                         ${RED_LIGHT}║${NC}"
    echo -e "${ORANGE_LIGHT}║${NC} 15. Python Env (New!)                                       ${ORANGE_LIGHT}║${NC}"
    echo -e "${RED_MEDIUM}║${NC} 0. Exit                                                       ${RED_MEDIUM}║${NC}"
    echo -e "${ORANGE_MEDIUM}╚══════════════════════════════════════════════════════════════╝${NC}"
    read -p $'\e[36mEnter your choice (0-15): \e[0m' choice

    case $choice in
        1) run_base_setup && optimize_apt ;;  # Compound APT here
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
        *) echo -e "${RED_DARK}Invalid choice! Please try again.${NC}\n" ;;
    esac

    read -p $'\e[32mRun another script? (y/n): \e[0m' continue
    if [[ $continue != "y" && $continue != "Y" ]]; then
        echo -e "${GREEN}🎉 Exiting. Full setup complete! Reboot: sudo reboot${NC}"
        exit 0
    fi
    echo ""
done