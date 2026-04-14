#!/usr/bin/env bash

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="FoundryVTT"
var_tags="${var_tags:-gaming;vtt;foundry}"
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

function default_settings() {
  CT_TYPE="unprivileged"
}

function update_script() {
  header_info "$APP"
  check_container_storage
  check_container_resources
  if [[ ! -f /etc/systemd/system/foundryvtt.service ]]; then
    msg_error "No ${APP} installation found!"
    exit 1
  fi
  msg_info "Updating ${APP}"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/alandillon/proxmox-helper-scripts/main/install/foundryvtt-install.sh)"
  msg_ok "Updated ${APP}"
  exit
}

start
build_container

msg_info "Running ${APP} installer inside the container"
lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/alandillon/proxmox-helper-scripts/main/install/foundryvtt-install.sh)"
msg_ok "Completed Successfully"

IP="$(pct exec "$CTID" -- hostname -I | awk '{print $1}')"
echo -e \"${APP} should be reachable at: http://${IP}:30000\"
