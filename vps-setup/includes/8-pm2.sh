#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing PM2...${NC}"
(npm install -g pm2 > /dev/null && pm2 startup > /dev/null) & spinner
echo -e "${GREEN}✔ PM2 installed!${NC}"
