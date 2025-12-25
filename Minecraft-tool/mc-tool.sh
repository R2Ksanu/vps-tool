#!/bin/bash


RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' 


ascii_art="
${ORANGE}███████╗███╗   ███╗ ██████╗      ████████╗ ██████╗  ██████╗ ██╗     
${GREEN}██╔════╝████╗ ████║██╔═══██╗     ╚══██╔══╝██╔═══██╗██╔════╝ ██║     
${ORANGE}█████╗  ██╔████╔██║██║   ██║█████╗  ██║   ██║   ██║██║  ███╗██║     
${GREEN}██╔══╝  ██║╚██╔╝██║██║   ██║╚════╝  ██║   ██║   ██║██║   ██║██║     
${ORANGE}███████╗██║ ╚═╝ ██║╚██████╔╝        ██║   ╚██████╔╝╚██████╔╝███████╗
${GREEN}╚══════╝╚═╝     ╚═╝ ╚═════╝         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
${CYAN}              Minecraft Panel Installer Tool - by R2K
"

clear
echo -e "$ascii_art"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi


port_check() {
  if ss -tuln | grep -q ":$1"; then
    echo -e "${RED}✗ Port $1 is already in use!${NC}"
    exit 1
  else
    echo -e "${GREEN}✓ Port $1 is free.${NC}"
  fi
}

echo_message() {
  echo -e "${ORANGE}[*] $1${NC}"
}


install_draco_panel() {
  port_check 3000
  echo_message "Installing Draco Panel..."
  apt update
  apt install -y curl software-properties-common git
  curl -sL https://deb.nodesource.com/setup_20.x | sudo bash -
  apt-get install -y nodejs
  git clone https://github.com/dragonlabsdev/panel-v1.0.0.git
  cd panel-v1.0.0 || exit 1
  npm install
  npm run seed
  npm run createUser
  node .
  echo -e "${GREEN}✔ Draco Panel running on port 3000${NC}"
}


install_draco_node() {
  echo_message "Installing Draco Node..."
  git clone https://github.com/draco-labes/draco-daemon
  cd draco-daemon || exit 1
  npm install
  echo_message "Paste your configuration here."
  echo -e "${GREEN}Run with: node .${NC}"

install_skyport_panel() {
  port_check 3001
  echo_message "Installing Skyport Panel..."
  apt update
  apt install -y curl software-properties-common git
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
  mkdir -p skyport-panel
  cd skyport-panel || exit 1
  git clone https://github.com/achul123/panel5.git
  cd panel5 || exit 1
  npm install
  npm run seed
  npm run createUser
  npm install -g pm2
  pm2 start index.js
  echo -e "${GREEN}✔ Skyport Panel running on port 3001${NC}"
}

install_skyport_node() {
  echo_message "Installing Skyport Node..."
  git clone https://github.com/achul123/skyportd.git
  cd skyportd || exit 1
  npm install
  echo_message "Paste your configuration here."
  echo -e "${GREEN}Run with: pm2 start .${NC}"
}

install_pterodactyl() {
  echo_message "Installing Pterodactyl..."
  bash <(curl -s https://pterodactyl-installer.se)
}


print_header() {
    echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}\n"
}
print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}
animate_progress() {
    pid=$!
    while kill -0 $pid 2>/dev/null; do
        for s in / - \\ \|; do
            printf "\r${CYAN}[$s]${NC} $1..."
            sleep 0.2
        done
    done
    printf "\r${GREEN}[✔]${NC} $1\n"
}
check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
    else
        print_error "$2"
        exit 1
    fi
}

install_r2kteam() {
    print_header "Blueprint installer"
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run this script as root or with sudo"
        return 1
    fi
    print_status "Starting Fresh Install for R2KTeam Hosting"

    print_header "INSTALLING NODE.JS 20.x"
    print_status "Installing required packages"
    apt-get install -y ca-certificates curl gnupg > /dev/null 2>&1 &
    animate_progress $! "Installing dependencies"
    print_status "Setting up Node.js repository"
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
      gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg > /dev/null 2>&1
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | \
      tee /etc/apt/sources.list.d/nodesource.list > /dev/null 2>&1
    print_status "Updating package lists"
    apt-get update > /dev/null 2>&1 &
    animate_progress $! "Updating package lists"
    print_status "Installing Node.js"
    apt-get install -y nodejs > /dev/null 2>&1 &
    animate_progress $! "Installing Node.js"
    check_success "Node.js installed" "Failed to install Node.js"
    print_header "INSTALLING DEPENDENCIES"
    print_status "Installing Yarn"
    npm i -g yarn > /dev/null 2>&1 &
    animate_progress $! "Installing Yarn"
    check_success "Yarn installed" "Failed to install Yarn"
    print_status "Changing to panel directory"
    cd /var/www/pterodactyl || { print_error "Panel directory not found!"; return 1; }
    print_status "Installing Yarn dependencies"
    yarn > /dev/null 2>&1 &
    animate_progress $! "Installing Yarn dependencies"
    check_success "Yarn dependencies installed" "Failed to install Yarn dependencies"
    print_status "Installing additional packages"
    apt install -y zip unzip git curl wget > /dev/null 2>&1 &
    animate_progress $! "Installing additional packages"
    check_success "Additional packages installed" "Failed to install additional packages"
    print_header "DOWNLOADING R2KTEAM HOSTING"
    print_status "Downloading latest release"
    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | \
    grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip > /dev/null 2>&1 &
    animate_progress $! "Downloading release"
    check_success "Release downloaded" "Failed to download release"
    print_status "Extracting release files"
    unzip -o release.zip > /dev/null 2>&1 &
    animate_progress $! "Extracting files"
    check_success "Files extracted" "Failed to extract files"
    print_header "RUNNING BLUEPRINT INSTALLER"
    if [ ! -f "blueprint.sh" ]; then
        print_error "blueprint.sh not found in release package"
        return 1
    fi
    print_status "Making blueprint.sh executable"
    chmod +x blueprint.sh
    check_success "Made executable" "Failed to make executable"
    print_status "Running Blueprint installer"
    bash blueprint.sh
}

reinstall_r2kteam() {
    print_header "REINSTALLING R2KTEAM HOSTING"
    print_status "Starting reinstallation"
    blueprint -rerun-install > /dev/null 2>&1 &
    animate_progress $! "Reinstalling"
    check_success "Reinstallation completed" "Reinstallation failed"
}

update_r2kteam() {
    print_header "UPDATING R2KTEAM HOSTING"
    print_status "Starting update"
    blueprint -upgrade > /dev/null 2>&1 &
    animate_progress $! "Updating"
    check_success "Update completed" "Update failed"
}

# R2KTeam Submenu (replaces old Blueprint)
r2kteam_menu() {
    clear
    echo -e "${BOLD}${CYAN}R2KTeam Hosting Installer${NC}"
    echo -e "${YELLOW}1.${NC} Fresh Install"
    echo -e "${YELLOW}2.${NC} Reinstall"
    echo -e "${YELLOW}3.${NC} Update"
    echo -e "${YELLOW}0.${NC} Back to Main Menu"
    read -rp "Choose an option: " choice
    case $choice in
        1) install_r2kteam ;;
        2) reinstall_r2kteam ;;
        3) update_r2kteam ;;
        0) return ;;
        *) print_error "Invalid choice" ;;
    esac
}

# Skyport Submenu
skyport_menu() {
  echo -e "${CYAN}Skyport Options:${NC}"
  echo -e "${ORANGE}[1] Panel Setup"
  echo -e "[2] Node Setup"
  echo -e "[3] Panel and Node Setup"
  read -rp "Enter your choice: " s_opt
  case $s_opt in
    1) install_skyport_panel ;;
    2) install_skyport_node ;;
    3) install_skyport_panel && install_skyport_node ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Draco Submenu
draco_menu() {
  echo -e "${CYAN}Draco Options:${NC}"
  echo -e "${ORANGE}[1] Panel Setup"
  echo -e "[2] Node Setup"
  echo -e "[3] Panel and Node Setup"
  read -rp "Enter your choice: " d_opt
  case $d_opt in
    1) install_draco_panel ;;
    2) install_draco_node ;;
    3) install_draco_panel && install_draco_node ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Pterodactyl Submenu (Updated to use R2KTeam)
pterodactyl_menu() {
  echo -e "${CYAN}Pterodactyl Options:${NC}"
  echo -e "${ORANGE}[1] Panel Setup"
  echo -e "[2] R2KTeam Hosting Addon"
  read -rp "Enter your choice: " p_opt
  case $p_opt in
    1) install_pterodactyl ;;
    2) r2kteam_menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Main Menu
echo -e "${CYAN}Main Menu:${NC}"
echo -e "${ORANGE}[1] Skyport Panel"
echo -e "[2] Draco Panel"
echo -e "[3] Pterodactyl Panel"
echo -n "Enter your choice: "
read -r main_choice

case "$main_choice" in
  1) skyport_menu ;;
  2) draco_menu ;;
  3) pterodactyl_menu ;;
  *) echo -e "${RED}Invalid option!${NC}" ;;
esac

echo -e "${CYAN}To rerun: chmod +x mc-tool.sh && ./mc-tool.sh${NC}"