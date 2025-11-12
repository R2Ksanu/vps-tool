#!/usr/bin/env bash
# r2ksanu-toolkit.sh
# Made by R2Ksanu 
set -euo pipefail
IFS=$'\n\t'


GRADIENT=(202 208 214 220 226 220 214 208 160 196)
ORANGE='\033[38;5;208m'
RED='\033[38;5;196m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ASCII_HEADER='
  /$$$$$$                                /$$                 /$$$$$$ /$$$$$$$  /$$   /$$       /$$    /$$ /$$$$$$$                         /$$                         /$$ /$$       /$$   /$$    
 /$$__  $$                              | $$                |_  $$_/| $$__  $$| $$  / $$      | $$   | $$| $$__  $$                       | $$                        | $$| $$      |__/  | $$    
| $$  \__/  /$$$$$$   /$$$$$$   /$$$$$$ | $$  /$$$$$$         | $$  | $$  \ $$|  $$/ $$/      | $$   | $$| $$  \ $$ /$$$$$$$             /$$$$$$    /$$$$$$   /$$$$$$ | $$| $$   /$$ /$$ /$$$$$$  
| $$ /$$$$ /$$__  $$ /$$__  $$ /$$__  $$| $$ /$$__  $$        | $$  | $$  | $$ \  $$$$/       |  $$ / $$/| $$$$$$$//$$_____/            |_  $$_/   /$$__  $$ /$$__  $$| $$| $$  /$$/| $$|_  $$_/  
| $$|_  $$| $$  \ $$| $$  \ $$| $$  \ $$| $$| $$$$$$$$        | $$  | $$  | $$  >$$  $$        \  $$ $$/ | $$____/|  $$$$$$               | $$    | $$  \ $$| $$  \ $$| $$| $$$$$$/ | $$  | $$    
| $$  \ $$| $$  | $$| $$  | $$| $$  | $$| $$| $$_____/        | $$  | $$  | $$ /$$/\  $$        \  $$$/  | $$      \____  $$              | $$ /$$| $$  | $$| $$  | $$| $$| $$_  $$ | $$  | $$ /$$
|  $$$$$$/|  $$$$$$/|  $$$$$$/|  $$$$$$$| $$|  $$$$$$$       /$$$$$$| $$$$$$$/| $$  \ $$         \  $/   | $$      /$$$$$$$/              |  $$$$/|  $$$$$$/|  $$$$$$/| $$| $$ \  $$| $$  |  $$$$/
 \______/  \______/  \______/  \____  $$|__/ \_______/      |______/|_______/ |__/  |__/          \_/    |__/     |_______/                \___/   \______/  \______/ |__/|__/  \__/|__/   \___/  
                               /$$  \ $$                                                                                                                                                          
                              |  $$$$$$/                                                                                                                                                          
                               \______/                                                                                                                                                           
'

log() { printf "%b\n" "$1"; }
err() { printf "%b\n" "${RED}ERROR:${NC} $1" >&2; }

spinner() {
  local pid=$1 msg=${2:-"Working..."}
  local spin='|/-\' i=0
  tput civis 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null; do
    i=$(((i+1)%4))
    printf "\r[${spin:i:1}] %s" "$msg"
    sleep 0.12
  done
  printf "\r%*s\r" "${#msg}" ""
  tput cnorm 2>/dev/null || true
}

print_animated_header() {
  local delay=${1:-0.0015}
  IFS=$'\n' read -r -d '' -a lines <<< "$ASCII_HEADER"$'\0'
  local g_len=${#GRADIENT[@]}
  for l in "${!lines[@]}"; do
    local line="${lines[l]}"
    for ((i=0;i<${#line};i++)); do
      local idx=$(( (i + l) % g_len ))
      printf "\033[38;5;%sm%s\033[0m" "${GRADIENT[idx]}" "${line:i:1}"
      sleep "$delay"
    done
    printf "\n"
  done
  printf "\n"
  printf "%b\n" "${YELLOW}             r2ksanu toolkit${NC}"
  printf "\n"
}

print_static_header() {
  printf "%b\n" "${ORANGE}"
  printf "%s\n" "$ASCII_HEADER"
  printf "%b\n" "${NC}"
  printf "%b\n" "${YELLOW}             r2ksanu toolkit${NC}"
  printf "\n"
}

ensure_root() {
  if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO='sudo'
    else
      err "This installer requires root. Install sudo and re-run as root."
      exit 1
    fi
  else
    SUDO=''
  fi
}

ensure_deps() {
  local needed=(curl git gpg apt-get)
  local to_install=()
  for pkg in "${needed[@]}"; do
    if ! command -v "${pkg%% *}" >/dev/null 2>&1; then
      to_install+=("${pkg}")
    fi
  done
  if (( ${#to_install[@]} )); then
    log "${CYAN}Installing missing base dependencies: ${to_install[*]}${NC}"
    ${SUDO} apt-get update -qq
    ${SUDO} apt-get install -y "${to_install[@]}"
  fi
}

module_google_idx() {
  cat > dev.nix <<'EOF'
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = [
    pkgs.unzip
    pkgs.openssh
    pkgs.git
    pkgs.qemu_kvm
    pkgs.sudo
    pkgs.cdrkit
    pkgs.cloud-utils
    pkgs.qemu
  ];
  env = {};
  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    workspace = {
      onCreate = { };
    };
    previews = {
      enable = false;
    };
  };
}
EOF
  log "${GREEN}✔ dev.nix created at: $(pwd)/dev.nix${NC}"
}

module_tailscale() {
  log "${CYAN}Installing Tailscale...${NC}"
  if ! command -v tailscale >/dev/null 2>&1; then
    bash -c "curl -fsSL https://tailscale.com/install.sh | sh" &
    spinner $! "Downloading & installing tailscale..."
  else
    log "${YELLOW}Tailscale already installed.${NC}"
  fi
  ${SUDO} systemctl enable --now tailscaled || log "${YELLOW}Could not enable tailscaled (maybe systemd not present)${NC}"
  log "${GREEN}✔ Tailscale ready. Run 'sudo tailscale up' to connect.${NC}"
}

module_playit() {
  log "${CYAN}Installing Playit.gg...${NC}"
  ${SUDO} apt-get update -qq
  ${SUDO} apt-get install -y sudo curl gpg apt-transport-https ca-certificates
  curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | ${SUDO} tee /etc/apt/sources.list.d/playit-cloud.list
  ${SUDO} apt-get update -qq
  ${SUDO} apt-get install -y playit
  ${SUDO} systemctl enable --now playit || log "${YELLOW}Could not enable playit service.${NC}"
  log "${GREEN}✔ Playit.gg installed. Run 'sudo playit setup' to link a tunnel.${NC}"
}

module_24_7() {
  log "${CYAN}Installing enhanced 24-7 Python script...${NC}"
  ${SUDO} apt-get update -qq
  ${SUDO} apt-get install -y python3
  cat > /usr/local/bin/24-7.py <<'PYEOF'
#!/usr/bin/env python3
import os, random, string, time
from pathlib import Path
def generate_random_string(length=100):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))
def run_random_command():
    commands=[lambda: os.system('neofetch --config none > /dev/null 2>&1'), lambda: os.system('clear'), lambda: print(f"Current user: {os.getenv('USER','unknown')}"), lambda: None]
    if random.random() < 0.1:
        random.choice(commands)()
def create_edit_delete_file():
    base_folder = Path("/var/tmp/24-7")
    base_folder.mkdir(exist_ok=True)
    cycle_count = 0
    while True:
        try:
            cycle_count += 1
            file_ext = random.choice(['.txt', '.log', '.tmp'])
            file_name = base_folder / f"{generate_random_string(8)}{file_ext}"
            with open(file_name, 'w') as f:
                for _ in range(random.randint(5, 20)):
                    f.write(generate_random_string(random.randint(20, 120)) + '\n')
            time.sleep(random.uniform(1, 2))
            with open(file_name, 'w') as f:
                for _ in range(random.randint(5, 20)):
                    f.write(generate_random_string(random.randint(20, 120)) + '\n')
            time.sleep(random.uniform(0.5, 1.5))
            try:
                os.remove(file_name)
            except OSError:
                pass
            run_random_command()
            if cycle_count % 10 == 0:
                for old_file in base_folder.glob("*.tmp"):
                    try:
                        old_file.unlink()
                    except:
                        pass
        except Exception as e:
            time.sleep(5)
if __name__ == "__main__":
    create_edit_delete_file()
PYEOF
  ${SUDO} chmod +x /usr/local/bin/24-7.py
  local cron_entry="@reboot /usr/bin/env python3 /usr/local/bin/24-7.py >> /var/log/24-7-cron.log 2>&1 &"
  (crontab -l 2>/dev/null || true) | grep -F "$cron_entry" >/dev/null 2>&1 || ( (crontab -l 2>/dev/null || true; echo "$cron_entry") | crontab - )
  ${SUDO} nohup /usr/bin/env python3 /usr/local/bin/24-7.py >/dev/null 2>&1 &
  log "${GREEN}✔ 24-7 script installed and started. Logs: /var/log/24-7.log${NC}"
}

module_rdp() {
  log "${CYAN}Setting up RDP (XFCE4 + xrdp)...${NC}"
  ${SUDO} apt-get update -qq
  local packages=(xfce4 xfce4-goodies xrdp)
  ${SUDO} apt-get install -y "${packages[@]}"
  local user_home
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  else
    user_home="$HOME"
  fi
  echo "startxfce4" > "${user_home}/.xsession"
  ${SUDO} chmod 644 "${user_home}/.xsession" || true
  ${SUDO} systemctl enable xrdp || log "${YELLOW}Enable xrdp failed${NC}"
  ${SUDO} systemctl start xrdp || log "${YELLOW}Start xrdp failed${NC}"
  log "${GREEN}✔ RDP setup complete. Connect to port 3389 with your user credentials.${NC}"
  log "${YELLOW}Tip: Run 'ip addr show' to find this machine's IP.${NC}"
}


module_vps_hopingboyz() {
  log "${CYAN}Launching VPS Management script by @Hopingboyz...${NC}"
  
  # Raw file URL (not GitHub blob)
  local url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/VPS%20MAKER/VM%20Maker-%40Hopingboyz.sh"
  
  # Run one-liner installer with spinner
  (
    bash <(curl -s "$url") 2>&1 | tee /tmp/vps_hopingboyz.log
  ) & spinner "Running VPS Manager by @Hopingboyz..."
  
  log "${GREEN}✔ VPS Manager executed. Logs available at /tmp/vps_hopingboyz.log${NC}"
}

main_menu() {
  while true; do
    clear
    print_animated_header 0.0008
    printf "%b" "${CYAN}Select an action:${NC}\n\n"
    printf "  %b1%b) %bGoogle IDX dev.nix generator%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b2%b) %bInstall Tailscale VPN%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b3%b) %bInstall Playit.gg tunnel%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b4%b) %bInstall 24-7 background script%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b5%b) %bSetup RDP (XFCE + xrdp)%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b6%b) %bVPS Management by @Hopingboyz (run remote script)%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b7%b) %bShow logs / last few entries%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b0%b) %bExit%b\n\n" "${YELLOW}" "${NC}" "${RED}" "${NC}"
    read -rp $'\e[1;33mChoice:\e[0m ' choice
    case "$choice" in
      1) module_google_idx; read -rp $'\e[1;36mPress Enter to continue...\e[0m' _ ;;
      2) module_tailscale; read -rp $'\e[1;36mPress Enter to continue...\e[0m' _ ;;
      3) module_playit; read -rp $'\e[1;36mPress Enter to continue...\e[0m' _ ;;
      4) module_24_7; read -rp $'\e[1;36mPress Enter to continue...\e[0m' _ ;;
      5) module_rdp; read -rp $'\e[1;36mPress Enter to continue...\e[0m' _ ;;
      6) module_vps_hopingboyz; read -rp $'\e[1;36mPress Enter to continue...\e[0m' _ ;;
      7)
         log "${CYAN}-- last 50 lines of /var/log/24-7.log (if exists) --${NC}"
         ${SUDO} tail -n 50 /var/log/24-7.log 2>/dev/null || log "${YELLOW}No /var/log/24-7.log found.${NC}"
         read -rp $'\e[1;36mPress Enter to continue...\e[0m' _
         ;;
      0) log "${GREEN}Goodbye!${NC}"; exit 0 ;;
      *) log "${RED}Invalid choice${NC}"; sleep 1 ;;
    esac
  done
}

ensure_root
ensure_deps
clear
print_animated_header 0.0008
printf "%b" "${YELLOW}Auto-dependencies installed. Menu will load shortly...${NC}\n"
sleep 0.6
main_menu
