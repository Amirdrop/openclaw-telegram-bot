#!/bin/bash
set -e

echo "== Updating system =="
apt update && apt upgrade -y
apt install -y curl git nano

echo "== Installing Docker =="
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

echo "== Installing Node.js 20 =="
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
fi

echo "== Installing 9Router =="
if ! command -v 9router >/dev/null 2>&1; then
  npm install -g 9router
fi

echo "== Creating 9Router systemd service =="
cat >/etc/systemd/system/9router.service <<'EOF'
[Unit]
Description=9Router AI Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/npx 9router
Restart=always
RestartSec=5
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable 9router
systemctl restart 9router

echo "== Preparing environment file =="
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env file. Please edit it before starting the bot."
fi

chmod +x install.sh

echo ""
echo "======================================"
echo "Installation complete!"
echo "1. Edit .env with your Telegram token"
echo "2. Open http://YOUR_SERVER_IP:20128/dashboard"
echo "3. Add your AI provider in 9Router"
echo "4. Run: docker compose up -d"
echo "======================================"
