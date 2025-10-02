#!/bin/bash
# =============================================================================
# VS Code Server Installation Script with Let's Encrypt SSL
# =============================================================================
# This script installs and configures VS Code Server (code-server) with:
# - Let's Encrypt SSL certificates via Certbot
# - Nginx reverse proxy for HTTPS termination
# - Development tools (Git, Terraform)
# - Automatic certificate renewal
# =============================================================================

set -e  # Exit on any error

# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# -----------------------------------------------------------------------------
export HOME=/root
export PATH=$PATH:/usr/local/bin

# Configuration from Terraform template variables
DOMAIN="${vscode_domain}"
PASSWORD="${vscode_password}"
EMAIL="${letsencrypt_email}"
BIND_ADDR="${bind_addr}"
LOG_FILE="${log_file}"

# -----------------------------------------------------------------------------
# SYSTEM SETUP AND PACKAGE INSTALLATION
# -----------------------------------------------------------------------------
echo "Starting VS Code Server installation at $(date)"

# Update system packages
apt-get update

# Install essential development tools and certbot
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    gnupg \
    lsb-release \
    python3-certbot-nginx \
    nginx

# -----------------------------------------------------------------------------
# TERRAFORM INSTALLATION
# -----------------------------------------------------------------------------
echo "Installing Terraform..."

# Add HashiCorp GPG key and repository
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list

apt-get update && apt-get install -y terraform

# -----------------------------------------------------------------------------
# CODE-SERVER INSTALLATION
# -----------------------------------------------------------------------------
echo "Installing code-server..."

# Install code-server using official installer
curl -fsSL https://code-server.dev/install.sh | sh

# Create code-server configuration directory
mkdir -p ~/.config/code-server

# Configure code-server for HTTP (will be proxied through nginx with SSL)
cat > ~/.config/code-server/config.yaml << EOF
bind-addr: $${BIND_ADDR}
auth: password
password: $${PASSWORD}
cert: false
EOF

# -----------------------------------------------------------------------------
# NGINX CONFIGURATION AND SSL SETUP
# -----------------------------------------------------------------------------
echo "Configuring Nginx and Let's Encrypt..."

# Start and enable nginx service
systemctl start nginx
systemctl enable nginx

# Create initial nginx configuration for Let's Encrypt verification
cat > /etc/nginx/sites-available/code-server << EOF
server {
    listen 80;
    server_name $${DOMAIN};
    
    location / {
        proxy_pass http://$${BIND_ADDR};
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the nginx site configuration
ln -sf /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx configuration
nginx -t && systemctl reload nginx

# Wait for nginx to be ready
sleep 10

# Obtain Let's Encrypt certificate
echo "Obtaining Let's Encrypt certificate for $${DOMAIN}..."
certbot --nginx --non-interactive --agree-tos --email "$${EMAIL}" -d "$${DOMAIN}"

# Update nginx configuration with HTTPS redirect and SSL
cat > /etc/nginx/sites-available/code-server << EOF
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name $${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server with SSL termination
server {
    listen 443 ssl http2;
    server_name $${DOMAIN};
    
    # SSL certificate configuration
    ssl_certificate /etc/letsencrypt/live/$${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$${DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Proxy configuration for code-server
    location / {
        proxy_pass http://$${BIND_ADDR};
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Test and reload nginx with new SSL configuration
nginx -t && systemctl reload nginx

# -----------------------------------------------------------------------------
# CODE-SERVER SERVICE STARTUP
# -----------------------------------------------------------------------------
echo "Starting code-server service..."

# Start code-server in background (nginx will proxy HTTPS requests)
nohup code-server --bind-addr "$${BIND_ADDR}" > "$${LOG_FILE}" 2>&1 &

# -----------------------------------------------------------------------------
# CERTIFICATE RENEWAL SETUP
# -----------------------------------------------------------------------------
echo "Setting up automatic certificate renewal..."

# Setup automatic certificate renewal via cron
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

# -----------------------------------------------------------------------------
# INSTALLATION COMPLETION LOGGING
# -----------------------------------------------------------------------------
echo "Code-server with Let's Encrypt installation completed at $(date)" >> /var/log/code-server-install.log
echo "Domain: $${DOMAIN}" >> /var/log/code-server-install.log
echo "Certificate location: /etc/letsencrypt/live/$${DOMAIN}/" >> /var/log/code-server-install.log
echo "Log file: $${LOG_FILE}" >> /var/log/code-server-install.log

echo "VS Code Server installation completed successfully!"