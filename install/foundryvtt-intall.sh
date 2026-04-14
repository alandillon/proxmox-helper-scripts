#!/usr/bin/env bash
set -euo pipefail

APP_USER="foundry"
APP_DIR="/opt/foundryvtt"
DATA_DIR="/opt/foundrydata"
SERVICE="foundryvtt"

apt update
apt install -y curl wget unzip ca-certificates gnupg lsb-release

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

if ! id "$APP_USER" >/dev/null 2>&1; then
  useradd --system --create-home --shell /usr/sbin/nologin "$APP_USER"
fi

mkdir -p "$APP_DIR" "$DATA_DIR"
chown -R "$APP_USER:$APP_USER" "$APP_DIR" "$DATA_DIR"

echo "Paste your Foundry VTT Node.js timed download URL"
read -r -p "URL: " FOUNDRY_URL

su -s /bin/bash -c "cd '$APP_DIR' && wget -O foundryvtt.zip '$FOUNDRY_URL'" "$APP_USER"
su -s /bin/bash -c "cd '$APP_DIR' && unzip -o foundryvtt.zip && rm -f foundryvtt.zip" "$APP_USER"

cat >/etc/systemd/system/${SERVICE}.service <<EOF
[Unit]
Description=Foundry Virtual Tabletop
After=network.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/node ${APP_DIR}/main.js --dataPath=${DATA_DIR}
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "$SERVICE"
