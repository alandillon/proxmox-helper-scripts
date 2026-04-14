#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="FoundryVTT"
var_tags="${var_tags:-gaming;vtt}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-12}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info "$APP"
  check_container_storage
  check_container_resources
  if [[ ! -f /opt/foundryvtt/main.js ]]; then
    msg_error "No Foundry installation found at /opt/foundryvtt"
    exit 1
  fi
  systemctl restart foundryvtt
  msg_ok "FoundryVTT service restarted"
}

start
build_container

msg_info "Running FoundryVTT installer inside the container"
lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/alandillon/proxmox-helper-scripts/main/install/foundryvtt-intall.sh)"
msg_ok "Completed Successfully"

IP=$(pct exec "$CTID" -- hostname -I | awk '{print $1}')
echo "FoundryVTT should be available at: http://${IP}:30000"
