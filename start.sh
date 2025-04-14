#!/bin/bash
# File: start.sh

set -e

REPO_URL="https://github.com/itzg/docker-minecraft-server"
INSTALL_DIR="$HOME/mc-auto-sh"
AUTO_SH_REPO="https://github.com/OwendB1/MC-Auto-SH"

command_exists() { command -v "$1" &>/dev/null; }

update_self() {
  echo "[+] Checking for MC-Auto-SH updates..."
  TMP_DIR=$(mktemp -d)
  git clone --depth 1 "$AUTO_SH_REPO" "$TMP_DIR"
  cp -r "$TMP_DIR/scripts" "$INSTALL_DIR/"
  rm -rf "$TMP_DIR"
  echo "[+] Scripts updated from latest MC-Auto-SH release."
}

# Auto-install dependencies
echo "[+] Checking required dependencies..."
if ! command_exists git; then
  echo "[-] Git not found. Installing..."
  sudo apt update && sudo apt install -y git
fi

if ! command_exists docker; then
  echo "[-] Docker not found. Installing..."
  curl -fsSL https://get.docker.com | sudo sh
fi

if ! command_exists whiptail; then
  echo "[-] Whiptail not found. Installing..."
  sudo apt install -y whiptail
fi

if ! command_exists yq; then
  echo "[-] yq not found. Installing..."
  sudo snap install yq
fi

# Clone the base image repo (for reference or templates)
if [ ! -d "$INSTALL_DIR/docker-minecraft-server" ]; then
  echo "[+] Cloning docker-minecraft-server for reference..."
  git clone "$REPO_URL" "$INSTALL_DIR/docker-minecraft-server"
else
  echo "[+] docker-minecraft-server already cloned at $INSTALL_DIR/docker-minecraft-server"
fi

# Self-update scripts from MC-Auto-SH
update_self

cd "$INSTALL_DIR/scripts"

# Whiptail Menu
CHOICE=$(whiptail --title "MC-Auto-SH Control Panel" --menu "Choose an action:" 20 60 10 \
  1 "Configure a server" \
  2 "List of all servers / Monitor" \
  3 "Remove a server" \
  4 "Exit" 3>&1 1>&2 2>&3)

case $CHOICE in
  1)
    ./configure-server.sh
    ;;
  2)
    ./server-console.sh
    ;;
  3)
    ./remove-server.sh
    ;;
  4)
    echo "Exiting."
    exit 0
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac
