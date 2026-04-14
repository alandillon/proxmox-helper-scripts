# Foundry VTT Proxmox / LXC Installer

Installs Foundry Virtual Tabletop in a Debian or Ubuntu LXC on Proxmox.

## What it does

- Installs Node.js 22
- Creates a `foundry` system user
- Installs Foundry VTT from your timed Node.js download URL
- Creates a `systemd` service
- Starts Foundry on port 30000

## Requirements

- Proxmox LXC running Debian 12 or Ubuntu 24.04
- Root shell in the container
- A valid Foundry VTT license
- A fresh timed download URL for the **Node.js** build

## Run

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/alandillon/proxmox_helper_scripts/main/foundry-proxmox/install-foundry.sh)"
```

## Notes

The Foundry timed URL expires after a few minutes, so copy it right before running the script.
