#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Installing Node.js v22...${NC}"
(
    curl -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash > /dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install lts > /dev/null
    nvm use lts dev/null
) & spinner
echo -e "${GREEN}✔ Node.js v22 installed!${NC}"
