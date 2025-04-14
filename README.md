# MC-Auto-SH

**MC-Auto-SH** is a collection of shell-based scripts with interactive GUI elements built using `whiptail`. It serves as a simple yet powerful interface on top of [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server), allowing you to easily manage and configure Minecraft server instances on Linux systems.

## ✨ Features
- Easy-to-use shell-based GUI for server setup and control
- Automatically installs dependencies like Docker, Git, YQ, and Whiptail
- Support for Fabric, NeoForge, and Vanilla Minecraft servers
- Optional support for CurseForge modpacks
- Automatic updates from the official MC-Auto-SH GitHub repo
- Per-server configuration stored in YAML files
- Console access and Docker container management built in

## 🛠️ Requirements
- Linux (Ubuntu/Debian preferred)
- `bash`, `docker`, `git`, `yq`, `whiptail`

> The main script will install any missing dependencies for you.

## 🚀 Getting Started

```bash
bash <(curl -s https://raw.githubusercontent.com/OwendB1/MC-Auto-SH/main/start.sh)
```

> This will clone the necessary files, install any dependencies, and launch the main menu.

## 🧭 Control Panel Options
- **Configure a server** – Create a new server or edit existing one
- **List of all servers / Monitor** – Start, stop, or attach to console of running servers
- **Remove a server** – Deletes a server directory and Docker container

## 📦 CurseForge Modpack Support
When configuring a server, you can enable CurseForge modpacks by pasting in a modpack URL. The system will then fetch and prepare the environment accordingly using `MODPACK_PLATFORM=AUTO_CURSEFORGE`.

Make sure to generate and configure a [CurseForge API key](https://console.curseforge.com/) and pass it as `CF_API_KEY` via your environment or `.env` file if needed.

## 📁 File Structure
```
mc-auto-sh/
├── scripts/                # All shell-based management scripts
├── servers/                # Each instance has its own folder
│   └── my-server/          # Includes config.yaml and mods folder
├── docker-minecraft-server/ # Cloned reference for itzg's base Docker config
└── start.sh                # Main entrypoint script
```

## 🧪 Coming Soon
- 🔄 Backup & restore utilities (local and cloud storage)
- 📊 Live resource monitoring (CPU, RAM, Docker stats)
- ⚙️ Mod manager with CurseForge API integration
- 🧠 Port conflict detection
- ⏱️ Scheduled server start/stop via cron
- 👥 Multi-user support / password protection
- 🌍 Custom world seeds and generator settings
- 🧪 Loader/version compatibility checker
- 🧠 Performance presets (low-end, balanced, high)
- 📦 Plugin support (Paper, Purpur, Spigot)
- 🌐 Reverse proxy integration (e.g. NGINX or Caddy)
- 🔐 Dynamic DNS integration (e.g., DuckDNS)

## 📘 Docs
Full documentation for the underlying Docker container is available at:
👉 [https://docker-minecraft-server.readthedocs.io/](https://docker-minecraft-server.readthedocs.io/)

---

Made with ❤️ to simplify server hosting for everyone.
