#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing Docker...${NC}"
(
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh > /dev/null
    usermod -aG docker $USER
) & spinner
echo -e "${GREEN}✔ Docker installed!${NC}"
