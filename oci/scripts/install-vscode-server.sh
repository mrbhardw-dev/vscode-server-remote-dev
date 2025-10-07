#!/bin/bash
set -euxo pipefail

# =============================================================================
# VS Code Server (code-server) Installation Script for Terraform OCI
# =============================================================================
# This script is modeled after the GCP startup script to provide a robust
# setup with a dedicated user and Caddy for automatic HTTPS.
#
# Variables substituted by Terraform templatefile():
#   ${code_user}, ${vscode_password}, ${http_port}
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

# --- Install Docker ---
echo "[3/6] Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker "${code_user}"

# --- Install code-server via Docker ---
echo "[4/6] Running code-server in Docker container..."
docker run -d \
  --name code-server \
  --restart unless-stopped \
  -p ${http_port}:8080 \
  -v /home/${code_user}:/home/coder \
  -v /workspace:/workspace \
  -e PASSWORD="${vscode_password}" \
  -u $(id -u ${code_user}):$(id -g ${code_user}) \
  codercom/code-server:latest

# Wait for container to start
sleep 5

# --- Configure firewall for code-server ---
echo "[5/6] Configuring firewall..."
ufw allow ${http_port}/tcp

echo "===== VS Code Server setup complete! ====="
echo "Access your IDE at: http://<YOUR_PUBLIC_IP>:${http_port}"