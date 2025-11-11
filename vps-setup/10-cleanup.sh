#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}Cleaning up system...${NC}"
(apt autoremove -y > /dev/null && apt clean > /dev/null) & spinner
echo -e "${GREEN}✔ System cleanup complete!${NC}"
