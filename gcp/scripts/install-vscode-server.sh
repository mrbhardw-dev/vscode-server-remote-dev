#!/bin/bash
set -euxo pipefail

# =============================================================================
# VS Code Server (code-server) Installation Script
# =============================================================================

# --- Log function ---
log() { echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"; }

log "Starting VS Code Server setup on Ubuntu 22..."

# --- Environment variables (from your Terraform input) ---
CODE_SERVER_USER="coder"
CODE_SERVER_PASSWORD="P@ssw0rd@123"
CODE_SERVER_DOMAIN="vscode-gcp.mbtux.com"
LETSENCRYPT_EMAIL="mritunjay.bhardwaj@mbtux.com"
HTTP_PORT="8080"

# --- Create dedicated user ---
log "Creating user '${CODE_SERVER_USER}'..."
if ! id -u "${CODE_SERVER_USER}" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "${CODE_SERVER_USER}"
    usermod -aG sudo "${CODE_SERVER_USER}"
    log "User created and added to sudoers group."
else
    log "User already exists."
fi

# Ensure proper home directory permissions BEFORE install
log "Setting initial permissions for /home/${CODE_SERVER_USER}..."
mkdir -p /home/${CODE_SERVER_USER}/.cache /home/${CODE_SERVER_USER}/.local/share/code-server/extensions
chown -R ${CODE_SERVER_USER}:${CODE_SERVER_USER} /home/${CODE_SERVER_USER}
chmod -R 700 /home/${CODE_SERVER_USER}

# --- Update system and install dependencies ---
log "Installing dependencies (curl, gnupg2, sudo, caddy prerequisites)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl gnupg2 software-properties-common sudo debian-keyring debian-archive-keyring apt-transport-https

# -------------------------------------------------------------
# --- Install code-server (FINAL FIX for HOME variable) ---
log "Installing code-server as root with HOME set..."
# Explicitly set HOME to /root for the non-interactive shell to resolve 
# the 'HOME: parameter not set' error during 'curl | sh' execution.
export HOME="/root" 
curl -fsSL https://code-server.dev/install.sh | sh
# -------------------------------------------------------------

# Re-assert user permissions after the installation
log "Re-setting permissions for /home/${CODE_SERVER_USER} after code-server install..."
# Reset HOME to ensure chown command is correct if the script uses it implicitly
export HOME="/home/${CODE_SERVER_USER}" 
chown -R ${CODE_SERVER_USER}:${CODE_SERVER_USER} /home/${CODE_SERVER_USER}
chmod -R 700 /home/${CODE_SERVER_USER}

# --- Configure code-server ---
log "Configuring code-server..."
mkdir -p /home/${CODE_SERVER_USER}/.config/code-server
cat > /home/${CODE_SERVER_USER}/.config/code-server/config.yaml <<EOF
bind-addr: 127.0.0.1:${HTTP_PORT}
auth: password
password: ${CODE_SERVER_PASSWORD}
cert: false
EOF
chown -R ${CODE_SERVER_USER}:${CODE_SERVER_USER} /home/${CODE_SERVER_USER}/.config

# --- Setup systemd service ---
log "Setting up systemd service..."
cat > /etc/systemd/system/code-server.service <<EOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=${CODE_SERVER_USER}
Group=${CODE_SERVER_USER}
ExecStart=/usr/bin/code-server --config /home/${CODE_SERVER_USER}/.config/code-server/config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now code-server

# --- Install Caddy for HTTPS ---
log "Installing Caddy..."
# Configuration setup for Caddy's repository
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update -y
apt-get install -y caddy

# --- Configure Caddy ---
log "Creating Caddyfile for reverse proxy and HTTPS..."
cat > /etc/caddy/Caddyfile <<EOF
${CODE_SERVER_DOMAIN} {
    reverse_proxy 127.0.0.1:${HTTP_PORT}
    tls ${LETSENCRYPT_EMAIL}
}
EOF

# Ensure Caddy service is running and configured
systemctl enable --now caddy
systemctl reload caddy

log "Setup complete! Access your VS Code Server at https://${CODE_SERVER_DOMAIN}"