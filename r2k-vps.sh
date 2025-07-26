#!/bin/bash

# Logging
exec > >(tee -i setup_log.txt)
exec 2>&1

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Spinner
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Root check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Please run this script as root${NC}"
    exit 1
fi

# Title
echo -e "${CYAN}💻 Welcome to vps-tool setup by r2k.org${NC}"

while true; do
    echo -e "\n${YELLOW}Choose an option to install or configure:${NC}"
    echo -e "${CYAN}1)${NC} Base setup (sudo, tmate, apt update/upgrade)"
    echo -e "${CYAN}2)${NC} Install Fastfetch"
    echo -e "${CYAN}3)${NC} Install Node.js v22 (via NVM)"
    echo -e "${CYAN}4)${NC} Install SSHX"
    echo -e "${CYAN}5)${NC} Install Docker"
    echo -e "${CYAN}6)${NC} Install Nginx"
    echo -e "${CYAN}7)${NC} Setup Firewall + Fail2Ban"
    echo -e "${CYAN}8)${NC} Install PM2"
    echo -e "${CYAN}9)${NC} Enable Fastfetch on login"
    echo -e "${CYAN}10)${NC} Clean up system"
    echo -e "${CYAN}11)${NC} Show system info"
    echo -e "${CYAN}0)${NC} Exit"
    echo -ne "${GREEN}Enter your choice: ${NC}"
    read choice

    case $choice in
    1)
        echo -e "${CYAN}Setting up base packages...${NC}"
        (apt install sudo -y && apt update -y && apt upgrade -y && apt install tmate -y) & spinner
        echo -e "${GREEN}✔ Base setup complete!${NC}"
        ;;
    2)
        echo -e "${CYAN}Installing Fastfetch...${NC}"
        (
             add-apt-repository -y ppa:zhangsongcui3371/fastfetch
            apt update
            apt install -y fastfetch
            cd ~
        ) & spinner
        echo -e "${GREEN}✔ Fastfetch installed!${NC}"
        ;;
    3)
        echo -e "${CYAN}Installing Node.js v22...${NC}"
        (
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install 22
            nvm use 22
        ) & spinner
        echo -e "${GREEN}✔ Node.js v22 installed!${NC}"
        ;;
    4)
        echo -e "${CYAN}Installing SSHX...${NC}"
        (curl -sSf https://sshx.io/get | sh) & spinner
        echo -e "${GREEN}✔ SSHX installed!${NC}"
        ;;
    5)
        echo -e "${CYAN}Installing Docker...${NC}"
        (
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            usermod -aG docker $USER
        ) & spinner
        echo -e "${GREEN}✔ Docker installed!${NC}"
        ;;
    6)
        echo -e "${CYAN}Installing Nginx...${NC}"
        (apt install nginx -y && systemctl enable nginx && systemctl start nginx) & spinner
        echo -e "${GREEN}✔ Nginx installed!${NC}"
        ;;
    7)
        echo -e "${CYAN}Setting up UFW + Fail2Ban...${NC}"
        (
            apt install ufw fail2ban -y
            ufw allow OpenSSH
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw --force enable
            systemctl enable fail2ban
            systemctl start fail2ban
        ) & spinner
        echo -e "${GREEN}✔ Firewall and Fail2Ban setup complete!${NC}"
        ;;
    8)
        echo -e "${CYAN}Installing PM2...${NC}"
        (npm install -g pm2 && pm2 startup) & spinner
        echo -e "${GREEN}✔ PM2 installed!${NC}"
        ;;
    9)
        echo "fastfetch" >> ~/.bashrc
        echo -e "${GREEN}✔ Fastfetch will run on every login.${NC}"
        ;;
    10)
        echo -e "${CYAN}Cleaning up system...${NC}"
        (apt autoremove -y && apt clean) & spinner
        echo -e "${GREEN}✔ System cleanup complete!${NC}"
        ;;
    11)
        echo -e "${CYAN}System info:${NC}"
        fastfetch || echo -e "${RED}Fastfetch is not installed.${NC}"
        ;;
    0)
        echo -e "${GREEN}👋 Exit complete. Setup log saved to setup_log.txt${NC}"
        break
        ;;
    *)
        echo -e "${RED}❌ Invalid choice. Try again.${NC}"
        ;;
    esac
done
