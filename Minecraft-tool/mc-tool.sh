#!/bin/bash

# Define colors
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ASCII Art (Minecraft Style)
ascii_art="
${LIGHT_GREEN}███████╗███╗   ███╗ ██████╗      ████████╗ ██████╗  ██████╗ ██╗     
${GREEN}██╔════╝████╗ ████║██╔═══██╗     ╚══██╔══╝██╔═══██╗██╔════╝ ██║     
${LIGHT_GREEN}█████╗  ██╔████╔██║██║   ██║█████╗  ██║   ██║   ██║██║  ███╗██║     
${GREEN}██╔══╝  ██║╚██╔╝██║██║   ██║╚════╝  ██║   ██║   ██║██║   ██║██║     
${LIGHT_GREEN}███████╗██║ ╚═╝ ██║╚██████╔╝        ██║   ╚██████╔╝╚██████╔╝███████╗
${GREEN}╚══════╝╚═╝     ╚═╝ ╚═════╝         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
${CYAN}                Skyport Installer Tool - by R2K
"

# Print ASCII art
clear
echo -e "$ascii_art"

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

# Function to show messages
echo_message() {
  echo -e "${LIGHT_GREEN}[*] $1${NC}"
}

# Skyport Panel setup
install_panel() {
  echo_message "Installing Dependencies"
  apt update
  apt install -y curl software-properties-common git
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs

  echo_message "Cloning Skyport Panel"
  mkdir -p panel5
  cd panel5 || exit 1
  git clone https://github.com/achul123/panel5.git
  cd panel5 || exit 1
  npm install

  echo_message "Seeding DB and Creating User"
  npm run seed
  npm run createUser

  echo_message "Installing PM2 and Starting Panel"
  npm install -g pm2
  pm2 start index.js

  clear
  echo -e "${LIGHT_GREEN}✔ Skyport Panel installed and running on port 3001!${NC}"
  echo -e "${CYAN}✔ Made by R2K${NC}"
}

# Skyport Node setup
install_node() {
  echo_message "Cloning Skyport Node"
  git clone https://github.com/achul123/skyportd.git
  cd skyportd || exit 1
  npm install

  echo_message "Please paste your configuration into this directory."
  echo_message "You can now run the node with:"
  echo -e "${GREEN}pm2 start .${NC}"
}

# Menu
echo -e "${LIGHT_GREEN}Choose an option below:${NC}"
echo -e "${GREEN}[1] Skyport Panel"
echo -e "[2] Skyport Node"
echo -n "Enter your choice: "
read -r choice

case "$choice" in
  1)
    install_panel
    ;;
  2)
    install_node
    ;;
  *)
    echo -e "${RED}Invalid option! Exiting.${NC}"
    exit 1
    ;;
esac

# Final Instructions
echo -e ""
echo -e "${CYAN}To re-run this script later, use:${NC}"
echo -e "${GREEN}chmod +x mc-tool.sh && sudo ./mc-tool.sh${NC}"
