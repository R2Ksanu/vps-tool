#!/bin/bash

# Logging
exec > >(tee -i setup_log.txt)
exec 2>&1

# Colors
RED='\033[1;31m'
ORANGE='\033[1;33m'
GREEN='\033[1;32m'
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

# Gradient ASCII art banner
echo -e "${RED}"
echo "██████╗ ██████╗ ██╗  ██╗     ██╗   ██╗██████╗ ███████╗"
echo -e "${ORANGE}██╔══██╗██╔══██╗██║ ██╔╝     ██║   ██║██╔══██╗██╔════╝"
echo -e "${RED}██████╔╝██████╔╝█████╔╝█████╗██║   ██║██████╔╝█████╗"
echo -e "${ORANGE}██╔═══╝ ██╔══██╗██╔═██╗╚════╝██║   ██║██╔═══╝ ██╔══╝"
echo -e "${RED}██║     ██║  ██║██║  ██╗     ╚██████╔╝██║     ███████╗"
echo -e "${ORANGE}╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝      ╚═════╝ ╚═╝     ╚══════╝"
echo -e "${CYAN}💻 VPS Tool Setup by r2k.org${NC}"

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
        (apt install -qq sudo tmate -y && apt update -qq -y && apt upgrade -qq -y) & spinner
        echo -e "${GREEN}✔ Base setup complete!${NC}"
        ;;
    2)
        echo -e "${CYAN}Installing Fastfetch...${NC}"
        (
            add-apt-repository -y ppa:zhangsongcui3371/fastfetch > /dev/null 2>&1
            apt update -qq > /dev/null
            apt install -y fastfetch > /dev/null
        ) & spinner
        echo -e "${GREEN}✔ Fastfetch installed!${NC}"
        ;;
    3)
        echo -e "${CYAN}Installing Node.js v22...${NC}"
        (
            curl -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash > /dev/null
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install 22 > /dev/null
            nvm use 22 > /dev/null
        ) & spinner
        echo -e "${GREEN}✔ Node.js v22 installed!${NC}"
        ;;
    4)
        echo -e "${CYAN}Installing SSHX...${NC}"
        (curl -sSf https://sshx.io/get | sh > /dev/null) & spinner
        echo -e "${GREEN}✔ SSHX installed!${NC}"
        ;;
    5)
        echo -e "${CYAN}Installing Docker...${NC}"
        (
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh > /dev/null
            usermod -aG docker $USER
        ) & spinner
        echo -e "${GREEN}✔ Docker installed!${NC}"
        ;;
    6)
        echo -e "${CYAN}Installing Nginx...${NC}"
        (apt install nginx -y > /dev/null && systemctl enable nginx && systemctl start nginx) & spinner
        echo -e "${GREEN}✔ Nginx installed!${NC}"
        ;;
    7)
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
        ;;
    8)
        echo -e "${CYAN}Installing PM2...${NC}"
        (npm install -g pm2 > /dev/null && pm2 startup > /dev/null) & spinner
        echo -e "${GREEN}✔ PM2 installed!${NC}"
        ;;
    9)
        echo "fastfetch" >> ~/.bashrc
        echo -e "${GREEN}✔ Fastfetch will run on every login.${NC}"
        ;;
    10)
        echo -e "${CYAN}Cleaning up system...${NC}"
        (apt autoremove -y > /dev/null && apt clean > /dev/null) & spinner
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
