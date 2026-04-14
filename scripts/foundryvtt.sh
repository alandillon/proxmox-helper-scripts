#!/usr/bin/env bash
set -Eeuo pipefail

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="FoundryVTT"
var_tags="gaming;vtt;foundry"
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
  if ! pct exec "$CTID" -- test -f /etc/systemd/system/foundryvtt.service; then
    msg_error "FoundryVTT is not installed in CT $CTID"
    exit 1
  fi
  msg_info "Re-running FoundryVTT installer in CT $CTID"
  pct exec "$CTID" -- bash -lc "curl -fsSL https://raw.githubusercontent.com/alandillon/proxmox-helper-scripts/main/install/foundryvtt-install.sh | bash"
  msg_ok "Updated Successfully"
  exit
}

start
build_container

msg_info "Running FoundryVTT installer inside the container"
pct exec "$CTID" -- bash -lc "curl -fsSL https://raw.githubusercontent.com/alandillon/proxmox-helper-scripts/main/install/foundryvtt-install.sh | bash"
msg_ok "Completed Successfully"

IP=$(pct exec "$CTID" -- hostname -I | awk '{print $1}')
echo " ${APP} should be reachable at: http://${IP}:30000"
