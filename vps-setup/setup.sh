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

# Function for Base Setup (one-liner curl)
run_base_setup() {
    local filename="1-base-setup.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Base Setup from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Base Setup${NC}\n"
}

# Function for Fastfetch (one-liner curl)
run_fastfetch() {
    local filename="2-fastfetch.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Fastfetch from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Fastfetch${NC}\n"
}

# Function for NodeJS (one-liner curl)
run_nodejs() {
    local filename="3-nodejs.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running NodeJS from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: NodeJS${NC}\n"
}

# Function for SSHX (one-liner curl)
run_sshx() {
    local filename="4-sshx.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running SSHX from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: SSHX${NC}\n"
}

# Function for Docker (one-liner curl)
run_docker() {
    local filename="5-docker.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Docker from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Docker${NC}\n"
}

# Function for Firewall + Fail2Ban (one-liner curl)
run_firewall_fail2ban() {
    local filename="7-firewall-fail2ban.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Firewall + Fail2Ban from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Firewall + Fail2Ban${NC}\n"
}

# Function for PM2 (one-liner curl)
run_pm2() {
    local filename="8-pm2.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running PM2 from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: PM2${NC}\n"
}

# Function for Fastfetch Login (one-liner curl)
run_fastfetch_login() {
    local filename="9-fastfetch-login.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Fastfetch Login from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Fastfetch Login${NC}\n"
}

# Function for Cleanup (one-liner curl)
run_cleanup() {
    local filename="10-cleanup.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Cleanup from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Cleanup${NC}\n"
}

# Function for Sysinfo (one-liner curl)
run_sysinfo() {
    local filename="11-sysinfo.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Sysinfo from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Sysinfo${NC}\n"
}

# Function for Nginx (one-liner curl)
run_nginx() {
    local filename="12-nginx.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Nginx from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
    spinner
    echo -e "${GREEN}Completed: Nginx${NC}\n"
}

# Function for Google IDX setup (one-liner curl)
run_google_idx() {
    local filename="Google-IDX/17-Google%20IDX-setup.sh"
    local base_url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup"
    echo -e "${YELLOW}Running Google IDX setup from GitHub...${NC}"
    curl -sL "${base_url}/${filename}" | bash &
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
        1) run_base_setup ;;
        2) run_fastfetch ;;
        3) run_nodejs ;;
        4) run_sshx ;;
        5) run_docker ;;
        6) run_firewall_fail2ban ;;
        7) run_pm2 ;;
        8) run_fastfetch_login ;;
        9) run_cleanup ;;
        10) run_sysinfo ;;
        11) run_nginx ;;
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