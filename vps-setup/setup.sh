#!/bin/bash

# ==========================================================
# VPS Tool Setup Script (Main)
# ==========================================================
# Author: @Hopingboyz
# Version: 3.0
# ==========================================================

# Logging
exec > >(tee -i setup_log.txt)
exec 2>&1

# Load includes
source includes/spinner.sh
source includes/banner.sh

# Root check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Please run this script as root${NC}"
    exit 1
fi

# Banner
show_banner

# Main menu
while true; do
    echo -e "\n${YELLOW}Choose an option to install or configure:${NC}"
    echo -e "${CYAN}1)${NC} Base setup (sudo, tmate, apt update/upgrade)"
    echo -e "${CYAN}2)${NC} Install Fastfetch"
    echo -e "${CYAN}3)${NC} Install Node.js v22 (via NVM)"
    echo -e "${CYAN}4)${NC} Install SSHX"
    echo -e "${CYAN}5)${NC} Install Docker"
    echo -e "${CYAN}6)${NC} Install Nginx"
    echo -e "${CYAN}7)${NC} Setup Firewall + Fail2Ban"
    echo -e "${CYAN}8)${NC} Install PM2"
    echo -e "${CYAN}9)${NC} Enable Fastfetch on login"
    echo -e "${CYAN}10)${NC} Clean up system"
    echo -e "${CYAN}11)${NC} Show system info"
    echo -e "${CYAN}12)${NC} Google IDX Tools → (RDP, Playit, 24/7, VM Maker)"
    echo -e "${CYAN}0)${NC} Exit"
    echo -ne "${GREEN}Enter your choice: ${NC}"
    read choice

    # Exit option
    if [ "$choice" -eq 0 ]; then
        echo -e "${GREEN}👋 Exit complete. Setup log saved to setup_log.txt${NC}"
        break
    fi

    # Define paths for both folders
    option_script="options/${choice}-"*.sh
    google_setup="Google IDX/Google IDX-setup.sh"

    # Run main options or Google IDX setup
    if [ -f $option_script ]; then
        bash "$option_script"
    elif [ "$choice" -eq 12 ] && [ -f "$google_setup" ]; then
        bash "$google_setup"
    else
        echo -e "${RED}❌ Invalid choice. Try again.${NC}"
    fi
done
