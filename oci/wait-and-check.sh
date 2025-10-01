#!/bin/bash
# Wait for cloud-init to complete and verify VS Code Server

SERVER_IP="193.123.190.9"
SSH_USER="ubuntu"

echo "=========================================="
echo "Waiting for VS Code Server Installation"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Wait for cloud-init to complete"
echo "2. Verify code-server installation"
echo "3. Start the service if needed"
echo "4. Show you the access URL"
echo ""
echo "This may take 5-10 minutes..."
echo "=========================================="
echo ""

# SSH and wait for cloud-init
ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" 'bash -s' << 'ENDSSH'
echo "⏳ Waiting for cloud-init to finish..."
sudo cloud-init status --wait
echo "✓ Cloud-init completed!"
echo ""

# Check if code-server is installed
if command -v code-server &> /dev/null; then
    echo "✓ Code-server is installed"
    code-server --version
else
    echo "❌ Code-server not installed. Installing now..."
    curl -fsSL https://code-server.dev/install.sh | sh
fi

echo ""

# Check service status
if sudo systemctl is-active code-server &> /dev/null; then
    echo "✓ Code-server service is RUNNING"
elif sudo systemctl is-active code-server@ubuntu &> /dev/null; then
    echo "✓ Code-server service is RUNNING (user service)"
else
    echo "⚠️  Code-server service not running. Starting..."
    
    # Try to start the service
    if sudo systemctl start code-server 2>/dev/null; then
        echo "✓ Started code-server service"
    elif sudo systemctl start code-server@ubuntu 2>/dev/null; then
        echo "✓ Started code-server@ubuntu service"
    else
        echo "❌ Could not start service automatically"
        echo "   Manual start required"
    fi
fi

echo ""
echo "=========================================="
echo "Service Status:"
echo "=========================================="
sudo systemctl status code-server --no-pager 2>/dev/null || \
sudo systemctl status code-server@ubuntu --no-pager 2>/dev/null || \
echo "Service not found"

echo ""
echo "=========================================="
echo "Configuration:"
echo "=========================================="
if [ -f ~/.config/code-server/config.yaml ]; then
    echo "Config file found:"
    cat ~/.config/code-server/config.yaml
else
    echo "Config file not found at ~/.config/code-server/config.yaml"
fi

echo ""
echo "=========================================="
ENDSSH

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Access VS Code Server at:"
echo "  http://$SERVER_IP:8080"
echo ""
echo "If it's not accessible yet, check:"
echo "  ssh $SSH_USER@$SERVER_IP"
echo "  sudo systemctl status code-server"
echo "  sudo journalctl -u code-server -f"
echo ""
echo "=========================================="
