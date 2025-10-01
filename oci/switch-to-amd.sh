#!/bin/bash
# Quick script to switch to AMD instance type

echo "Switching to AMD instance (VM.Standard.E2.1.Micro)..."
echo ""

# Backup current config
cp terraform.tfvars terraform.tfvars.backup.$(date +%Y%m%d_%H%M%S)

# Update to AMD instance
sed -i 's/^instance_shape[[:space:]]*=.*/instance_shape = "VM.Standard.E2.1.Micro"/' terraform.tfvars

# Comment out ARM-specific settings (these don't apply to AMD)
sed -i 's/^instance_ocpus[[:space:]]*=/# instance_ocpus =/' terraform.tfvars
sed -i 's/^instance_memory_in_gbs[[:space:]]*=/# instance_memory_in_gbs =/' terraform.tfvars

echo "✓ Configuration updated!"
echo ""
echo "New instance specs:"
echo "  - Shape: VM.Standard.E2.1.Micro (AMD)"
echo "  - CPU: 1 OCPU"
echo "  - RAM: 1 GB"
echo "  - Storage: 50-100 GB"
echo "  - Always available (no capacity issues)"
echo ""
echo "Backup saved to: terraform.tfvars.backup.$(date +%Y%m%d_%H%M%S)"
echo ""
