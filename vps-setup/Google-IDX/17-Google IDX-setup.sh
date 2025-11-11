#!/bin/bash
# ==========================================================
# Google IDX Sub-Setup Script
# Handles IDX-related tools (RDP, Playit, 24/7, etc.)
# Author: @Hopingboyz & R2Ksanu
# ==========================================================

# Colors (define here if not loaded)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Load includes (relative to main dir)
if [ -f "../includes/spinner.sh" ]; then
    source ../includes/spinner.sh
fi
if [ -f "../includes/banner.sh" ]; then
    source ../includes/banner.sh
fi

clear
show_banner() {
    cat << 'EOF'
  ╔══════════════════════════════════════════════════════════════╗
  ║                 Google IDX Tools Setup                       ║
  ║                 Powered by   R2Ksanu                         ║
  ╚══════════════════════════════════════════════════════════════╝
EOF
}
show_banner

while true; do
    echo -e "\n${YELLOW}Choose a Google IDX tool to install or configure:${NC}"
    echo -e "${CYAN}12)${NC} Setup RDP (Remote Desktop)"
    echo -e "${CYAN}13)${NC} Install & Run 24/7 Python Script"
    echo -e "${CYAN}14)${NC} Setup Playit.gg Tunnel"
    echo -e "${CYAN}15)${NC} Install & Setup Tailscale VPN"
    echo -e "${CYAN}16)${NC} Setup Code Server (VS Code Web)"
    echo -e "${CYAN}17)${NC} VM Maker - @Hopingboyz"
    echo -e "${CYAN}0)${NC} Back to Main Menu"
    echo -ne "${GREEN}Enter your choice: ${NC}"
    read sub_choice

    if [ "$sub_choice" -eq 0 ]; then
        clear
        break
    fi

    google_script="Google IDX/${sub_choice}-"*.sh
    vm_maker="Google IDX/VPS-setup-Google IDX-VM Maker-@Hopingboyz.sh"

    if [ -f "$google_script" ]; then
        bash "$google_script"
    elif [ "$sub_choice" -eq 17 ] && [ -f "$vm_maker" ]; then
        bash "$vm_maker"
    else
        echo -e "${RED}❌ Invalid choice or missing script for option ${sub_choice}.${NC}"
        sleep 2
    fi
done