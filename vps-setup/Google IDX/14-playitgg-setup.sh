#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing Playit.gg tunnel service...${NC}"
(
    set -e
    apt update -y && apt upgrade -y
    apt install -y sudo curl gpg

    curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | \
      gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null

    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | \
      sudo tee /etc/apt/sources.list.d/playit-cloud.list

    sudo apt update -y
    sudo apt install -y playit
    sudo systemctl enable --now playit
) & spinner

echo -e "${GREEN}✔ Playit.gg installed successfully!${NC}"
echo -e "${YELLOW}Run 'sudo playit setup' to link your tunnel.${NC}"
echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
