#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Clear the screen
clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

# Display ASCII art
echo -e "${PURPLE}"
cat << "EOF"
            ______   __                                        
           /      \ |  \                                       
  ______  |  $$$$$$\| $$   __      ______    ______    ______  
 /      \  \$$__| $$| $$  /  \    /      \  /      \  /      \ 
|  $$$$$$\ /      $$| $$_/  $$   |  $$$$$$\|  $$$$$$\|  $$$$$$\
| $$   \$$|  $$$$$$ | $$   $$    | $$  | $$| $$   \$$| $$  | $$
| $$      | $$_____ | $$$$$$\  __| $$__/ $$| $$      | $$__| $$
| $$      | $$     \| $$  \$$\|  \\$$    $$| $$       \$$    $$
 \$$       \$$$$$$$$ \$$   \$$ \$$ \$$$$$$  \$$       _\$$$$$$$
                                                     |  \__| $$
                                                      \$$    $$
                                                       \$$$$$$ 
EOF
echo -e "${NC}"

echo -e "${YELLOW}Installing base packages...${NC}"
apt install sudo -y
sudo apt update -y
sudo apt upgrade -y
sudo apt install tmate -y

echo -e "${YELLOW}Installing Fastfetch and dependencies...${NC}"
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

echo -e "${YELLOW}Installing Node.js v22 via NVM...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
nvm use 22

echo -e "${YELLOW}Installing SSHX...${NC}"
curl -sSf https://sshx.io/get | sh

echo -e "${GREEN}Setup complete! Made by r2k.org${NC}"
