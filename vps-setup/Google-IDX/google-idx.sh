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
info() { printf "%b\n" "${CYAN}${1}${NC}"; }
ok()   { printf "%b\n" "${GREEN}✔ ${1}${NC}"; }
warn() { printf "%b\n" "${YELLOW}⚠ ${1}${NC}"; }
err()  { printf "%b\n" "${RED}ERROR:${NC} ${1}" >&2; }

# ---------------------------
# Spinner
# ---------------------------
_spinner_pid=""
start_spinner() {
  local msg=$1
  printf "%b" "${CYAN}${msg}... ${NC}"
  (
    while :; do
      for c in ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏; do
        printf "%s" "$c"
        sleep 0.1
        printf "\b"
      done
    done
  ) &
  _spinner_pid=$!
}
stop_spinner() {
  if [[ -n "${_spinner_pid}" ]]; then
    kill "$_spinner_pid" >/dev/null 2>&1 || true
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=""
    printf "%b\n" "${GREEN} done.${NC}"
  fi
}

# ---------------------------
# Progress Bar
# ---------------------------
progress_bar() {
  local duration=$1
  local width=40
  local fill_char="#"
  local empty_char="-"

  for ((i=0; i<=duration; i++)); do
    local progress=$((i * width / duration))
    local bar=$(printf "%-${width}s" "#" | cut -c1-$progress)
    printf "\r${CYAN}Progress:${NC} [${GREEN}${bar}${NC}$(printf "%$((width - progress))s" "")] %d%%" $((i * 100 / duration))
    sleep 0.1
  done
  echo ""
}

finish_task() {
  stop_spinner
  progress_bar 40
}

# ---------------------------
# Root & Deps
# ---------------------------
SUDO=''
ensure_root() {
  if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO='sudo'
    else
      err "Run as root or install sudo."
      exit 1
    fi
  fi
}

ensure_deps() {
  local needed=(curl git apt-get)
  local to_install=()
  for pkg in "${needed[@]}"; do
    if ! command -v "${pkg%% *}" >/dev/null 2>&1; then
      to_install+=("${pkg}")
    fi
  done
  if (( ${#to_install[@]} )); then
    info "Installing missing base dependencies..."
    ${SUDO} apt-get update -qq >/dev/null 2>&1
    ${SUDO} apt-get install -y "${to_install[@]}" >/dev/null 2>&1
  fi
  ok "Base dependencies ready"
}

# ---------------------------
# Modules
# ---------------------------
module_google_idx() {
  cat > dev.nix <<'EOF'
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = [ pkgs.unzip pkgs.openssh pkgs.git pkgs.qemu_kvm pkgs.sudo pkgs.cdrkit pkgs.cloud-utils pkgs.qemu ];
  env = {};
  idx = {
    extensions = [ "Dart-Code.flutter" "Dart-Code.dart-code" ];
    workspace = { onCreate = { }; };
    previews.enable = false;
  };
}
EOF
  ok "dev.nix created at: $(pwd)/dev.nix"
  progress_bar 30
}

module_tailscale() {
  info "Installing Tailscale"
  if ! command -v tailscale >/dev/null 2>&1; then
    start_spinner "Installing Tailscale"
    curl -fsSL https://tailscale.com/install.sh | ${SUDO} sh >/dev/null 2>&1
    finish_task
  else
    warn "Tailscale already installed"
  fi
  ${SUDO} systemctl enable --now tailscaled >/dev/null 2>&1 || warn "Could not enable tailscaled"
  ok "Run '${SUDO} tailscale up' to connect"
}

module_playit() {
  info "Installing Playit.gg"
  export DEBIAN_FRONTEND=noninteractive
  start_spinner "Adding Playit repository & installing"
  ${SUDO} apt-get update -qq >/dev/null 2>&1
  ${SUDO} apt-get install -y curl gpg apt-transport-https ca-certificates >/dev/null 2>&1
  curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | ${SUDO} tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null 2>&1
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | ${SUDO} tee /etc/apt/sources.list.d/playit-cloud.list >/dev/null 2>&1
  ${SUDO} apt-get update -qq >/dev/null 2>&1
  ${SUDO} apt-get install -y playit >/dev/null 2>&1 || warn "Playit package may not be available"
  finish_task
  ${SUDO} systemctl enable --now playit >/dev/null 2>&1 || warn "Could not enable playit service"
  ok "Playit installed. Run '${SUDO} playit setup' to link a tunnel"
}

module_24_7() {
  info "Installing 24-7 Python3 background service"
  ${SUDO} apt-get update -qq >/dev/null 2>&1
  ${SUDO} apt-get install -y python3 >/dev/null 2>&1

  start_spinner "Writing /usr/local/bin/24-7.py"
  ${SUDO} mkdir -p /usr/local/bin
  ${SUDO} tee /usr/local/bin/24-7.py >/dev/null <<'PYEOF'
#!/usr/bin/env python3
import os, random, string, time, logging, sys
from pathlib import Path

WORK_DIR = Path("/var/tmp/24-7")
LOG_FILE = Path("/var/log/24-7.log")

LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler(sys.stdout)],
)

def randstr(n=80):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=n))

def make_file():
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    f = WORK_DIR / f"{randstr(8)}.log"
    with f.open('w') as fp:
        for _ in range(random.randint(5, 10)):
            fp.write(randstr() + "\n")
    logging.info(f"Created {f}")
    return f

def delete_file(f):
    try:
        f.unlink()
        logging.info(f"Deleted {f}")
    except Exception as e:
        logging.warning(f"Failed to delete {f}: {e}")

def main():
    logging.info("24-7 service started.")
    while True:
        f = make_file()
        time.sleep(random.uniform(1.0, 2.0))
        delete_file(f)
        time.sleep(random.uniform(1.0, 2.0))

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logging.info("24-7 stopped.")
    except Exception as e:
        logging.exception(e)
PYEOF
  ${SUDO} chmod +x /usr/local/bin/24-7.py
  finish_task

  start_spinner "Creating systemd service"
  ${SUDO} tee /etc/systemd/system/24-7.service >/dev/null <<EOF
[Unit]
Description=24-7 Python background activity
After=network.target

[Service]
ExecStart=/usr/bin/env python3 /usr/local/bin/24-7.py
Restart=always
StandardOutput=append:${LOGFILE}
StandardError=append:${LOGFILE}
User=root

[Install]
WantedBy=multi-user.target
EOF
  ${SUDO} systemctl daemon-reload
  ${SUDO} systemctl enable --now 24-7.service >/dev/null 2>&1 || warn "Could not enable service"
  finish_task
  ok "24-7 Python service installed and running."
}

module_rdp() {
  info "Setting up RDP (XFCE4 + xrdp)"
  export DEBIAN_FRONTEND=noninteractive
  start_spinner "Installing XFCE4 and xrdp"
  ${SUDO} apt-get update -qq >/dev/null 2>&1
  ${SUDO} apt-get install -y xfce4 xfce4-goodies xrdp >/dev/null 2>&1
  finish_task

  local user_home
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  else
    user_home="$HOME"
  fi

  echo "startxfce4" | ${SUDO} tee "${user_home}/.xsession" >/dev/null
  ${SUDO} chmod 644 "${user_home}/.xsession"
  ${SUDO} systemctl enable --now xrdp >/dev/null 2>&1
  ok "RDP ready — connect to port 3389"
  warn "Use 'ip addr show' to find IP"
}

module_vps_hopingboyz() {
  info "Launching VPS Management script by @Hopingboyz"
  local url="https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/VPS%20MAKER/VM%20Maker-%40Hopingboyz.sh"
  bash <(curl -fsSL "$url") || err "Remote script failed"
  ok "VPS Manager executed"
  progress_bar 25
}

# ---------------------------
# Menu UI
# ---------------------------
print_header() {
  clear
  printf "%b\n" "${ORANGE}${ASCII_HEADER}${NC}"
  printf "%b\n" "${YELLOW}             r2ksanu toolkit${NC}\n"
}

main_menu() {
  while true; do
    print_header
    echo -e "${CYAN}Select an action:${NC}\n"
    echo -e "  ${YELLOW}1${NC}) ${GREEN}Google IDX dev.nix generator${NC}"
    echo -e "  ${YELLOW}2${NC}) ${GREEN}Install Tailscale VPN${NC}"
    echo -e "  ${YELLOW}3${NC}) ${GREEN}Install Playit.gg tunnel${NC}"
    echo -e "  ${YELLOW}4${NC}) ${GREEN}Install 24-7 Python background script${NC}"
    echo -e "  ${YELLOW}5${NC}) ${GREEN}Setup RDP (XFCE + xrdp)${NC}"
    echo -e "  ${YELLOW}6${NC}) ${GREEN}VPS Management by @Hopingboyz${NC}"
    echo -e "  ${YELLOW}7${NC}) ${GREEN}Show 24-7 logs (last 50 lines)${NC}"
    echo -e "  ${YELLOW}0${NC}) ${RED}Exit${NC}\n"
    read -rp $'\e[1;33mChoice:\e[0m ' choice || choice=0
    case "$choice" in
      1) module_google_idx ;;
      2) module_tailscale ;;
      3) module_playit ;;
      4) module_24_7 ;;
      5) module_rdp ;;
      6) module_vps_hopingboyz ;;
      7)
         if ${SUDO} test -f "${LOGFILE}"; then
           ${SUDO} tail -n 50 "${LOGFILE}" || warn "Unable to read log"
         else
           warn "No log found at ${LOGFILE}"
         fi
         ;;
      0) ok "Goodbye!"; exit 0 ;;
      *) err "Invalid choice: ${choice}" ;;
    esac
    echo ""
    read -rp $'\e[1;36mPress Enter to continue...\e[0m' _
  done
}

# ---------------------------
# Startup
# ---------------------------
trap 'err "Interrupted."; exit 1' INT TERM
ensure_root
ensure_deps
print_header
info "Dependencies checked. Loading menu..."
sleep 0.5
main_menu
