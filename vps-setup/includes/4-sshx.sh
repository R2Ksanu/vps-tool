#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing SSHX...${NC}"
(curl -sSf https://sshx.io/get | sh > /dev/null) & spinner
echo -e "${GREEN}✔ SSHX installed!${NC}"
