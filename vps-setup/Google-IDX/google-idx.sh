#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ---------------------------
# Colors & Header
# ---------------------------
ORANGE='\033[38;5;208m'
RED='\033[38;5;196m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\e[1m'
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

LOGFILE="/var/log/24-7.log"

# ---------------------------
# Output helpers
# ---------------------------
log()  { printf "%b\n" "$1"; }
info() { printf "%b\n" "${CYAN}${1}${NC}"; }
ok()   { printf "%b\n" "${GREEN}✔ ${1}${NC}"; }
warn() { printf "%b\n" "${YELLOW}⚠ ${1}${NC}"; }
err()  { printf "%b\n" "${RED}ERROR:${NC} ${1}" >&2; }

# ---------------------------
# Spinner & Progress bar
# ---------------------------
_spinner_pid=""
start_spinner() {
  local msg=$1
  local delay=0.08
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  printf "%b" "${CYAN}${msg}... ${NC}"
  (
    while :; do
      for ((i=0;i<${#spinstr};i++)); do
        printf "%s" "${spinstr:i:1}"
        sleep $delay
        printf "\b"
      done
    done
  ) &
  _spinner_pid=$!
  disown
}
stop_spinner() {
  if [[ -n "${_spinner_pid}" ]]; then
    kill "$_spinner_pid" >/dev/null 2>&1 || true
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=""
    printf "%b\n" "${GREEN} done.${NC}"
  fi
}

progress_bar() {
  # usage: progress_bar "Message" seconds
  local msg=$1; local total=${2:-4}
  printf "%b\n" "${CYAN}${msg}${NC}"
  local cols=40
  for ((i=1;i<=total;i++)); do
    local filled=$(( (i*cols)/total ))
    local empty=$((cols-filled))
    printf "\r["
    printf "%0.s#" $(seq 1 $filled)
    printf "%0.s " $(seq 1 $empty)
    printf "] %3d%%" $(( i*100/total ))
    sleep 1
  done
  printf "\n"
}

# ---------------------------
# Ensure root / SUDO
# ---------------------------
SUDO=''
ensure_root() {
  if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO='sudo'
    else
      err "This installer requires root. Install sudo or run as root."
      exit 1
    fi
  fi
}

# ---------------------------
# Ensure base dependencies
# ---------------------------
ensure_deps() {
  local needed=(curl git gpg apt-get)
  local to_install=()
  for pkg in "${needed[@]}"; do
    if ! command -v "${pkg%% *}" >/dev/null 2>&1; then
      to_install+=("${pkg}")
    fi
  done
  if (( ${#to_install[@]} )); then
    info "Installing missing base dependencies: ${to_install[*]}"
    export DEBIAN_FRONTEND=noninteractive
    start_spinner "Updating package lists"
    ${SUDO} apt-get update -qq >/dev/null 2>&1 || { stop_spinner; warn "apt-get update failed"; }
    stop_spinner
    start_spinner "Installing packages: ${to_install[*]}"
    ${SUDO} apt-get install -y "${to_install[@]}" >/dev/null 2>&1 || { stop_spinner; err "Failed to install base packages"; exit 1; }
    stop_spinner
    ok "Base dependencies ready"
  else
    ok "All base dependencies present"
  fi
}

# ---------------------------
# Modules
# ---------------------------
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
  ok "dev.nix created at: $(pwd)/dev.nix"
}

module_tailscale() {
  info "Installing Tailscale"
  if ! command -v tailscale >/dev/null 2>&1; then
    start_spinner "Downloading and installing Tailscale"
    curl -fsSL https://tailscale.com/install.sh | ${SUDO} sh >/dev/null 2>&1 || { stop_spinner; err "Tailscale install failed"; return 1; }
    stop_spinner
  else
    warn "Tailscale already installed"
  fi
  ${SUDO} systemctl enable --now tailscaled 2>/dev/null || warn "Could not enable tailscaled (non-systemd?)"
  ok "Tailscale ready. Run '${SUDO} tailscale up' to connect"
}

module_playit() {
  info "Installing Playit.gg"
  export DEBIAN_FRONTEND=noninteractive
  start_spinner "Adding Playit repository & installing"
  ${SUDO} apt-get update -qq >/dev/null 2>&1 || true
  ${SUDO} apt-get install -y curl gpg apt-transport-https ca-certificates >/dev/null 2>&1 || true
  curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null 2>&1 || true
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | ${SUDO} tee /etc/apt/sources.list.d/playit-cloud.list >/dev/null 2>&1
  ${SUDO} apt-get update -qq >/dev/null 2>&1 || true
  ${SUDO} apt-get install -y playit >/dev/null 2>&1 || { stop_spinner; warn "playit package may not be available in this repo"; }
  stop_spinner
  ${SUDO} systemctl enable --now playit 2>/dev/null || warn "Could not enable playit service"
  ok "Playit installed. Run '${SUDO} playit setup' to link a tunnel"
}

module_24_7() {
  info "Installing 24-7 background script"
  ${SUDO} apt-get update -qq >/dev/null 2>&1 || true
  ${SUDO} apt-get install -y python3 >/dev/null 2>&1 || true

  start_spinner "Writing script to /usr/local/bin/24-7.py"
  ${SUDO} mkdir -p /usr/local/bin
  ${SUDO} tee /usr/local/bin/24-7.py >/dev/null <<'PYEOF'
#!/usr/bin/env python3
import os, random, string, time
from pathlib import Path
def generate_random_string(length=100):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))
def run_random_command():
    commands=[lambda: None, lambda: None]
    if random.random() < 0.05:
        try:
            os.system('neofetch --version > /dev/null 2>&1')
        except:
            pass
def create_edit_delete_file():
    base_folder = Path("/var/tmp/24-7")
    base_folder.mkdir(parents=True, exist_ok=True)
    cycle_count = 0
    while True:
        try:
            cycle_count += 1
            file_ext = random.choice(['.txt', '.log', '.tmp'])
            file_name = base_folder / (generate_random_string(8) + file_ext)
            with open(file_name, 'w') as f:
                for _ in range(random.randint(5, 12)):
                    f.write(generate_random_string(random.randint(20, 120)) + '\n')
            time.sleep(random.uniform(1, 2))
            with open(file_name, 'w') as f:
                for _ in range(random.randint(3, 10)):
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
        except Exception:
            time.sleep(5)
if __name__ == "__main__":
    create_edit_delete_file()
PYEOF
  ${SUDO} chmod +x /usr/local/bin/24-7.py
  stop_spinner

  # Create systemd service
  local svc="[Unit]
Description=24-7 background generator
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/env python3 /usr/local/bin/24-7.py
Restart=always
StandardOutput=append:${LOGFILE}
StandardError=append:${LOGFILE}
User=root

[Install]
WantedBy=multi-user.target
"
  start_spinner "Installing systemd service"
  echo "$svc" | ${SUDO} tee /etc/systemd/system/24-7.service >/dev/null
  ${SUDO} systemctl daemon-reload >/dev/null 2>&1 || true
  ${SUDO} systemctl enable --now 24-7.service >/dev/null 2>&1 || warn "Could not enable 24-7.service"
  stop_spinner
  ok "24-7 script installed and started. Logs: ${LOGFILE}"
}

module_rdp() {
  info "Setting up RDP (XFCE4 + xrdp)"
  export DEBIAN_FRONTEND=noninteractive
  start_spinner "Installing XFCE4 and xrdp"
  ${SUDO} apt-get update -qq >/dev/null 2>&1 || true
  ${SUDO} apt-get install -y xfce4 xfce4-goodies xrdp >/dev/null 2>&1 || { stop_spinner; err "Failed installing RDP packages"; return 1; }
  stop_spinner

  local user_home
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  else
    user_home="$HOME"
  fi

  printf "%s\n" "startxfce4" | ${SUDO} tee "${user_home}/.xsession" >/dev/null || true
  ${SUDO} chmod 644 "${user_home}/.xsession" || true
  ${SUDO} systemctl enable --now xrdp 2>/dev/null || warn "Enable/start xrdp failed"
  ok "RDP setup complete. Connect to port 3389 with your credentials"
  warn "Tip: Run 'ip addr show' to find this machine's IP"
}

module_vps_hopingboyz() {
  info "Launching VPS Management script by @Hopingboyz (GitHub one-liner)"
  # Raw URL to the script on GitHub
  local url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/VPS%20MAKER/VM%20Maker-%40Hopingboyz.sh"
  start_spinner "Downloading & executing remote script"
  # Pipe to bash
  bash <(curl -fsSL "$url") || { stop_spinner; err "Remote script execution failed"; return 1; }
  stop_spinner
  ok "VPS Manager executed"
}

# ---------------------------
# Main Menu
# ---------------------------
print_static_header() {
  clear
  printf "%b\n" "${ORANGE}"
  printf "%s\n" "$ASCII_HEADER"
  printf "%b\n" "${NC}"
  printf "%b\n" "${YELLOW}             r2ksanu toolkit${NC}"
  printf "\n"
}

main_menu() {
  while true; do
    print_static_header
    printf "%b" "${CYAN}Select an action:${NC}\n\n"
    printf "  %b1%b) %bGoogle IDX dev.nix generator%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b2%b) %bInstall Tailscale VPN%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b3%b) %bInstall Playit.gg tunnel%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b4%b) %bInstall 24-7 background script%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b5%b) %bSetup RDP (XFCE + xrdp)%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b6%b) %bVPS Management by @Hopingboyz (GitHub)%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b7%b) %bShow 24-7 logs (last 50 lines)%b\n" "${YELLOW}" "${NC}" "${GREEN}" "${NC}"
    printf "  %b0%b) %bExit%b\n\n" "${YELLOW}" "${NC}" "${RED}" "${NC}"
    read -rp $'\e[1;33mChoice:\e[0m ' choice || choice=0
    case "$choice" in
      1) module_google_idx ;;
      2) module_tailscale ;;
      3) module_playit ;;
      4) module_24_7 ;;
      5) module_rdp ;;
      6) module_vps_hopingboyz ;;
      7)
         if ${SUDO} test -f "${LOGFILE}" >/dev/null 2>&1; then
           ${SUDO} tail -n 50 "${LOGFILE}" || warn "Unable to read log"
         else
           warn "No log found at ${LOGFILE}"
         fi
         ;;
      0) ok "Goodbye!"; exit 0 ;;
      *)
         err "Invalid choice: ${choice}"
         ;;
    esac
    printf "\n"
    read -rp $'\e[1;36mPress Enter to continue...\e[0m' _dummy
  done
}

# ---------------------------
# Startup
# ---------------------------
trap 'err "Interrupted."; exit 1' INT TERM
ensure_root
ensure_deps
print_static_header
info "Dependencies checked. Loading menu..."
sleep 0.5
main_menu

# End of script
