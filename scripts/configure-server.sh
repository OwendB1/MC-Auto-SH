#!/bin/bash
# File: scripts/configure-server.sh

set -e

SERVER_ROOT="$HOME/mc-auto-sh/servers"
mkdir -p "$SERVER_ROOT"

SERVER_NAME=$(whiptail --inputbox "Enter a name for your new Minecraft server instance:" 10 60 "server-1" --title "Configure Server" 3>&1 1>&2 2>&3)
if [ -z "$SERVER_NAME" ]; then
  echo "[-] Server name cannot be empty."
  exit 1
fi

SERVER_DIR="$SERVER_ROOT/$SERVER_NAME"
CONTAINER_NAME="mcauto-${SERVER_NAME// /_}"  # Save this for consistency across scripts
mkdir -p "$SERVER_DIR/mods"

VERSION=$(whiptail --inputbox "Enter Minecraft version (e.g. 1.20.4):" 10 60 "1.20.4" --title "Minecraft Version" 3>&1 1>&2 2>&3)
RAM=$(whiptail --inputbox "Enter RAM allocation (e.g. 4G):" 10 60 "4G" --title "RAM Allocation" 3>&1 1>&2 2>&3)
LOADER=$(whiptail --title "Mod Loader" --radiolist \
"Choose a mod loader:" 15 60 3 \
"vanilla" "Standard Minecraft Server" ON \
"fabric" "Fabric Mod Loader" OFF \
"neoforge" "NeoForge Mod Loader" OFF \
3>&1 1>&2 2>&3)
PORT=$(whiptail --inputbox "Enter external port (default: 25565):" 10 60 "25565" --title "Server Port" 3>&1 1>&2 2>&3)

USE_CURSEFORGE=$(whiptail --yesno "Would you like to use a CurseForge modpack?" 10 60 --title "CurseForge Modpack" 3>&1 1>&2 2>&3 && echo "yes" || echo "no")
MODPACK_URL=""
if [ "$USE_CURSEFORGE" == "yes" ]; then
  MODPACK_URL=$(whiptail --inputbox "Enter CurseForge modpack URL:" 10 80 "https://www.curseforge.com/minecraft/modpacks/all-the-mods-9" --title "CurseForge Modpack URL" 3>&1 1>&2 2>&3)
fi

cat > "$SERVER_DIR/config.yaml" <<EOF
version: "$VERSION"
ram: "$RAM"
port: $PORT
loader: "$LOADER"
docker_image: "itzg/minecraft-server:latest"
container_name: "$CONTAINER_NAME"
EOF

if [ "$USE_CURSEFORGE" == "yes" ]; then
  echo "modpack_url: \"$MODPACK_URL\"" >> "$SERVER_DIR/config.yaml"
fi

echo "[+] Configuration for '$SERVER_NAME' saved to $SERVER_DIR/config.yaml"
echo "[+] You can now start this server from the main menu."
read -n 1 -s -r -p "Press any key to return to menu..."
clear
