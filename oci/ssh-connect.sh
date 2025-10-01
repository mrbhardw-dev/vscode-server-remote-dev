#!/bin/bash
# Quick SSH connection script for OCI VS Code Server

PUBLIC_IP="193.123.190.9"
SSH_USER="ubuntu"
SSH_KEY="~/.ssh/id_rsa"

echo "Connecting to VS Code Server instance..."
echo "IP: $PUBLIC_IP"
echo "User: $SSH_USER"
echo ""

ssh -i "$SSH_KEY" "$SSH_USER@$PUBLIC_IP"
