#!/bin/bash
# File: scripts/remove-server.sh

set -e

SERVER_ROOT="$HOME/mc-auto-sh/servers"

if [ ! -d "$SERVER_ROOT" ]; then
  echo "[-] No servers found."
  exit 1
fi

SERVER_LIST=$(ls "$SERVER_ROOT")
if [ -z "$SERVER_LIST" ]; then
  echo "[-] No server directories found in $SERVER_ROOT."
  exit 1
fi

SELECTED_SERVER=$(whiptail --title "Remove MC Server" \
  --menu "Select a server to remove:" 20 60 10 \
  $(for dir in $SERVER_LIST; do echo "$dir" ""; done) \
  3>&1 1>&2 2>&3)

if [ -z "$SELECTED_SERVER" ]; then
  echo "[-] No server selected."
  exit 1
fi

CONFIG_FILE="$SERVER_ROOT/$SELECTED_SERVER/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[-] Configuration file not found for $SELECTED_SERVER."
  exit 1
fi

CONTAINER_NAME=$(yq '.container_name' "$CONFIG_FILE")

CONFIRM=$(whiptail --yesno "Are you sure you want to delete server '$SELECTED_SERVER' and container '$CONTAINER_NAME'?" 10 60 --title "Confirm Removal" 3>&1 1>&2 2>&3 && echo "yes" || echo "no")

if [ "$CONFIRM" != "yes" ]; then
  echo "[+] Operation cancelled."
  exit 0
fi

# Stop and remove Docker container (if exists)
echo "[+] Removing Docker container '$CONTAINER_NAME' if it exists..."
docker stop "$CONTAINER_NAME" &>/dev/null || true
docker rm "$CONTAINER_NAME" &>/dev/null || true

# Remove server directory
echo "[+] Deleting server directory '$SERVER_ROOT/$SELECTED_SERVER'..."
rm -rf "$SERVER_ROOT/$SELECTED_SERVER"

echo "[✓] Server '$SELECTED_SERVER' and container '$CONTAINER_NAME' removed."
read -n 1 -s -r -p "Press any key to return to menu..."
clear