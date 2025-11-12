#!/bin/bash
# ============================================
# Ultimate VPS Setup Toolkit - Main Menu
# Combined Multi-VM Manager & Google IDX Tools
# Colors: Full Red & Orange Gradients Theme
# ASCII Art Banner with Animation
# Made by R2Ksanu 💎
# ============================================

set -euo pipefail

# Color Definitions (Red & Orange Gradient Theme)
RED='\033[0;31m'          # Base Red
DARK_RED='\033[0;30m\033[41m' # Dark Red background (for emphasis if needed)
ORANGE='\033[0;33m'       # Base Orange
LIGHT_ORANGE='\033[0;38;5;208m' # Lighter Orange (gradient effect via 256 colors)
YELLOW='\033[1;33m'       # Bright Yellow for accents
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'              # No Color

# Global Paths
VM_DIR="${VM_DIR:-$HOME/vms}"
GOOGLE_IDX_DIR="Google IDX"
INCLUDES_DIR="includes"

# Simple Spinner Animation Function (No external dependency)
spinner() {
    local pid=$!
    local spinstr='|/-\'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(((i+1)%4))
        printf "\r${LIGHT_ORANGE}[%c] %s${NC}" "${spinstr:$i:1}" "$1"
        sleep 0.2
    done
    printf "\r${GREEN}✔ %s - Complete!${NC}\n" "$1"
}

# ASCII Art Banner with Animation Effect
show_banner() {
    clear
    # Simple animation: Print line by line with delay
    local lines=(
        "  ${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        "  ${RED}║${NC}                                                                              ${RED}║${NC}"
        "  ${RED}║${LIGHT_ORANGE}    ██████╗ ██████╗ ███╗   ██╗███████╗     ██████╗ ██████╗  ██████╗ ███████╗${NC} ${RED}║${NC}"
        "  ${RED}║${LIGHT_ORANGE}    ██╔══██╗██╔═══██╗████╗  ██║██╔════╝     ██╔══██╗██╔══██╗██╔═══██╗██╔════╝${NC} ${RED}║${NC}"
        "  ${RED}║${LIGHT_ORANGE}    ██████╔╝██║   ██║██╔██╗ ██║███████╗     ██████╔╝██████╔╝██║   ██║███████╗${NC} ${RED}║${NC}"
        "  ${RED}║${LIGHT_ORANGE}    ██╔══██╗██║   ██║██║╚██╗██║╚════██║     ██╔═══╝ ██╔══██╗██║   ██║╚════██║${NC} ${RED}║${NC}"
        "  ${RED}║${LIGHT_ORANGE}    ██████╔╝╚██████╔╝██║ ╚████║███████║     ██║     ██║  ██║╚██████╔╝███████║${NC} ${RED}║${NC}"
        "  ${RED}║${LIGHT_ORANGE}    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝${NC} ${RED}║${NC}"
        "  ${RED}║${NC}                                                                              ${RED}║${NC}"
        "  ${RED}║${ORANGE}                       Ultimate VPS Setup Toolkit${NC}                    ${RED}║${NC}"
        "  ${RED}║${YELLOW}                           Powered by R2Ksanu 💎${NC}                     ${RED}║${NC}"
        "  ${RED}║${NC}                                                                              ${RED}║${NC}"
        "  ${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    )
    for line in "${lines[@]}"; do
        echo -e "$line"
        sleep 0.1  # Animation delay
    done
    echo -e "\n${ORANGE}Loading tools...${NC}"
    sleep 1
}

# VM Manager Functions (Full integration with theme colors)
display_header() {
    clear
    cat << "EOF"
========================================================================
  _ _ ____ _____ _____ _ _ _____ ____ ______ ________
 | | | |/ __ \| __ \_ _| \ | |/ ____| _ \ / __ \ \ / /___ /
 | |__| | | | | |__) || | | \| | | __| |_) | | | \ \_/ / / /
 | __ | | | | ___/ | | | \ | | |_ | _ <| | | |\ / / /
 | | | | |__| | | _| |_| |\ | |__| | |_) | |__| | | | / /__
 |_| |_|\____/|_| |_____|_| \_|\_____|____/ \____/ |_| /_____|
                                                               
                    POWERED BY HOPINGBOYZ
========================================================================
EOF
    echo
}

print_status() {
    local type=$1
    local message=$2
    case $type in
        "INFO") echo -e "${CYAN}[INFO]${NC} $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "INPUT") echo -e "${LIGHT_ORANGE}[INPUT]${NC} $message" ;;
        *) echo "[$type] $message" ;;
    esac
}

validate_input() {
    local type=$1
    local value=$2

    case $type in
        "number")
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                print_status "ERROR" "Must be a number"
                return 1
            fi
            ;;
        "size")
            if ! [[ "$value" =~ ^[0-9]+[GgMm]$ ]]; then
                print_status "ERROR" "Must be a size with unit (e.g., 100G, 512M)"
                return 1
            fi
            ;;
        "port")
            if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 23 ] || [ "$value" -gt 65535 ]; then
                print_status "ERROR" "Must be a valid port number (23-65535)"
                return 1
            fi
            ;;
        "name")
            if ! [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                print_status "ERROR" "VM name can only contain letters, numbers, hyphens, and underscores"
                return 1
            fi
            ;;
        "username")
            if ! [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                print_status "ERROR" "Username must start with a letter or underscore, and contain only letters, numbers, hyphens, and underscores"
                return 1
            fi
            ;;
    esac
    return 0
}

check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "ERROR" "Missing dependencies: ${missing_deps[*]}"
        print_status "INFO" "On Ubuntu/Debian, try: sudo apt install qemu-system cloud-image-utils wget"
        exit 1
    fi
}

cleanup() {
    if [ -f "user-data" ]; then rm -f "user-data"; fi
    if [ -f "meta-data" ]; then rm -f "meta-data"; fi
}

get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"

    if [[ -f "$config_file" ]]; then
        # Clear previous variables
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED

        source "$config_file"
        return 0
    else
        print_status "ERROR" "Configuration for VM '$vm_name' not found"
        return 1
    fi
}

save_vm_config() {
    local config_file="$VM_DIR/$VM_NAME.conf"

    cat > "$config_file" <<EOF
VM_NAME="$VM_NAME"
OS_TYPE="$OS_TYPE"
CODENAME="$CODENAME"
IMG_URL="$IMG_URL"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
DISK_SIZE="$DISK_SIZE"
MEMORY="$MEMORY"
CPUS="$CPUS"
SSH_PORT="$SSH_PORT"
GUI_MODE="$GUI_MODE"
PORT_FORWARDS="$PORT_FORWARDS"
IMG_FILE="$IMG_FILE"
SEED_FILE="$SEED_FILE"
CREATED="$CREATED"
EOF

    print_status "SUCCESS" "Configuration saved to $config_file"
}

create_new_vm() {
    print_status "INFO" "Creating a new VM"

    # OS Selection
    print_status "INFO" "Select an OS to set up:"
    local os_options=()
    local i=1
    for os in "${!OS_OPTIONS[@]}"; do
        echo " $i) $os"
        os_options[$i]="$os"
        ((i++))
    done

    while true; do
        read -p "$(print_status "INPUT" "Enter your choice (1-${#OS_OPTIONS[@]}): ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#OS_OPTIONS[@]} ]; then
            local os="${os_options[$choice]}"
            IFS='|' read -r OS_TYPE CODENAME IMG_URL DEFAULT_HOSTNAME DEFAULT_USERNAME DEFAULT_PASSWORD <<< "${OS_OPTIONS[$os]}"
            break
        else
            print_status "ERROR" "Invalid selection. Try again."
        fi
    done
    # Custom Inputs with validation
    while true; do
        read -p "$(print_status "INPUT" "Enter VM name (default: $DEFAULT_HOSTNAME): ")" VM_NAME
        VM_NAME="${VM_NAME:-$DEFAULT_HOSTNAME}"
        if validate_input "name" "$VM_NAME"; then
            # Check if VM name already exists
            if [[ -f "$VM_DIR/$VM_NAME.conf" ]]; then
                print_status "ERROR" "VM with name '$VM_NAME' already exists"
            else
                break
            fi
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Enter hostname (default: $VM_NAME): ")" HOSTNAME
        HOSTNAME="${HOSTNAME:-$VM_NAME}"
        if validate_input "name" "$HOSTNAME"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Enter username (default: $DEFAULT_USERNAME): ")" USERNAME
        USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
        if validate_input "username" "$USERNAME"; then
            break
        fi
    done
    while true; do
        read -s -p "$(print_status "INPUT" "Enter password (default: $DEFAULT_PASSWORD): ")" PASSWORD
        PASSWORD="${PASSWORD:-$DEFAULT_PASSWORD}"
        echo
        if [ -n "$PASSWORD" ]; then
            break
        else
            print_status "ERROR" "Password cannot be empty"
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Disk size (default: 20G): ")" DISK_SIZE
        DISK_SIZE="${DISK_SIZE:-20G}"
        if validate_input "size" "$DISK_SIZE"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Memory in MB (default: 2048): ")" MEMORY
        MEMORY="${MEMORY:-2048}"
        if validate_input "number" "$MEMORY"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Number of CPUs (default: 2): ")" CPUS
        CPUS="${CPUS:-2}"
        if validate_input "number" "$CPUS"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "SSH Port (default: 2222): ")" SSH_PORT
        SSH_PORT="${SSH_PORT:-2222}"
        if validate_input "port" "$SSH_PORT"; then
            # Check if port is already in use
            if ss -tln 2>/dev/null | grep -q ":$SSH_PORT "; then
                print_status "ERROR" "Port $SSH_PORT is already in use"
            else
                break
            fi
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Enable GUI mode? (y/n, default: n): ")" gui_input
        GUI_MODE=false
        gui_input="${gui_input:-n}"
        if [[ "$gui_input" =~ ^[Yy]$ ]]; then
            GUI_MODE=true
            break
        elif [[ "$gui_input" =~ ^[Nn]$ ]]; then
            break
        else
            print_status "ERROR" "Please answer y or n"
        fi
    done
    # Additional network options
    read -p "$(print_status "INPUT" "Additional port forwards (e.g., 8080:80, press Enter for none): ")" PORT_FORWARDS
    IMG_FILE="$VM_DIR/$VM_NAME.img"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date)"
    # Download and setup VM image
    setup_vm_image

    # Save configuration
    save_vm_config
}

setup_vm_image() {
    print_status "INFO" "Downloading and preparing image..."

    # Create VM directory if it doesn't exist
    mkdir -p "$VM_DIR"

    # Check if image already exists
    if [[ -f "$IMG_FILE" ]]; then
        print_status "INFO" "Image file already exists. Skipping download."
    else
        print_status "INFO" "Downloading image from $IMG_URL..."
        if ! wget --progress=bar:force "$IMG_URL" -O "$IMG_FILE.tmp"; then
            print_status "ERROR" "Failed to download image from $IMG_URL"
            exit 1
        fi
        mv "$IMG_FILE.tmp" "$IMG_FILE"
    fi

    # Resize the disk image if needed
    if ! qemu-img resize "$IMG_FILE" "$DISK_SIZE" 2>/dev/null; then
        print_status "WARN" "Failed to resize disk image. Creating new image with specified size..."
        # Create a new image with the specified size
        rm -f "$IMG_FILE"
        qemu-img create -f qcow2 -F qcow2 -b "$IMG_FILE" "$IMG_FILE.tmp" "$DISK_SIZE" 2>/dev/null || \
        qemu-img create -f qcow2 "$IMG_FILE" "$DISK_SIZE"
        if [ -f "$IMG_FILE.tmp" ]; then
            mv "$IMG_FILE.tmp" "$IMG_FILE"
        fi
    fi
    # cloud-init configuration
    cat > user-data <<EOF
#cloud-config
hostname: $HOSTNAME
ssh_pwauth: true
disable_root: false
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "$PASSWORD" | tr -d '\n')
chpasswd:
  list: |
    root:$PASSWORD
    $USERNAME:$PASSWORD
  expire: false
EOF
    cat > meta-data <<EOF
instance-id: iid-$VM_NAME
local-hostname: $HOSTNAME
EOF
    if ! cloud-localds "$SEED_FILE" user-data meta-data; then
        print_status "ERROR" "Failed to create cloud-init seed image"
        exit 1
    fi

    print_status "SUCCESS" "VM '$VM_NAME' created successfully."
}

start_vm() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        print_status "INFO" "Starting VM: $vm_name"
        print_status "INFO" "SSH: ssh -p $SSH_PORT $USERNAME@localhost"
        print_status "INFO" "Password: $PASSWORD"

        # Check if image file exists
        if [[ ! -f "$IMG_FILE" ]]; then
            print_status "ERROR" "VM image file not found: $IMG_FILE"
            return 1
        fi

        # Check if seed file exists
        if [[ ! -f "$SEED_FILE" ]]; then
            print_status "WARN" "Seed file not found, recreating..."
            setup_vm_image
        fi

        # Base QEMU command
        local qemu_cmd=(
            qemu-system-x86_64
            -enable-kvm
            -m "$MEMORY"
            -smp "$CPUS"
            -cpu host
            -drive "file=$IMG_FILE,format=qcow2,if=virtio"
            -drive "file=$SEED_FILE,format=raw,if=virtio"
            -boot order=c
            -device virtio-net-pci,netdev=n0
            -netdev "user,id=n0,hostfwd=tcp::$SSH_PORT-:22"
        )
        # Add port forwards if specified
        if [[ -n "$PORT_FORWARDS" ]]; then
            IFS=',' read -ra forwards <<< "$PORT_FORWARDS"
            for forward in "${forwards[@]}"; do
                IFS=':' read -r host_port guest_port <<< "$forward"
                qemu_cmd+=(-device "virtio-net-pci,netdev=n${#qemu_cmd[@]}")
                qemu_cmd+=(-netdev "user,id=n${#qemu_cmd[@]},hostfwd=tcp::$host_port-:$guest_port")
            done
        fi
        # Add GUI or console mode
        if [[ "$GUI_MODE" == true ]]; then
            qemu_cmd+=(-vga virtio -display gtk,gl=on)
        else
            qemu_cmd+=(-nographic -serial mon:stdio)
        fi
        # Add performance enhancements
        qemu_cmd+=(
            -device virtio-balloon-pci
            -object rng-random,filename=/dev/urandom,id=rng0
            -device virtio-rng-pci,rng=rng0
        )
        print_status "INFO" "Starting QEMU..."
        "${qemu_cmd[@]}"

        print_status "INFO" "VM $vm_name has been shut down"
    fi
}

delete_vm() {
    local vm_name=$1

    print_status "WARN" "This will permanently delete VM '$vm_name' and all its data!"
    read -p "$(print_status "INPUT" "Are you sure? (y/N): ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if load_vm_config "$vm_name"; then
            rm -f "$IMG_FILE" "$SEED_FILE" "$VM_DIR/$vm_name.conf"
            print_status "SUCCESS" "VM '$vm_name' has been deleted"
        fi
    else
        print_status "INFO" "Deletion cancelled"
    fi
}

show_vm_info() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        echo
        print_status "INFO" "VM Information: $vm_name"
        echo "=========================================="
        echo "OS: $OS_TYPE"
        echo "Hostname: $HOSTNAME"
        echo "Username: $USERNAME"
        echo "Password: $PASSWORD"
        echo "SSH Port: $SSH_PORT"
        echo "Memory: $MEMORY MB"
        echo "CPUs: $CPUS"
        echo "Disk: $DISK_SIZE"
        echo "GUI Mode: $GUI_MODE"
        echo "Port Forwards: ${PORT_FORWARDS:-None}"
        echo "Created: $CREATED"
        echo "Image File: $IMG_FILE"
        echo "Seed File: $SEED_FILE"
        echo "=========================================="
        echo
        read -p "$(print_status "INPUT" "Press Enter to continue...")"
    fi
}

is_vm_running() {
    local vm_name=$1
    if pgrep -f "qemu-system-x86_64.*$vm_name" >/dev/null; then
        return 0
    else
        return 1
    fi
}

stop_vm() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then
            print_status "INFO" "Stopping VM: $vm_name"
            pkill -f "qemu-system-x86_64.*$IMG_FILE"
            sleep 2
            if is_vm_running "$vm_name"; then
                print_status "WARN" "VM did not stop gracefully, forcing termination..."
                pkill -9 -f "qemu-system-x86_64.*$IMG_FILE"
            fi
            print_status "SUCCESS" "VM $vm_name stopped"
        else
            print_status "INFO" "VM $vm_name is not running"
        fi
    fi
}

edit_vm_config() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        print_status "INFO" "Editing VM: $vm_name"

        while true; do
            echo "What would you like to edit?"
            echo " 1) Hostname"
            echo " 2) Username"
            echo " 3) Password"
            echo " 4) SSH Port"
            echo " 5) GUI Mode"
            echo " 6) Port Forwards"
            echo " 7) Memory (RAM)"
            echo " 8) CPU Count"
            echo " 9) Disk Size"
            echo " 0) Back to main menu"

            read -p "$(print_status "INPUT" "Enter your choice: ")" edit_choice

            case $edit_choice in
                1)
                    while true; do
                        read -p "$(print_status "INPUT" "Enter new hostname (current: $HOSTNAME): ")" new_hostname
                        new_hostname="${new_hostname:-$HOSTNAME}"
                        if validate_input "name" "$new_hostname"; then
                            HOSTNAME="$new_hostname"
                            break
                        fi
                    done
                    ;;
                2)
                    while true; do
                        read -p "$(print_status "INPUT" "Enter new username (current: $USERNAME): ")" new_username
                        new_username="${new_username:-$USERNAME}"
                        if validate_input "username" "$new_username"; then
                            USERNAME="$new_username"
                            break
                        fi
                    done
                    ;;
                3)
                    while true; do
                        read -s -p "$(print_status "INPUT" "Enter new password (current: ****): ")" new_password
                        new_password="${new_password:-$PASSWORD}"
                        echo
                        if [ -n "$new_password" ]; then
                            PASSWORD="$new_password"
                            break
                        else
                            print_status "ERROR" "Password cannot be empty"
                        fi
                    done
                    ;;
                4)
                    while true; do
                        read -p "$(print_status "INPUT" "Enter new SSH port (current: $SSH_PORT): ")" new_ssh_port
                        new_ssh_port="${new_ssh_port:-$SSH_PORT}"
                        if validate_input "port" "$new_ssh_port"; then
                            # Check if port is already in use
                            if [ "$new_ssh_port" != "$SSH_PORT" ] && ss -tln 2>/dev/null | grep -q ":$new_ssh_port "; then
                                print_status "ERROR" "Port $new_ssh_port is already in use"
                            else
                                SSH_PORT="$new_ssh_port"
                                break
                            fi
                        fi
                    done
                    ;;
                5)
                    while true; do
                        read -p "$(print_status "INPUT" "Enable GUI mode? (y/n, current: $GUI_MODE): ")" gui_input
                        gui_input="${gui_input:-}"
                        if [[ "$gui_input" =~ ^[Yy]$ ]]; then
                            GUI_MODE=true
                            break
                        elif [[ "$gui_input" =~ ^[Nn]$ ]]; then
                            GUI_MODE=false
                            break
                        elif [ -z "$gui_input" ]; then
                            # Keep current value if user just pressed Enter
                            break
                        else
                            print_status "ERROR" "Please answer y or n"
                        fi
                    done
                    ;;
                6)
                    read -p "$(print_status "INPUT" "Additional port forwards (current: ${PORT_FORWARDS:-None}): ")" new_port_forwards
                    PORT_FORWARDS="${new_port_forwards:-$PORT_FORWARDS}"
                    ;;
                7)
                    while true; do
                        read -p "$(print_status "INPUT" "Enter new memory in MB (current: $MEMORY): ")" new_memory
                        new_memory="${new_memory:-$MEMORY}"
                        if validate_input "number" "$new_memory"; then
                            MEMORY="$new_memory"
                            break
                        fi
                    done
                    ;;
                8)
                    while true; do
                        read -p "$(print_status "INPUT" "Enter new CPU count (current: $CPUS): ")" new_cpus
                        new_cpus="${new_cpus:-$CPUS}"
                        if validate_input "number" "$new_cpus"; then
                            CPUS="$new_cpus"
                            break
                        fi
                    done
                    ;;
                9)
                    while true; do
                        read -p "$(print_status "INPUT" "Enter new disk size (current: $DISK_SIZE): ")" new_disk_size
                        new_disk_size="${new_disk_size:-$DISK_SIZE}"
                        if validate_input "size" "$new_disk_size"; then
                            DISK_SIZE="$new_disk_size"
                            break
                        fi
                    done
                    ;;
                0)
                    return 0
                    ;;
                *)
                    print_status "ERROR" "Invalid selection"
                    continue
                    ;;
            esac

            # Recreate seed image with new configuration if user/password/hostname changed
            if [[ "$edit_choice" -eq 1 || "$edit_choice" -eq 2 || "$edit_choice" -eq 3 ]]; then
                print_status "INFO" "Updating cloud-init configuration..."
                setup_vm_image
            fi

            # Save configuration
            save_vm_config

            read -p "$(print_status "INPUT" "Continue editing? (y/N): ")" continue_editing
            if [[ ! "$continue_editing" =~ ^[Yy]$ ]]; then
                break
            fi
        done
    fi
}

resize_vm_disk() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        print_status "INFO" "Current disk size: $DISK_SIZE"

        while true; do
            read -p "$(print_status "INPUT" "Enter new disk size (e.g., 50G): ")" new_disk_size
            if validate_input "size" "$new_disk_size"; then
                if [[ "$new_disk_size" == "$DISK_SIZE" ]]; then
                    print_status "INFO" "New disk size is the same as current size. No changes made."
                    return 0
                fi

                # Check if new size is smaller than current (not recommended)
                local current_size_num=${DISK_SIZE%[GgMm]}
                local new_size_num=${new_disk_size%[GgMm]}
                local current_unit=${DISK_SIZE: -1}
                local new_unit=${new_disk_size: -1}

                # Convert both to MB for comparison
                if [[ "$current_unit" =~ [Gg] ]]; then
                    current_size_num=$((current_size_num * 1024))
                fi
                if [[ "$new_unit" =~ [Gg] ]]; then
                    new_size_num=$((new_size_num * 1024))
                fi

                if [[ $new_size_num -lt $current_size_num ]]; then
                    print_status "WARN" "Shrinking disk size is not recommended and may cause data loss!"
                    read -p "$(print_status "INPUT" "Are you sure you want to continue? (y/N): ")" confirm_shrink
                    if [[ ! "$confirm_shrink" =~ ^[Yy]$ ]]; then
                        print_status "INFO" "Disk resize cancelled."
                        return 0
                    fi
                fi

                # Resize the disk
                print_status "INFO" "Resizing disk to $new_disk_size..."
                if qemu-img resize "$IMG_FILE" "$new_disk_size"; then
                    DISK_SIZE="$new_disk_size"
                    save_vm_config
                    print_status "SUCCESS" "Disk resized successfully to $new_disk_size"
                else
                    print_status "ERROR" "Failed to resize disk"
                    return 1
                fi
                break
            fi
        done
    fi
}

show_vm_performance() {
    local vm_name=$1

    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then
            print_status "INFO" "Performance metrics for VM: $vm_name"
            echo "=========================================="

            # Get QEMU process ID
            local qemu_pid=$(pgrep -f "qemu-system-x86_64.*$IMG_FILE")
            if [[ -n "$qemu_pid" ]]; then
                # Show process stats
                echo "QEMU Process Stats:"
                ps -p "$qemu_pid" -o pid,%cpu,%mem,sz,rss,vsz,cmd --no-headers
                echo

                # Show memory usage
                echo "Memory Usage:"
                free -h
                echo

                # Show disk usage
                echo "Disk Usage:"
                df -h "$IMG_FILE" 2>/dev/null || du -h "$IMG_FILE"
            else
                print_status "ERROR" "Could not find QEMU process for VM $vm_name"
            fi
        else
            print_status "INFO" "VM $vm_name is not running"
            echo "Configuration:"
            echo " Memory: $MEMORY MB"
            echo " CPUs: $CPUS"
            echo " Disk: $DISK_SIZE"
        fi
        echo "=========================================="
        read -p "$(print_status "INPUT" "Press Enter to continue...")"
    fi
}

vm_main_menu() {
    while true; do
        display_header

        local vms=($(get_vm_list))
        local vm_count=${#vms[@]}

        if [ $vm_count -gt 0 ]; then
            print_status "INFO" "Found $vm_count existing VM(s):"
            for i in "${!vms[@]}"; do
                local status="Stopped"
                if is_vm_running "${vms[$i]}"; then
                    status="Running"
                fi
                printf " %2d) %s (%s)\n" $((i+1)) "${vms[$i]}" "$status"
            done
            echo
        fi

        echo "Main Menu:"
        echo " 1) Create a new VM"
        if [ $vm_count -gt 0 ]; then
            echo " 2) Start a VM"
            echo " 3) Stop a VM"
            echo " 4) Show VM info"
            echo " 5) Edit VM configuration"
            echo " 6) Delete a VM"
            echo " 7) Resize VM disk"
            echo " 8) Show VM performance"
        fi
        echo " 0) Exit VM Manager"
        echo

        read -p "$(print_status "INPUT" "Enter your choice: ")" choice

        case $choice in
            1)
                create_new_vm
                ;;
            2)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to start: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        start_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            3)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to stop: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        stop_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            4)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to show info: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        show_vm_info "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            5)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to edit: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        edit_vm_config "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            6)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to delete: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        delete_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            7)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to resize disk: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        resize_vm_disk "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            8)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to show performance: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        show_vm_performance "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            0)
                return 0
                ;;
            *)
                print_status "ERROR" "Invalid option"
                ;;
        esac

        read -p "$(print_status "INPUT" "Press Enter to continue...")"
    done
}

# Google IDX Sub-Menu (Full Integration)
google_idx_submenu() {
    while true; do
        clear
        cat << 'EOF'
  ╔══════════════════════════════════════════════════════════════╗
  ║ Google IDX Tools Setup                                       ║
  ║ Powered by R2Ksanu 💎                                        ║
  ╚══════════════════════════════════════════════════════════════╝
EOF
        echo -e "\n${ORANGE}Choose a Google IDX tool to install or configure:${NC}"
        echo -e "${RED}12)${NC}${CYAN} Setup RDP (Remote Desktop)${NC}"
        echo -e "${RED}13)${NC}${CYAN} Install & Run 24/7 Python Script${NC}"
        echo -e "${RED}14)${NC}${CYAN} Setup Playit.gg Tunnel${NC}"
        echo -e "${RED}15)${NC}${CYAN} Install & Setup Tailscale VPN${NC}"
        echo -e "${RED}16)${NC}${CYAN} Setup Code Server (VS Code Web)${NC}"
        echo -e "${RED}17)${NC}${CYAN} VM Maker - @Hopingboyz${NC}"
        echo -e "${YELLOW}0)${NC}${GREEN} Back to Main Menu${NC}"
        echo -ne "${ORANGE}Enter your choice: ${NC}"
        read sub_choice
        if [ "$sub_choice" -eq 0 ]; then
            clear
            break
        fi
        case $sub_choice in
            12)
                echo -e "${RED}Setting up RDP (Remote Desktop Protocol)...${NC}"
                (
                    apt update -y && apt upgrade -y
                    apt install xfce4 xfce4-goodies xrdp -y
                    echo "startxfce4" > ~/.xsession
                    sudo chown $(whoami):$(whoami) ~/.xsession
                    systemctl enable xrdp
                    systemctl restart xrdp
                ) & spinner "RDP Setup"
                echo -e "${GREEN}✔ RDP setup complete!${NC}"
                echo -e "${YELLOW}You can now connect using Remote Desktop on port 3389.${NC}"
                echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
                ;;
            13)
                echo -e "${RED}Installing 24/7 Python script...${NC}"
                (
                    apt install -y python3 > /dev/null
                    cat << 'EOF' > /usr/local/bin/24-7.py
#!/usr/bin/env python3
import os, random, string, time
def display_banner():
    print(r"""
                            R2Ksanu 24/7 File Engine
    """)
def generate_random_string(length=100):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))
def create_edit_delete_file():
    folder_name = "24"
    os.makedirs(folder_name, exist_ok=True)
    while True:
        try:
            file_name = os.path.join(folder_name, f"{generate_random_string(8)}.txt")
            with open(file_name, "w") as file:
                for _ in range(random.randint(10, 100)):
                    file.write(generate_random_string(100) + "\n")
            print(f"Created: {file_name}")
            time.sleep(2)
            with open(file_name, "w") as file:
                for _ in range(random.randint(10, 100)):
                    file.write(generate_random_string(100) + "\n")
            print(f"Edited: {file_name}")
            time.sleep(1)
            os.remove(file_name)
            print(f"Deleted: {file_name}")
            time.sleep(1)
        except Exception as e:
            print(f"An error occurred: {e}")
            time.sleep(5)
if __name__ == "__main__":
    display_banner()
    create_edit_delete_file()
EOF
                    chmod +x /usr/local/bin/24-7.py
                    echo "@reboot /usr/bin/python3 /usr/local/bin/24-7.py &" | crontab -
                ) & spinner "24/7 Script Install"
                echo -e "${GREEN}✔ 24/7 script installed and set to run in background at startup!${NC}"
                echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
                ;;
            14)
                echo -e "${RED}Installing Playit.gg tunnel service...${NC}"
                (
                    set -e
                    apt update -y && apt upgrade -y
                    apt install -y sudo curl gpg
                    curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
                    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
                    sudo apt update -y
                    sudo apt install -y playit
                    sudo systemctl enable --now playit
                ) & spinner "Playit.gg Install"
                echo -e "${GREEN}✔ Playit.gg installed successfully!${NC}"
                echo -e "${YELLOW}Run 'sudo playit setup' to link your tunnel.${NC}"
                echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
                ;;
            15)
                echo -e "${RED}Installing Tailscale VPN...${NC}"
                (
                    curl -fsSL https://tailscale.com/install.sh | sh > /dev/null
                    systemctl enable --now tailscaled
                ) & spinner "Tailscale Install"
                echo -e "${GREEN}✔ Tailscale installed and running!${NC}"
                echo -e "${YELLOW}Next step: run 'sudo tailscale up' to connect your device.${NC}"
                echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
                ;;
            16)
                echo -e "${RED}Setting up Code Server (VS Code Web)...${NC}"
                (
                    curl -fsSL https://code-server.dev/install.sh | sh
                    systemctl enable --now code-server@$USER
                ) & spinner "Code Server Setup"
                echo -e "${GREEN}✔ Code Server setup complete!${NC}"
                echo -e "${YELLOW}Access at http://localhost:8080${NC}"
                echo -e "${CYAN}✨ Made by R2Ksanu${NC}"
                ;;
            17)
                # Run VM Maker
                vm_main_menu
                ;;
            *)
                echo -e "${RED}❌ Invalid choice or missing script for option ${sub_choice}.${NC}"
                sleep 2
                ;;
        esac
        read -p "${GREEN}Press Enter to continue...${NC}"
    done
}

# dev.nix Generator
generate_dev_nix() {
    echo -e "\n${RED}[*] Creating dev.nix configuration for Google IDX...${NC}"
    cat << 'EOF' > dev.nix
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
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
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = { };
      # To run something each time the workspace is (re)started, use the `onStart` hook
    };
    # Disable previews completely
    previews = {
      enable = false;
    };
  };
}
EOF
    echo -e "${GREEN}[✔] dev.nix file successfully created!${NC}"
    echo -e "${YELLOW}Location:${NC} $(pwd)/dev.nix"
    echo -e "${ORANGE}Code Made by Hopingboyz 💎${NC}\n"
    echo -e "${RED}Script by R2Ksanu 💎${NC}\n"
    read -p "${GREEN}Press Enter to continue...${NC}"
}

# Main Menu Loop (Full Combined Menu)
main_menu() {
    while true; do
        show_banner
        echo -e "\n${ORANGE}Main Menu - Select an Option:${NC}"
        echo -e "${RED}1)${NC}${CYAN} VM Manager (Multi-VM Creator & Controller)${NC}"
        echo -e "${RED}2)${NC}${CYAN} Google IDX Tools Sub-Menu${NC}"
        echo -e "${RED}3)${NC}${CYAN} Generate dev.nix for Google IDX${NC}"
        echo -e "${YELLOW}0)${NC}${GREEN} Exit${NC}"
        echo -ne "${ORANGE}Enter your choice: ${NC}"
        read choice
        case $choice in
            1)
                vm_main_menu
                ;;
            2)
                google_idx_submenu
                ;;
            3)
                generate_dev_nix
                ;;
            0)
                echo -e "${RED}Goodbye! Powered by R2Ksanu 💎${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option. Try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Supported OS list for VM Manager
declare -A OS_OPTIONS=(
    ["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu22|ubuntu|ubuntu"
    ["Ubuntu 24.04"]="ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu24|ubuntu|ubuntu"
    ["Debian 11"]="debian|bullseye|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2|debian11|debian|debian"
    ["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian12|debian|debian"
    ["Fedora 40"]="fedora|40|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedora40|fedora|fedora"
    ["CentOS Stream 9"]="centos|stream9|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos9|centos|centos"
    ["AlmaLinux 9"]="almalinux|9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|almalinux9|alma|alma"
    ["Rocky Linux 9"]="rockylinux|9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky9|rocky|rocky"
)

# Initialize
mkdir -p "$VM_DIR" "$GOOGLE_IDX_DIR" "$INCLUDES_DIR"
check_dependencies
trap cleanup EXIT

# Start
main_menu