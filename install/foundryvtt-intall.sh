#!/usr/bin/env bash
set -Eeuo pipefail

APP_USER="foundry"
APP_DIR="/opt/foundryvtt"
DATA_DIR="/opt/foundrydata"
SERVICE="foundryvtt"
GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y curl wget unzip ca-certificates gnupg lsb-release iproute2

if ! command -v node >/dev/null 2>&1 || ! node -v | grep -q '^v22\.'; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt install -y nodejs
fi

if ! id "$APP_USER" >/dev/null 2>&1; then
  useradd --system --create-home --shell /usr/sbin/nologin "$APP_USER"
fi

mkdir -p "$APP_DIR" "$DATA_DIR"
chown -R "$APP_USER:$APP_USER" "$APP_DIR" "$DATA_DIR"

mkdir -p "$(dirname "$GETTY_OVERRIDE")"
cat <<'EOG' > "$GETTY_OVERRIDE"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 $TERM
EOG
systemctl daemon-reload
systemctl restart container-getty@1.service || true

if [[ ! -f "$APP_DIR/main.js" ]]; then
  echo "Paste your Foundry VTT Node.js timed download URL"
  read -r -p "URL: " FOUNDRY_URL
  if [[ -z "${FOUNDRY_URL:-}" ]]; then
    echo "No Foundry URL provided"
    exit 1
  fi
  su -s /bin/bash -c "cd '$APP_DIR' && wget -O foundryvtt.zip '$FOUNDRY_URL'" "$APP_USER"
  su -s /bin/bash -c "cd '$APP_DIR' && unzip -o foundryvtt.zip && rm -f foundryvtt.zip" "$APP_USER"
fi

if [[ ! -f "$APP_DIR/main.js" ]]; then
  echo "Foundry install failed: $APP_DIR/main.js not found"
  exit 1
fi

cat > /etc/systemd/system/${SERVICE}.service <<EOS
[Unit]
Description=Foundry Virtual Tabletop
After=network.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/node ${APP_DIR}/main.js --dataPath=${DATA_DIR} --port=30000
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOS

systemctl daemon-reload
systemctl enable --now "$SERVICE"
systemctl restart "$SERVICE"
