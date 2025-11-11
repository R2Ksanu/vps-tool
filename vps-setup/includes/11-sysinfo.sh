#!/bin/bash
source includes/spinner.sh

echo -e "${CYAN}System info:${NC}"
fastfetch || echo -e "${RED}Fastfetch is not installed.${NC}"
