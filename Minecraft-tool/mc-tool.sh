#!/bin/bash

# Define colors
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art (Minecraft Style)
ascii_art="
${ORANGE}███████╗███╗   ███╗ ██████╗      ████████╗ ██████╗  ██████╗ ██╗     
${GREEN}██╔════╝████╗ ████║██╔═══██╗     ╚══██╔══╝██╔═══██╗██╔════╝ ██║     
${ORANGE}█████╗  ██╔████╔██║██║   ██║█████╗  ██║   ██║   ██║██║  ███╗██║     
${GREEN}██╔══╝  ██║╚██╔╝██║██║   ██║╚════╝  ██║   ██║   ██║██║   ██║██║     
${ORANGE}███████╗██║ ╚═╝ ██║╚██████╔╝        ██║   ╚██████╔╝╚██████╔╝███████╗
${GREEN}╚══════╝╚═╝     ╚═╝ ╚═════╝         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
${CYAN}              Minecraft Panel Installer Tool - by R2K
"

clear
echo -e "$ascii_art"

# Check root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

# Utility
port_check() {
  if ss -tuln | grep -q ":$1"; then
    echo -e "${RED}✗ Port $1 is already in use!${NC}"
    exit 1
  else
    echo -e "${GREEN}✓ Port $1 is free.${NC}"
  fi
}

echo_message() {
  echo -e "${ORANGE}[*] $1${NC}"
}

# Skyport Panel Install
install_skyport_panel() {
  port_check 3001
  echo_message "Installing Skyport Panel..."
  apt update
  apt install -y curl software-properties-common git
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
  mkdir -p skyport-panel
  cd skyport-panel || exit 1
  git clone https://github.com/achul123/panel5.git
  cd panel5 || exit 1
  npm install
  npm run seed
  npm run createUser
  npm install -g pm2
  pm2 start index.js
  echo -e "${GREEN}✔ Skyport Panel running on port 3001${NC}"
}

# Skyport Node Install
install_skyport_node() {
  echo_message "Installing Skyport Node..."
  git clone https://github.com/achul123/skyportd.git
  cd skyportd || exit 1
  npm install
  echo_message "Paste your configuration here."
  echo -e "${GREEN}Run with: pm2 start .${NC}"
}

# Draco Panel Install
install_draco_panel() {
  port_check 3001
  echo_message "Installing Draco Panel..."
  apt update
  apt install -y curl software-properties-common git
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
  git clone https://github.com/draco-labes/oversee-fixed.git
  cd oversee-fixed || exit 1
  npm install
  npm run seed
  npm run createUser
  node .
  echo -e "${GREEN}✔ Draco Panel running on port 3000${NC}"
}

# Draco Node Install
install_draco_node() {
  echo_message "Installing Draco Node..."
  git clone https://github.com/hydren-dev/HydraDAEMON.git
  cd HydraDAEMON || exit 1
  npm install
  echo_message "Paste your configuration here."
  echo -e "${GREEN}Run with: node .${NC}"
}

# Pterodactyl Base Install
install_pterodactyl() {
  echo_message "Installing Pterodactyl..."
  bash <(curl -s https://pterodactyl-installer.se)
}

# Blueprint Addon Setup
install_blueprint_addon() {
  echo_message "Installing Blueprint Addon for Pterodactyl..."
  sudo apt-get install -y ca-certificates curl gnupg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  apt-get update
  apt-get install -y nodejs
  npm i -g yarn
  apt install -y zip unzip git curl wget
  cd /var/www/pterodactyl || exit 1
  yarn
  wget https://github.com/BlueprintFramework/framework/releases/download/beta-2024-08/beta-2024-08.zip -O release.zip
  unzip release.zip
  chmod +x blueprint.sh
  bash blueprint.sh
}

# Skyport Submenu
skyport_menu() {
  echo -e "${CYAN}Skyport Options:${NC}"
  echo -e "${ORANGE}[1] Panel Setup"
  echo -e "[2] Node Setup"
  echo -e "[3] Panel and Node Setup"
  read -rp "Enter your choice: " s_opt
  case $s_opt in
    1) install_skyport_panel ;;
    2) install_skyport_node ;;
    3) install_skyport_panel && install_skyport_node ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Draco Submenu
draco_menu() {
  echo -e "${CYAN}Draco Options:${NC}"
  echo -e "${ORANGE}[1] Panel Setup"
  echo -e "[2] Node Setup"
  echo -e "[3] Panel and Node Setup"
  read -rp "Enter your choice: " d_opt
  case $d_opt in
    1) install_draco_panel ;;
    2) install_draco_node ;;
    3) install_draco_panel && install_draco_node ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Pterodactyl Submenu
pterodactyl_menu() {
  echo -e "${CYAN}Pterodactyl Options:${NC}"
  echo -e "${ORANGE}[1] Panel Setup"
  echo -e "[2] Addons Setup"
  echo -e "    [a] Blueprint Setup"
  read -rp "Enter your choice: " p_opt
  case $p_opt in
    1) install_pterodactyl ;;
    2|a|A) install_blueprint_addon ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Main Menu
echo -e "${CYAN}Main Menu:${NC}"
echo -e "${ORANGE}[1] Skyport Panel"
echo -e "[2] Draco Panel"
echo -e "[3] Pterodactyl Panel"
echo -n "Enter your choice: "
read -r main_choice

case "$main_choice" in
  1) skyport_menu ;;
  2) draco_menu ;;
  3) pterodactyl_menu ;;
  *) echo -e "${RED}Invalid option!${NC}" ;;
esac

echo -e "${CYAN}To rerun: chmod +x mc-tool.sh && ./mc-tool.sh${NC}"
