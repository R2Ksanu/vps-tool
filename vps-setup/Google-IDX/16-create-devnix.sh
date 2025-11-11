#!/bin/bash
# ============================================
# Google IDX Dev.nix Auto Generator
# Made by R2Ksanu 💎
# ============================================

echo -e "\n${CYAN}[*] Creating dev.nix configuration for Google IDX...${NC}"

cat << 'EOF' > dev.nix
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.unzip
    pkgs.openssh
    pkgs.git
    pkgs.qemu_kvm
    pkgs.sudo
    pkgs.cdrkit
    pkgs.cloud-utils
    pkgs.qemu
  ];
  
  # Sets environment variables in the workspace
  env = {};
  
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = { };
      # To run something each time the workspace is (re)started, use the `onStart` hook
    };

    # Disable previews completely
    previews = {
      enable = false;
    };
  };
}
EOF 

echo -e "${GREEN}[✔] dev.nix file successfully created!${NC}"
echo -e "${YELLOW}Location:${NC} $(pwd)/dev.nix"
echo -e "${BLUE}Code Made  by Hopingboyz 💎${NC}\n"
echo -e "${BLUE}Script by R2Ksanu 💎${NC}\n"

