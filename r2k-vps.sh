#!/bin/bash

# Name of your setup
SETUP_NAME="vps-tool"

# Log everything
exec > >(tee -i setup_log.txt)
exec 2>&1

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
    echo -e "\n[!] Please run this script as root"
    exit 1
fi

# Auto-install whiptail if missing
if ! command -v whiptail >/dev/null 2>&1; then
    echo "[+] Installing whiptail..."
    apt update -y && apt install whiptail -y
fi

# Intro
whiptail --title "$SETUP_NAME" --msgbox "👋 Welcome to the $SETUP_NAME installer by r2k.org" 10 50

while true; do
    CHOICE=$(whiptail --title "$SETUP_NAME - Main Menu" --menu "Choose what to install or configure:" 20 60 12 \
    "1" "Base setup (sudo, tmate, apt update/upgrade)" \
    "2" "Install Fastfetch (with deps)" \
    "3" "Install Node.js v22 (via NVM)" \
    "4" "Install SSHX (remote access tool)" \
    "5" "Install Docker" \
    "6" "Install Nginx" \
    "7" "Setup UFW Firewall + Fail2Ban" \
    "8" "Install PM2 (Node.js process manager)" \
    "9" "Enable Fastfetch on login" \
    "10" "Clean up system" \
    "11" "Show system info" \
    "0" "Exit" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        break
    fi

    case "$CHOICE" in
    1)
        whiptail --infobox "Installing base packages..." 8 40
        (apt install sudo -y && apt update -y && apt upgrade -y && apt install tmate -y) & spinner
        ;;
    2)
        whiptail --infobox "Installing Fastfetch..." 8 40
        (
            apt install -y git cmake build-essential libpci-dev libdrm-dev libxcb1-dev libxcb-randr0-dev \
            libxcb-xinerama0-dev libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev \
            libxcb-res0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev zlib1g-dev
            git clone https://github.com/fastfetch-cli/fastfetch.git --depth=1
            cd fastfetch
            mkdir -p build && cd build
            cmake ..
            make -j$(nproc)
            make install
            cd ~
        ) & spinner
        ;;
    3)
        whiptail --infobox "Installing Node.js v22..." 8 40
        (
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install 22
            nvm use 22
        ) & spinner
        ;;
    4)
        whiptail --infobox "Installing SSHX..." 8 40
        (curl -sSf https://sshx.io/get | sh) & spinner
        ;;
    5)
        whiptail --infobox "Installing Docker..." 8 40
        (
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            usermod -aG docker $USER
        ) & spinner
        ;;
    6)
        whiptail --infobox "Installing Nginx..." 8 40
        (apt install nginx -y && systemctl enable nginx && systemctl start nginx) & spinner
        ;;
    7)
        whiptail --infobox "Setting up UFW + Fail2Ban..." 8 40
        (
            apt install ufw fail2ban -y
            ufw allow OpenSSH
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw --force enable
            systemctl enable fail2ban
            systemctl start fail2ban
        ) & spinner
        ;;
    8)
        whiptail --infobox "Installing PM2..." 8 40
        (npm install -g pm2 && pm2 startup) & spinner
        ;;
    9)
        echo "fastfetch" >> ~/.bashrc
        whiptail --msgbox "Fastfetch will now run on every login." 8 40
        ;;
    10)
        whiptail --infobox "Cleaning up..." 8 40
        (apt autoremove -y && apt clean) & spinner
        ;;
    11)
        clear
        fastfetch || echo "Fastfetch not installed"
        read -p "Press Enter to return to menu..."
        ;;
    0)
        whiptail --title "$SETUP_NAME" --msgbox "👋 Goodbye! Setup log saved as setup_log.txt" 8 50
        break
        ;;
    esac
done
