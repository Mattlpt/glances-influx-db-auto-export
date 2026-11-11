#!/bin/bash
# Installe/répare glances.service : glances --export influxdb au démarrage.
# Usage : sudo bash install-glances-service.sh
set -euo pipefail

RUN_USER="${SUDO_USER:?lancer avec sudo depuis ton compte utilisateur}"
GLANCES_BIN="$(sudo -u "$RUN_USER" bash -lc 'command -v glances' || true)"
[ -x "$GLANCES_BIN" ] || { echo "glances introuvable pour $RUN_USER"; exit 1; }
echo "Utilisateur : $RUN_USER  |  binaire : $GLANCES_BIN"

cat > /etc/systemd/system/glances.service <<EOF
[Unit]
Description=Glances - export InfluxDB
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=$RUN_USER
ExecStart=$GLANCES_BIN --export influxdb --quiet
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Arrêter l'instance lancée à la main dans screen (sinon double export)
sudo -u "$RUN_USER" screen -S glances -X quit 2>/dev/null || true
pkill -u "$RUN_USER" -f 'glances --export influxdb' 2>/dev/null || true
sleep 1

systemctl daemon-reload
systemctl enable --now glances.service
sleep 3
systemctl --no-pager status glances.service | head -12
