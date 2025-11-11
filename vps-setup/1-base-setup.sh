#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Setting up base packages...${NC}"
(apt install -qq sudo tmate -y && apt update -qq -y && apt upgrade -qq -y) & spinner
echo -e "${GREEN}✔ Base setup complete!${NC}"
