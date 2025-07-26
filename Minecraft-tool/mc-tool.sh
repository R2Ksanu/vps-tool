#!/bin/bash

# Define colors
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ASCII Art
ascii_art="
${LIGHT_GREEN}███████╗███╗   ███╗ ██████╗      ████████╗ ██████╗  ██████╗ ██╗     
${GREEN}██╔════╝████╗ ████║██╔═══██╗     ╚══██╔══╝██╔═══██╗██╔════╝ ██║     
${LIGHT_GREEN}█████╗  ██╔████╔██║██║   ██║█████╗  ██║   ██║   ██║██║  ███╗██║     
${GREEN}██╔══╝  ██║╚██╔╝██║██║   ██║╚════╝  ██║   ██║   ██║██║   ██║██║     
${LIGHT_GREEN}███████╗██║ ╚═╝ ██║╚██████╔╝        ██║   ╚██████╔╝╚██████╔╝███████╗
${GREEN}╚══════╝╚═╝     ╚═╝ ╚═════╝         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
${CYAN}              Skyport Installer Tool - by R2K
"

# Print art
clear
echo -e "$ascii_art"

# Root check
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root!${NC}"
  exit 1
fi

# Message helper
echo_message() {
  echo -e "${LIGHT_GREEN}[*] $1${NC}"
}

### Install functions for Skyport ###
install_skyport_panel() {
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

  echo -e "${GREEN}✔ Skyport Panel is running on port 3001!${NC}"
}

install_skyport_node() {
  echo_message "Installing Skyport Node..."
  git clone https://github.com/achul123/skyportd.git
  cd skyportd || exit 1
  npm install

  echo_message "Paste your config file and run: pm2 start ."
}

### Placeholder for other panels ###
install_draco_panel() {
  echo_message "Installing Draco Panel..."
  # Add actual install logic here
}

install_pufferfish_panel() {
  echo_message "Installing Pufferfish Panel..."
  # Add actual install logic here
}

install_pterodactyl_panel() {
  echo_message "Installing Pterodactyl Panel..."
  # Add actual install logic here
}

### Skyport submenu ###
skyport_menu() {
  echo -e "${LIGHT_GREEN}Skyport Panel Setup:${NC}"
  echo -e "${GREEN}[1] Panel Setup"
  echo -e "[2] Node Setup"
  echo -n "Enter your choice: "
  read -r subchoice
  case "$subchoice" in
    1) install_skyport_panel ;;
    2) install_skyport_node ;;
    *) echo -e "${RED}Invalid option.${NC}" ;;
  esac
}

### Main menu ###
echo -e "${LIGHT_GREEN}Choose an option:${NC}"
echo -e "${GREEN}[1] Skyport Panel"
echo -e "[2] Draco Panel"
echo -e "[3] Pufferfish Panel"
echo -e "[4] Pterodactyl Panel"
echo -n "Enter your choice: "
read -r choice

case "$choice" in
  1) skyport_menu ;;
  2) install_draco_panel ;;
  3) install_pufferfish_panel ;;
  4) install_pterodactyl_panel ;;
  *) echo -e "${RED}Invalid main option.${NC}" ;;
esac

# Final note
echo -e ""
echo -e "${CYAN}To rerun later:${NC}"
echo -e "${GREEN}chmod +x mc-tool.sh && sudo ./mc-tool.sh${NC}"
