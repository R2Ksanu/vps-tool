#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing Tailscale VPN...${NC}"
(
    curl -fsSL https://tailscale.com/install.sh | sh > /dev/null
    systemctl enable --now tailscaled
) & spinner

echo -e "${GREEN}✔ Tailscale installed and running!${NC}"
echo -e "${YELLOW}Next step: run 'sudo tailscale up' to connect your device.${NC}"
echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
