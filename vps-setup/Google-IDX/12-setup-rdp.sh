#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Setting up RDP (Remote Desktop Protocol)...${NC}"
(
    apt update -y && apt upgrade -y
    apt install xfce4 xfce4-goodies xrdp -y
    echo "startxfce4" > ~/.xsession
    sudo chown $(whoami):$(whoami) ~/.xsession
    systemctl enable xrdp
    systemctl restart xrdp
) & spinner

echo -e "${GREEN}✔ RDP setup complete!${NC}"
echo -e "${YELLOW}You can now connect using Remote Desktop on port 3389.${NC}"
echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
