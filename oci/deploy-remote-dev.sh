#!/bin/bash
# =============================================================================
# DEPLOY VS CODE REMOTE DEVELOPMENT ENVIRONMENT
# =============================================================================
# This script deploys the enhanced remote development environment on OCI
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "versions.tf" ]]; then
    print_error "Please run this script from the Terraform directory containing versions.tf"
    exit 1
fi

print_status "🚀 Deploying VS Code Remote Development Environment"
echo "=================================================="

# Check if consolidated configuration files exist
CONSOLIDATED_FILES=(
    "terraform.tfvars"
    "variables-consolidated.tf"
    "locals-consolidated.tf"
    "compute-consolidated.tf"
    "network-consolidated.tf"
    "outputs-consolidated.tf"
    "scripts/cloud-init-remote-dev.yaml"
)

print_status "Checking consolidated configuration files..."
for file in "${CONSOLIDATED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "✓ Found: $file"
    else
        print_error "✗ Missing: $file"
        exit 1
    fi
done

# Use existing consolidated configuration
print_status "Using consolidated configuration..."

# Backup existing configuration
cp terraform.tfvars terraform.tfvars.backup 2>/dev/null || true

print_status "Configuration ready - using terraform.tfvars and consolidated files"


# Validate Terraform configuration
print_status "Validating Terraform configuration..."
if terraform validate; then
    print_success "✓ Configuration is valid"
else
    print_error "✗ Configuration validation failed"
    exit 1
fi

# Initialize Terraform if needed
if [[ ! -d ".terraform" ]]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Create deployment plan
print_status "Creating deployment plan..."
if terraform plan ; then
    print_success "✓ Plan created successfully"
else
    print_error "✗ Plan creation failed"
    print_warning "Retrying with state refresh..."
    if terraform plan -refresh=true; then
        print_success "✓ Plan created successfully on retry"
    else
        print_error "✗ Plan creation failed on retry"
        exit 1
    fi
fi

# Show plan summary
print_status "Plan Summary:"
terraform show -no-color remote-dev.tfplan | grep -E "(Plan:|will be created|will be destroyed|will be modified)" || true

# Confirm deployment
echo
print_warning "⚠️  This will deploy the following resources:"
echo "   • ARM-based compute instance (2 OCPU, 8GB RAM)"
echo "   • 50GB persistent workspace volume"
echo "   • Enhanced network security configuration"
echo "   • Complete development environment setup"
echo
read -p "$(echo -e ${YELLOW}Do you want to proceed with deployment? [y/N]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled"
    exit 0
fi

# Deploy infrastructure
print_status "🚀 Deploying remote development environment..."
echo "This may take 10-15 minutes..."

if terraform apply -auto-approve ; then
    print_success "🎉 Deployment completed successfully!"
else
    print_error "Deployment failed"
    print_warning "Checking if partial deployment occurred..."
    terraform show -no-color | grep -E "(id =|state =)" | head -10 || true
    exit 1
fi

# Show outputs
print_status "📋 Deployment Summary:"
terraform output -json > deployment_outputs.json

# Extract key information
INSTANCE_IP=$(terraform output -raw public_ip 2>/dev/null || echo "Not available")
SSH_COMMAND=$(terraform output -json ssh_connection 2>/dev/null | jq -r '.command' 2>/dev/null || echo "ssh developer@$INSTANCE_IP")

echo
print_success "🎯 Remote Development Environment Ready!"
echo "=================================================="
echo -e "${BLUE}Public IP:${NC} $INSTANCE_IP"
echo -e "${BLUE}SSH Command:${NC} $SSH_COMMAND"
echo -e "${BLUE}Workspace:${NC} /workspace"
echo
print_status "Next Steps:"
echo "1. Wait 5-10 minutes for complete setup"
echo "2. Install 'Remote - SSH' extension in VS Code"
echo "3. Connect to: developer@$INSTANCE_IP"
echo "4. Open folder: /workspace"
echo "5. Start coding!"
echo
print_status "📖 Full deployment details saved to:"
echo "   • deployment_outputs.json"
echo "   • deployment.tfvars"
echo
print_warning "💡 Pro Tip: Run 'terraform output quick_start_commands' for detailed instructions"

print_success "✅ Deployment script completed!"