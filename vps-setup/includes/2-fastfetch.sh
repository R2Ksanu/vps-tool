#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing Fastfetch...${NC}"
(
    add-apt-repository -y ppa:fastfetch-cli/fastfetch > /dev/null 2>&1
    apt update -qq > /dev/null
    apt install -y fastfetch > /dev/null
) & spinner
echo -e "${GREEN}✔ Fastfetch installed!${NC}"
