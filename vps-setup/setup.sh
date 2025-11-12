#!/bin/bash
# ==============================================================
# 🌐 VPS Setup Tool — Pro Edition by R2Ksanu
# ==============================================================

# 🎨 Colors
RED='\033[1;91m'
YELLOW='\033[1;93m'
GREEN='\033[1;92m'
BLUE='\033[1;94m'
MAGENTA='\033[1;95m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m'

# ==============================================================
# ✨ Animation & UI Helpers
# ==============================================================
animate_text() {
    local text="$1" delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

spinner() {
    local pid=$!
    local spin='|/-\'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYAN}⏳ ${spin:$i:1}${NC}"
        i=$(( (i+1) %4 ))
        sleep 0.1
    done
    printf "\r${GREEN}✔ Done!${NC}\n"
}

progress_bar() {
    local duration=${1:-3}
    local width=30
    local fill="█"
    local empty="░"
    for ((i=0; i<=width; i++)); do
        local percent=$((i * 100 / width))
        printf "\r${MAGENTA}[${CYAN}"
        for ((j=0; j<i; j++)); do printf "${fill}"; done
        for ((j=i; j<width; j++)); do printf "${empty}"; done
        printf "${MAGENTA}] ${WHITE}%3d%%" "$percent"
        sleep "$(bc -l <<< "$duration/$width")"
    done
    echo ""
}

# ==============================================================
# 🚀 Banner
# ==============================================================
show_banner() {
    clear
    echo -e "${RED}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║        🚀 VPS SETUP TOOL — Pro Edition by R2Ksanu       ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    animate_text "${CYAN}💻 Setting up your VPS environment...${NC}" 0.03
    progress_bar 2
    echo ""
}

# ==============================================================
# ⚙️ Utilities
# ==============================================================
command_exists() { command -v "$1" &>/dev/null; }
is_package_installed() { dpkg -l | grep -q "^ii  $1 "; }

# ==============================================================
# 🧩 Core Functions
# ==============================================================

optimize_apt() {
    echo -e "\n${YELLOW}🔄 Optimizing APT and installing base packages...${NC}"
    {
        sudo apt update -y && sudo apt upgrade -y
        local pkgs=(sudo tmate htop git curl wget unzip ufw fail2ban nginx python3 python3-pip python3-venv certbot python3-certbot-nginx)
        for pkg in "${pkgs[@]}"; do
            if ! is_package_installed "$pkg"; then
                echo -e "${BLUE}📦 Installing: ${pkg}${NC}"
                sudo apt install -y "$pkg"
            fi
        done
        sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
    } & spinner
}

run_fastfetch() {
    echo -e "\n${YELLOW}🖥 Installing Fastfetch...${NC}"
    {
        if command_exists fastfetch; then
            echo -e "${GREEN}✔ Already installed.${NC}"
        else
            sudo add-apt-repository -y ppa:fastfetch-cli/fastfetch || true
            sudo apt update && sudo apt install -y fastfetch || sudo snap install fastfetch --classic
        fi
    } & spinner
}

run_nodejs() {
    echo -e "\n${YELLOW}⚡ Installing Node.js v22...${NC}"
    {
        if command_exists node && node --version | grep -q "v22"; then
            echo -e "${GREEN}✔ Node.js v22 already installed.${NC}"
        else
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt install -y nodejs
        fi
    } & spinner
}

run_sshx() {
    echo -e "\n${YELLOW}🔗 Installing SSHX...${NC}"
    { curl -sSf https://sshx.io/get | sh; } & spinner
}

run_docker() {
    echo -e "\n${YELLOW}🐳 Installing Docker...${NC}"
    {
        if command_exists docker; then
            echo -e "${GREEN}✔ Docker already installed.${NC}"
        else
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh && rm get-docker.sh
            sudo usermod -aG docker "$USER"
        fi
    } & spinner
}

run_firewall_fail2ban() {
    echo -e "\n${YELLOW}🛡 Configuring Firewall & Fail2Ban...${NC}"
    {
        sudo apt install -y ufw fail2ban
        sudo ufw allow OpenSSH
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw --force enable
        sudo systemctl enable fail2ban --now
    } & spinner
}

run_pm2() {
    echo -e "\n${YELLOW}🔁 Installing PM2...${NC}"
    { sudo npm install -g pm2 && pm2 startup; } & spinner
}

run_fastfetch_login() {
    echo -e "\n${YELLOW}⚙️ Adding Fastfetch to login...${NC}"
    { grep -q fastfetch ~/.bashrc || echo "fastfetch" >> ~/.bashrc; } & spinner
}

run_cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning system...${NC}"
    { sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y; } & spinner
}

run_sysinfo() {
    echo -e "\n${YELLOW}📊 System Information:${NC}"
    sleep 1
    command_exists fastfetch && fastfetch || neofetch || uname -a
}

run_nginx() {
    echo -e "\n${YELLOW}🌐 Installing Nginx...${NC}"
    { sudo apt install -y nginx && sudo systemctl enable nginx --now; } & spinner
}

run_google_idx() {
    echo -e "\n${YELLOW}🧠 Installing Google IDX Toolkit...${NC}"
    { curl -sL https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/Google-IDX/google-idx.sh | bash; } & spinner
}

run_mongodb() {
    echo -e "\n${YELLOW}🍃 Installing MongoDB...${NC}"
    {
        if command_exists mongod; then
            echo -e "${GREEN}✔ MongoDB already installed.${NC}"
        else
            wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
            echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] \
            https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc 2>/dev/null || echo jammy)/mongodb-org/7.0 multiverse" \
            | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
            sudo apt update && sudo apt install -y mongodb-org
            sudo systemctl enable mongod --now
        fi
    } & spinner
}

run_certbot() {
    echo -e "\n${YELLOW}🔐 Installing Certbot SSL...${NC}"
    { sudo apt install -y certbot python3-certbot-nginx; } & spinner
}

run_python_env() {
    echo -e "\n${YELLOW}🐍 Setting up Python Virtual Environment...${NC}"
    { sudo apt install -y python3 python3-pip python3-venv && python3 -m venv ~/venv; } & spinner
}

# ==============================================================
# 🧭 Main Menu
# ==============================================================
show_banner

while true; do
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                VPS SETUP MENU — R2Ksanu Pro                ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  1.  Base Setup + APT Optimize                             ║"
    echo "║  2.  Fastfetch (System Info Tool)                          ║"
    echo "║  3.  Node.js v22 LTS                                       ║"
    echo "║  4.  SSHX (Collaborative SSH)                              ║"
    echo "║  5.  Docker (Containerization)                             ║"
    echo "║  6.  Firewall + Fail2Ban (Security)                        ║"
    echo "║  7.  PM2 (Process Manager)                                 ║"
    echo "║  8.  Fastfetch on Login                                    ║"
    echo "║  9.  System Cleanup                                        ║"
    echo "║ 10.  Sysinfo (Display Info)                                ║"
    echo "║ 11.  Nginx (Web Server)                                    ║"
    echo "║ 12.  Google IDX Setup (One-liner)                          ║"
    echo "║ 13.  MongoDB (Database)                                    ║"
    echo "║ 14.  Certbot SSL (Certificates)                            ║"
    echo "║ 15.  Python Env (Virtual Env)                              ║"
    echo "║  0.  Exit                                                  ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -ne "${CYAN}Enter your choice (0–15): ${NC}"
    read -r choice

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
        0) echo -e "${GREEN}👋 Exiting VPS Setup Tool. Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid choice! Try again.${NC}" ;;
    esac

    echo -ne "\n${GREEN}🔁 Run another task? (y/n): ${NC}"
    read -r again
    [[ ! $again =~ ^[Yy]$ ]] && {
        echo -e "\n${MAGENTA}🎉 Setup complete! Consider rebooting your VPS.${NC}"
        echo -e "${CYAN}✨ Made with ❤️ by R2Ksanu${NC}"
        exit 0
    }
done
