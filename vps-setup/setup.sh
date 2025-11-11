#!/bin/bash

# Colors
RED='\033[1;31m'
ORANGE='\033[1;33m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_banner() {
    echo -e "${RED}"
    echo "██████╗ ██████╗ ██╗  ██╗     ██╗   ██╗██████╗ ███████╗"
    echo -e "${ORANGE}██╔══██╗██╔══██╗██║ ██╔╝     ██║   ██║██╔══██╗██╔════╝"
    echo -e "${RED}██████╔╝██████╔╝█████╔╝█████╗██║   ██║██████╔╝█████╗  "
    echo -e "${ORANGE}██╔═══╝ ██╔══██╗██╔═██╗╚════╝██║   ██║██╔═══╝ ██╔══╝  "
    echo -e "${RED}██║     ██║  ██║██║  ██╗     ╚██████╔╝██║     ███████╗"
    echo -e "${ORANGE}╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝      ╚═════╝ ╚═╝     ╚══════╝"
    echo -e "${CYAN}💻 VPS Tool Setup by R2Ksanu${NC}"
    echo ""
}

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to run a local script
run_script() {
    local script_name="$1"
    if [[ -f "$script_name" ]]; then
        echo -e "${GREEN}Running $script_name...${NC}"
        bash "$script_name" &
        spinner
        echo -e "${GREEN}Completed: $script_name${NC}\n"
    else
        echo -e "${RED}Error: $script_name not found!${NC}\n"
    fi
}

# Function for Google IDX setup (one-liner curl)
run_google_idx() {
    echo -e "${YELLOW}Running Google IDX setup from GitHub...${NC}"
    curl -fsSL "https://raw.githubusercontent.com/R2Ksanu/vps-setup/main/Google-IDX/17-Google%20IDX-setup.sh" | bash &
    spinner
    echo -e "${GREEN}Completed: Google IDX setup${NC}\n"
}

# Show banner
show_banner

# Main menu loop
while true; do
    echo -e "${CYAN}=== VPS Setup Menu ===${NC}"
    echo "1. Base Setup (1-base-setup.sh)"
    echo "2. Fastfetch (2-fastfetch.sh)"
    echo "3. NodeJS (3-nodejs.sh)"
    echo "4. SSHX (4-sshx.sh)"
    echo "5. Docker (5-docker.sh)"
    echo "6. Firewall + Fail2Ban (7-firewall-fail2ban.sh)"
    echo "7. PM2 (8-pm2.sh)"
    echo "8. Fastfetch Login (9-fastfetch-login.sh)"
    echo "9. Cleanup (10-cleanup.sh)"
    echo "10. Sysinfo (11-sysinfo.sh)"
    echo "11. Nginx (12-nginx.sh)"
    echo "12. Google IDX Setup (GitHub one-liner)"
    echo "0. Exit"
    echo -e "${CYAN}========================${NC}"
    read -p "Enter your choice (0-12): " choice

    case $choice in
        1) run_script "1-base-setup.sh" ;;
        2) run_script "2-fastfetch.sh" ;;
        3) run_script "3-nodejs.sh" ;;
        4) run_script "4-sshx.sh" ;;
        5) run_script "5-docker.sh" ;;
        6) run_script "7-firewall-fail2ban.sh" ;;
        7) run_script "8-pm2.sh" ;;
        8) run_script "9-fastfetch-login.sh" ;;
        9) run_script "10-cleanup.sh" ;;
        10) run_script "11-sysinfo.sh" ;;
        11) run_script "12-nginx.sh" ;;
        12) run_google_idx ;;
        0) echo -e "${GREEN}Exiting VPS Setup Tool. Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice! Please try again.${NC}\n" ;;
    esac

    read -p "Run another script? (y/n): " continue
    if [[ $continue != "y" && $continue != "Y" ]]; then
        echo -e "${GREEN}Exiting. Goodbye!${NC}"
        exit 0
    fi
    echo ""
done