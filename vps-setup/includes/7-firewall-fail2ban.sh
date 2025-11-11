#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Setting up UFW + Fail2Ban...${NC}"
(
    apt install ufw fail2ban -y > /dev/null
    ufw allow OpenSSH > /dev/null
    ufw allow 80/tcp > /dev/null
    ufw allow 443/tcp > /dev/null
    ufw --force enable > /dev/null
    systemctl enable fail2ban
    systemctl start fail2ban
) & spinner
echo -e "${GREEN}✔ Firewall and Fail2Ban setup complete!${NC}"
