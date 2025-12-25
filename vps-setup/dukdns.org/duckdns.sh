#!/bin/bash
# ========================================
#     🦆 DuckDNS Auto-Updater 
#          Author: R2Ksanu
# ========================================

# --- Colors ---
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

clear
echo -e "${CYAN}"
echo "===================================="
echo "        🦆 DuckDNS Updater           "
echo "===================================="
echo -e "${RESET}"

# --- Ask user for input ---
read -p "🔑 Enter your DuckDNS Token: " TOKEN
read -p "🌍 Enter your DuckDNS Subdomain(s) (comma separated if many): " DOMAINS
read -p "📡 Enter your IPv4 (leave blank to auto-detect): " IPV4
read -p "🌐 Enter your IPv6 (leave blank to auto-detect): " IPV6

# --- Show summary ---
echo -e "${YELLOW}✨ Setup Summary:${RESET}"
echo -e " 🔑 Token: ${GREEN}$TOKEN${RESET}"
echo -e " 🌍 Subdomains: ${GREEN}$DOMAINS${RESET}"
echo -e " 📡 IPv4: ${GREEN}${IPV4:-Auto-detect}${RESET}"
echo -e " 🌐 IPv6: ${GREEN}${IPV6:-Auto-detect}${RESET}"
echo ""

# --- Setup directory ---
INSTALL_DIR=~/duckdns
LOG_FILE="$INSTALL_DIR/duck.log"
SCRIPT_FILE="$INSTALL_DIR/duck_update.sh"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

# --- Create update script ---
cat > "$SCRIPT_FILE" <<EOF
#!/bin/bash
DATE=\$(date '+%Y-%m-%d %H:%M:%S')

IPV4="$IPV4"
IPV6="$IPV6"

# Auto-detect if blank
if [ -z "\$IPV4" ]; then
  IPV4=\$(curl -s ipv4.icanhazip.com)
fi
if [ -z "\$IPV6" ]; then
  IPV6=\$(curl -s ipv6.icanhazip.com)
fi

URL="https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=\$IPV4&ipv6=\$IPV6"
RESPONSE=\$(curl -k -s "\$URL")

if [ "\$RESPONSE" = "OK" ]; then
    echo "[\$DATE] ✅ Update OK (IPv4=\$IPV4 | IPv6=\$IPV6)" >> "$LOG_FILE"
else
    echo "[\$DATE] ❌ Update FAILED: \$RESPONSE" >> "$LOG_FILE"
fi
EOF

chmod 700 "$SCRIPT_FILE"

# --- Run first test ---
echo -e "${YELLOW}⚡ Running first test update...${RESET}"
"$SCRIPT_FILE"

# --- Show last log entry ---
tail -n 1 "$LOG_FILE"

# --- Setup cron job (every 5 minutes) ---
CRON_JOB="*/5 * * * * $SCRIPT_FILE >/dev/null 2>&1"
( crontab -l 2>/dev/null | grep -v "$SCRIPT_FILE" ; echo "$CRON_JOB" ) | crontab -

echo -e "${GREEN}"
echo "===================================="
echo " ✅ DuckDNS Updater Installed!       "
echo " 🔁 Updates run every 5 minutes      "
echo " 📜 Log file: $LOG_FILE              "
echo " 🛠 Script file: $SCRIPT_FILE        "
echo "===================================="
echo -e "${RESET}"

# --- Extra features ---
echo -e "${CYAN}✨ Extra Features:${RESET}"
echo -e " - Multiple subdomains supported"
echo -e " - IPv4 + IPv6 support (auto-detect if blank)"
echo -e " - Logs with timestamps & IPs"
echo -e " - Cron auto-update every 5 minutes"
echo -e ""
echo -e "💡 Use 'cat $LOG_FILE' to check update history"
