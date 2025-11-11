#!/bin/bash

# Gradient function (Red to Blue)
function gradient_text() {
    text="$1"
    len=${#text}
    for ((i=0; i<$len; i++)); do
        r=$((255 - 10 * i))
        b=$((50 + 10 * i))
        [[ $r -lt 0 ]] && r=0
        [[ $b -gt 255 ]] && b=255
        printf "\e[38;2;%d;0;%dm%s" "$r" "$b" "${text:$i:1}"
    done
    echo -e "\e[0m"
}

# ASCII ART with Gradient
ascii_art() {
    clear
    echo ""
    gradient_text "██████╗ ██████╗ ██╗  ██╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗"
    gradient_text "██╔══██╗██╔══██╗██║ ██╔╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
    gradient_text "██████╔╝██████╔╝█████╔╝        ██║   ██║   ██║██║   ██║██║     █████╗  "
    gradient_text "██╔═══╝ ██╔══██╗██╔═██╗        ██║   ██║   ██║██║   ██║██║     ██╔══╝  "
    gradient_text "██║     ██║  ██║██║  ██╗       ██║   ╚██████╔╝╚██████╔╝███████╗███████╗"
    gradient_text "╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
    echo ""
    gradient_text "                           Powered by R2K"
    echo ""
}

# Menu Display
show_menu() {
    echo -e "\e[36m[ 1 ] VPS Tool"
    echo -e "[ 2 ] Minecraft Tool"
    echo -e "[ 0 ] Exit"
    echo ""
    read -p "Select your option below = " choice
}

# Main Logic
main() {
    ascii_art
    show_menu

    case "$choice" in
        1)
            echo -e "\e[34m[+] Cloning and running VPS Tool...\e[0m"
            bash <(curl -s https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/vps-setup/setup.sh)
            ;;
        2)
            echo -e "\e[32m[+] Launching Minecraft Tool...\e[0m"
            bash <(curl -s https://raw.githubusercontent.com/R2Ksanu/vps-tool/main/Minecraft-tool/mc-tool.sh)
            ;;
        0)
            echo -e "\e[31mExiting... Goodbye!\e[0m"
            exit 0
            ;;
        *)
            echo -e "\e[31mInvalid option! Please choose again.\e[0m"
            sleep 1
            main
            ;;
    esac
}

main

# Optional: Make the script executable and rerun itself only if executed directly
[[ $0 != bash ]] && chmod +x r2k-tools.sh && ./r2k-tools.sh
