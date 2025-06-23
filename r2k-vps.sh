#!/bin/bash

# Log everything
exec > >(tee -i setup_log.txt)
exec 2>&1

# Colors
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
  echo -e "${YELLOW}Please run as root.${NC}"
  exit 1
fi

# Welcome
echo -e "${CYAN}R2K VPS PRO MENU${NC}"

while true; do
echo ""
echo -e "${GREEN}Choose a setup option:${NC}"
echo "1) Base setup (sudo, tmate, update)"
echo "2) Install Fastfetch"
echo "3) Install Node.js v22 via NVM"
echo "4) Install SSHX"
echo "5) Install Docker"
echo "6) Install Nginx"
echo "7) Setup UFW + Fail2Ban"
echo "8) Install PM2 (Node process manager)"
echo "9) Enable Fastfetch on login"
echo "10) Clean up system"
echo "11) Show system info"
echo "0) Exit"
read -p "Enter choice [0-11]: " choice

case $choice in
1)
    echo -e "${YELLOW}Setting up base packages...${NC}"
    (apt install sudo -y && sudo apt update -y && sudo apt upgrade -y && sudo apt install tmate -y) & spinner
    echo -e "${GREEN}✔ Done${NC}"
    ;;
2)
    echo -e "${YELLOW}Installing Fastfetch...${NC}"
    (
      sudo apt install -y git cmake build-essential libpci-dev libdrm-dev libxcb1-dev libxcb-randr0-dev \
      libxcb-xinerama0-dev libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev \
      libxcb-res0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev zlib1g-dev
      git clone https://github.com/fastfetch-cli/fastfetch.git --depth=1
      cd fastfetch
      mkdir -p build && cd build
      cmake ..
      make -j$(nproc)
      sudo make install
      cd ~
    ) & spinner
    echo -e "${GREEN}✔ Done${NC}"
    ;;
3)
    echo -e "${YELLOW}Installing Node.js v22...${NC}"
    (
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      nvm install 22
      nvm use 22
    ) & spinner
    echo -e "${GREEN}✔ Node.js Installed${NC}"
    ;;
4)
    echo -e "${YELLOW}Installing SSHX...${NC}"
    (curl -sSf https://sshx.io/get | sh) & spinner
    echo -e "${GREEN}✔ Done${NC}"
    ;;
5)
    echo -e "${YELLOW}Installing Docker...${NC}"
    (
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      usermod -aG docker $USER
    ) & spinner
    echo -e "${GREEN}✔ Docker Installed${NC}"
    ;;
6)
    echo -e "${YELLOW}Installing Nginx...${NC}"
    (sudo apt install nginx -y && sudo systemctl enable nginx && sudo systemctl start nginx) & spinner
    echo -e "${GREEN}✔ Nginx Installed${NC}"
    ;;
7)
    echo -e "${YELLOW}Setting up UFW + Fail2Ban...${NC}"
    (
      sudo apt install ufw fail2ban -y
      sudo ufw allow OpenSSH
      sudo ufw allow 80/tcp
      sudo ufw allow 443/tcp
      sudo ufw enable
      sudo systemctl enable fail2ban
      sudo systemctl start fail2ban
    ) & spinner
    echo -e "${GREEN}✔ Security Configured${NC}"
    ;;
8)
    echo -e "${YELLOW}Installing PM2...${NC}"
    (npm install -g pm2 && pm2 startup) & spinner
    echo -e "${GREEN}✔ PM2 Installed${NC}"
    ;;
9)
    echo -e "${YELLOW}Enabling Fastfetch on login...${NC}"
    echo "fastfetch" >> ~/.bashrc
    echo -e "${GREEN}✔ Enabled${NC}"
    ;;
10)
    echo -e "${YELLOW}Cleaning up...${NC}"
    (apt autoremove -y && apt clean) & spinner
    echo -e "${GREEN}✔ Cleaned${NC}"
    ;;
11)
    echo -e "${CYAN}System Info:${NC}"
    fastfetch || echo "Fastfetch not installed."
    ;;
0)
    echo -e "${GREEN}Goodbye!${NC}"
    break
    ;;
*)
    echo -e "${RED}Invalid choice.${NC}"
    ;;
esac
done
