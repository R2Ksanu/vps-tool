#!/bin/bash

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art
ascii_art="
${LIGHT_GREEN}███████╗███╗   ███╗ ██████╗      ████████╗ ██████╗  ██████╗ ██╗     
${GREEN}██╔════╝████╗ ████║██╔═══██╗     ╚══██╔══╝██╔═══██╗██╔════╝ ██║     
${LIGHT_GREEN}█████╗  ██╔████╔██║██║   ██║█████╗  ██║   ██║   ██║██║  ███╗██║     
${GREEN}██╔══╝  ██║╚██╔╝██║██║   ██║╚════╝  ██║   ██║   ██║██║   ██║██║     
${LIGHT_GREEN}███████╗██║ ╚═╝ ██║╚██████╔╝        ██║   ╚██████╔╝╚██████╔╝███████╗
${GREEN}╚══════╝╚═╝     ╚═╝ ╚═════╝         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
${CYAN}                Skyport Installer Tool - by R2K
"

# Show ASCII art
clear
echo -e "$ascii_art"

# Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

# Port checker
check_port() {
  PORT=$1
  if lsof -i ":$PORT" >/dev/null 2>&1; then
    echo -e "${RED}[✘] Port $PORT is already in use!${NC}"
    echo -e "${ORANGE}[!] Please stop the process using that port or choose another.${NC}"
    lsof -i ":$PORT" | grep LISTEN
    exit 1
  else
    echo -e "${GREEN}[✔] Port $PORT is available.${NC}"
  fi
}

# Message echo helper
echo_message() {
  echo -e "${LIGHT_GREEN}[*] $1${NC}"
}

# Skyport Panel install
install_skyport_panel() {
  check_port 3001
  echo_message "Installing Skyport Panel..."
  apt update
  apt install -y curl software-properties-common git
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
  mkdir -p panel5 && cd panel5 || exit 1
  git clone https://github.com/achul123/panel5.git
  cd panel5 || exit 1
  npm install
  npm run seed
  npm run createUser
  npm install -g pm2
  pm2 start index.js
  echo -e "${GREEN}✔ Skyport Panel installed on port 3001!${NC}"
}

# Skyport Node install
install_skyport_node() {
  echo_message "Installing Skyport Node..."
  git clone https://github.com/achul123/skyportd.git
  cd skyportd || exit 1
  npm install
  echo_message "Paste your config and run: pm2 start ."
}

# Draco Panel install
install_draco_panel() {
  check_port 3001
  echo_message "Installing Draco Panel..."
  apt update
  apt install -y curl software-properties-common git
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  apt install -y nodejs
  git clone https://github.com/draco-labes/oversee-fixed.git
  cd oversee-fixed || exit 1
  npm install
  npm run seed
  npm run createUser
  node .
  echo -e "${GREEN}✔ Draco Panel installed on port 3000!${NC}"
}

# Draco Node
install_draco_node() {
  echo_message "Installing Draco Node..."
  git clone https://github.com/hydren-dev/HydraDAEMON
  cd HydraDAEMON || exit 1
  npm install
  echo_message "Paste your config and run: node ."
}

# Skyport Submenu
skyport_menu() {
  echo -e "${LIGHT_GREEN}Skyport Panel Options:${NC}"
  echo -e "${GREEN}[1] Panel Setup"
  echo -e "[2] Node Setup"
  echo -e "[3] Panel and Node Setup"
  read -p "Enter your choice: " subchoice
  case $subchoice in
    1) install_skyport_panel ;;
    2) install_skyport_node ;;
    3)
      install_skyport_panel
      install_skyport_node
      ;;
    *) echo -e "${RED}Invalid option.${NC}" ;;
  esac
}

# Main Menu
echo -e "${LIGHT_GREEN}Main Menu:${NC}"
echo -e "${GREEN}[1] Skyport Panel"
echo -e "[2] Draco Panel"
echo -e "[3] Pufferfish Panel (Coming Soon)"
echo -e "[4] Pterodactyl Panel (Coming Soon)"
echo -n "Enter your choice: "
read -r choice

case "$choice" in
  1) skyport_menu ;;
  2)
    echo -e "${LIGHT_GREEN}Draco Options:${NC}"
    echo -e "${GREEN}[1] Panel Setup"
    echo -e "[2] Node Setup"
    echo -e "[3] Panel and Node Setup"
    read -p "Enter your choice: " dchoice
    case $dchoice in
      1) install_draco_panel ;;
      2) install_draco_node ;;
      3)
        install_draco_panel
        install_draco_node
        ;;
      *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
    ;;
  3|4)
    echo -e "${ORANGE}Coming soon!${NC}" ;;
  *)
    echo -e "${RED}Invalid option!${NC}"
    exit 1 ;;
esac

# Final Instructions
echo -e "\n${CYAN}To re-run this script later, use:${NC}"
echo -e "${GREEN}chmod +x installer.sh && sudo ./installer.sh${NC}"
