#!/bin/bash
# File: scripts/server-console.sh

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

SELECTED_SERVER=$(whiptail --title "MC Server Console" \
  --menu "Select a server to manage:" 20 60 10 \
  $(for dir in $SERVER_LIST; do echo "$dir" ""; done) \
  3>&1 1>&2 2>&3)

if [ -z "$SELECTED_SERVER" ]; then
  echo "[-] No server selected."
  exit 1
fi

CONFIG_FILE="$SERVER_ROOT/$SELECTED_SERVER/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[-] Config file not found for $SELECTED_SERVER."
  exit 1
fi

CONTAINER_NAME=$(yq '.container_name' "$CONFIG_FILE")

ACTION=$(whiptail --title "Server: $SELECTED_SERVER" --menu "Choose an action:" 20 60 10 \
  "1" "Start server" \
  "2" "Stop server" \
  "3" "Attach to console" \
  "4" "View itzg/minecraft-server help" \
  "5" "Back to main menu" \
  3>&1 1>&2 2>&3)

case $ACTION in
  1)
    echo "[+] Starting container '$CONTAINER_NAME'..."
    docker start "$CONTAINER_NAME" || echo "[-] Failed to start container. It may not exist yet."
    ;;
  2)
    echo "[+] Stopping container '$CONTAINER_NAME'..."
    docker stop "$CONTAINER_NAME" || echo "[-] Failed to stop container."
    ;;
  3)
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
      echo "[+] Attaching to '$CONTAINER_NAME'. Press Ctrl+P Ctrl+Q to detach."
      docker attach "$CONTAINER_NAME"
    else
      echo "[-] Container is not running. Start it first."
    fi
    ;;
  4)
    echo "[+] Opening itzg/minecraft-server documentation in browser..."
    xdg-open "https://docker-minecraft-server.readthedocs.io/" &>/dev/null || open "https://docker-minecraft-server.readthedocs.io/"
    ;;
  5)
    echo "[+] Returning to main menu."
    ;;
  *)
    echo "[-] Invalid selection."
    exit 1
    ;;
esac