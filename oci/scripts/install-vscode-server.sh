#!/bin/bash
set -euxo pipefail

# =============================================================================
# VS Code Server (code-server) Installation Script for Terraform OCI
# =============================================================================
# This script is modeled after the GCP startup script to provide a robust
# setup with a dedicated user and Caddy for automatic HTTPS.
#
# Variables substituted by Terraform templatefile():
#   ${code_user}, ${vscode_password}, ${vscode_domain}, ${letsencrypt_email}, ${http_port}
# =============================================================================

# --- Logging ---
exec > >(tee /var/log/vscode-setup.log | logger -t vscode-setup -s 2>/dev/console) 2>&1
echo "===== Starting VS Code Server setup on OCI instance ====="

# --- System Update ---
echo "[1/6] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y curl gnupg2 software-properties-common ufw

# --- Create Dedicated User ---
echo "[2/6] Creating dedicated user: ${code_user}"
if ! id -u "${code_user}" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "${code_user}"
  # Add user to sudo group and allow passwordless sudo
  usermod -aG sudo "${code_user}"
  echo "${code_user} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${code_user}"
fi

# --- Install code-server ---
echo "[3/6] Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh

# --- Configure code-server ---
echo "[4/6] Configuring code-server for user ${code_user}..."
mkdir -p "/home/${code_user}/.config/code-server"

cat > "/home/${code_user}/.config/code-server/config.yaml" <<EOF
bind-addr: 127.0.0.1:${http_port}
auth: password
password: ${vscode_password}
cert: false
EOF

chown -R "${code_user}:${code_user}" "/home/${code_user}/.config"

# --- Create and Enable Systemd Service ---
echo "[5/6] Setting up systemd service..."
cat > /etc/systemd/system/code-server.service <<EOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=${code_user}
Group=${code_user}
ExecStart=/usr/bin/code-server --config /home/${code_user}/.config/code-server/config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now code-server

# --- Install and Configure Caddy for HTTPS ---
echo "[6/6] Installing and configuring Caddy as a reverse proxy..."
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update -y
apt-get install -y caddy

systemctl enable --now caddy

echo "===== VS Code Server setup complete! ====="
echo "Access your IDE at: https://${vscode_domain}"