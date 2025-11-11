#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing Nginx...${NC}"
(apt install nginx -y > /dev/null && systemctl enable nginx && systemctl start nginx) & spinner
echo -e "${GREEN}✔ Nginx installed!${NC}"
