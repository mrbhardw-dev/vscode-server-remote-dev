#!/bin/bash
# Check VS Code Server installation and service status

SERVER_IP="193.123.190.9"
SSH_USER="ubuntu"

echo "=========================================="
echo "VS Code Server Status Check"
echo "=========================================="
echo ""

# Check if we can SSH
echo "Testing SSH connection..."
if ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SSH_USER@$SERVER_IP" "echo 'Connected'" &>/dev/null; then
    echo "❌ Cannot connect via SSH"
    exit 1
fi
echo "✓ SSH connection successful"
echo ""

# Check cloud-init status
echo "Checking cloud-init status..."
CLOUD_INIT_STATUS=$(ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" "sudo cloud-init status" 2>&1)
echo "Cloud-init: $CLOUD_INIT_STATUS"
echo ""

# Check if code-server is installed
echo "Checking if code-server is installed..."
if ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" "command -v code-server" &>/dev/null; then
    echo "✓ code-server is installed"
    CODE_SERVER_VERSION=$(ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" "code-server --version 2>&1 | head -1")
    echo "  Version: $CODE_SERVER_VERSION"
else
    echo "⏳ code-server not installed yet (installation in progress)"
fi
echo ""

# Check code-server service status
echo "Checking code-server service..."
SERVICE_STATUS=$(ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" "sudo systemctl is-active code-server" 2>&1)
if [ "$SERVICE_STATUS" = "active" ]; then
    echo "✓ code-server service is RUNNING"
    echo ""
    echo "=========================================="
    echo "✓ VS Code Server is ready!"
    echo "=========================================="
    echo ""
    echo "Access URLs:"
    echo "  HTTP:  http://$SERVER_IP:8080"
    echo "  HTTPS: https://$SERVER_IP:8080"
    echo ""
    echo "Open in browser: http://$SERVER_IP:8080"
    echo "=========================================="
else
    echo "⏳ code-server service is NOT running yet"
    echo "   Status: $SERVICE_STATUS"
    echo ""
    echo "Installation is still in progress..."
    echo ""
    echo "To monitor progress, run:"
    echo "  ssh $SSH_USER@$SERVER_IP"
    echo "  sudo tail -f /var/log/cloud-init-output.log"
    echo ""
    echo "Or wait a few more minutes and run this script again:"
    echo "  ./check-vscode-status.sh"
fi
echo ""

# Show last few lines of cloud-init log
echo "Last 10 lines of installation log:"
echo "----------------------------------------"
ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" "sudo tail -10 /var/log/cloud-init-output.log" 2>&1
echo "----------------------------------------"
