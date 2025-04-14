#!/bin/bash
# File: start.sh

set -e

REPO_URL="https://github.com/itzg/docker-minecraft-server"
INSTALL_DIR="$HOME/mc-auto-sh"
AUTO_SH_REPO="https://github.com/OwendB1/MC-Auto-SH"
CONFIG_FILE="$HOME/.mc-auto-sh-env"

command_exists() { command -v "$1" &>/dev/null; }

# Load environment variables if config file exists
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

update_self() {
  echo "[+] Checking for MC-Auto-SH updates..."
  TMP_DIR=$(mktemp -d)
  git clone --depth 1 "$AUTO_SH_REPO" "$TMP_DIR"
  cp -r "$TMP_DIR/scripts" "$INSTALL_DIR/"
  mkdir -p "$INSTALL_DIR/.mc-auto-sh"

  # Get commit hash
  cd "$TMP_DIR"
  COMMIT_HASH=$(git rev-parse --short HEAD)
  cd - > /dev/null

  date > "$INSTALL_DIR/.mc-auto-sh/.last_update"
  echo "$COMMIT_HASH" > "$INSTALL_DIR/.mc-auto-sh/.version"

  echo "[+] Scripts updated from latest MC-Auto-SH release (commit: $COMMIT_HASH)."

  # Show latest changelog entry
  if [ -f "$TMP_DIR/CHANGELOG.md" ]; then
    echo "[*] Recent changes:"
    awk '/^## \[/{i++} i==1' "$TMP_DIR/CHANGELOG.md"
  fi

  rm -rf "$TMP_DIR"
}

update_base_repo() {
  echo "[+] Checking for updates to docker-minecraft-server..."
  if [ ! -d "$INSTALL_DIR/docker-minecraft-server/.git" ]; then
    echo "[+] Cloning docker-minecraft-server for reference..."
    git clone "$REPO_URL" "$INSTALL_DIR/docker-minecraft-server"
  else
    echo "[+] Updating docker-minecraft-server repo..."
    cd "$INSTALL_DIR/docker-minecraft-server"
    git pull
    cd - > /dev/null
  fi
}

fetch_env_var_docs() {
  echo "[+] Updating Minecraft server env var documentation..."
  VAR_CACHE="$HOME/.mc-auto-sh/vars-list.txt"
  mkdir -p "$(dirname "$VAR_CACHE")"

  curl -sL "https://docker-minecraft-server.readthedocs.io/en/latest/variables/" |
    sed -n '/<h2 id="/,/<\/table>/p' |
    grep -E '<td>|<th>' |
    sed -E 's/<[^>]+>//g' |
    sed '/^\s*$/d' |
    awk 'NR%2{printf "%s - ", $0; next}1' > "$VAR_CACHE"

  echo "[+] Environment variable list cached to $VAR_CACHE"
}

# First: update this tool and the base repo
update_self
update_base_repo

# Check dependencies
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

# Fetch variable documentation
fetch_env_var_docs

# Prompt for CurseForge API Key if not set
if [ -z "$CF_API_KEY" ]; then
  if whiptail --yesno "Would you like to configure your CurseForge API key now?" 10 60 --title "CurseForge API Key"; then
    CF_API_KEY=$(whiptail --inputbox "Paste your CurseForge API Key here:" 10 80 "" --title "Configure CurseForge API" 3>&1 1>&2 2>&3)
    echo "export CF_API_KEY=\"$CF_API_KEY\"" > "$CONFIG_FILE"
    echo "[+] CurseForge API key saved to $CONFIG_FILE"
  fi
fi

# Show last update info and version
if [ -f "$INSTALL_DIR/.mc-auto-sh/.last_update" ]; then
  echo "🕓 Last MC-Auto-SH update: $(cat "$INSTALL_DIR/.mc-auto-sh/.last_update")"
fi
if [ -f "$INSTALL_DIR/.mc-auto-sh/.version" ]; then
  echo "📦 Installed version: commit $(cat "$INSTALL_DIR/.mc-auto-sh/.version")"
fi

cd "$INSTALL_DIR/scripts"

# Main menu
CHOICE=$(whiptail --title "MC-Auto-SH Control Panel" --menu "Choose an action:" 20 60 10 \
  1 "Configure a server" \
  2 "List of all servers / Monitor" \
  3 "Remove a server" \
  4 "Manage CurseForge API Key" \
  5 "Exit" 3>&1 1>&2 2>&3)

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
    API_ACTION=$(whiptail --title "Manage CurseForge API Key" --menu "What would you like to do?" 15 60 3 \
      1 "Set/Update API Key" \
      2 "Remove API Key" \
      3 "Cancel" 3>&1 1>&2 2>&3)
    case $API_ACTION in
      1)
        CF_API_KEY=$(whiptail --inputbox "Paste your new CurseForge API Key:" 10 80 "" --title "Update CurseForge API Key" 3>&1 1>&2 2>&3)
        echo "export CF_API_KEY=\"$CF_API_KEY\"" > "$CONFIG_FILE"
        echo "[+] API key updated in $CONFIG_FILE"
        ;;
      2)
        rm -f "$CONFIG_FILE"
        echo "[+] CurseForge API key removed."
        ;;
      3)
        echo "[+] Cancelled."
        ;;
    esac
    ;;
  5)
    echo "Exiting."
    exit 0
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac
