# 🚀 VS Code Server on Oracle Cloud Infrastructure (OCI)

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://www.oracle.com/cloud/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Deploy VS Code Server on Oracle Cloud Infrastructure using **Always Free Tier** resources - completely free forever!

## ✨ Features

- **💰 Always Free** - Uses OCI Always Free Tier resources ($0/month)
- **🚀 High Performance** - ARM-based Ampere A1 processors (up to 4 OCPUs, 24 GB RAM)
- **🔒 Secure** - VCN with security lists and network security groups
- **📦 Automated** - Complete setup with cloud-init
- **🌐 Web-based IDE** - Access VS Code from anywhere
- **🔧 Customizable** - Flexible configuration options

## 🎯 OCI Always Free Tier Resources

This deployment uses the following Always Free resources:

### Compute
- **2x AMD VMs**: VM.Standard.E2.1.Micro (1 OCPU, 1 GB RAM each)
- **OR 1x ARM VM**: VM.Standard.A1.Flex (up to 4 OCPUs, 24 GB RAM) **← Recommended**

### Storage
- **200 GB** total boot volume storage
- **200 GB** total block volume storage

### Network
- **2 VCNs** with associated resources
- **10 TB/month** outbound data transfer
- **1 Public IPv4** address

### Additional Services
- **Monitoring**: All metrics and alarms
- **Notifications**: 1 million/month
- **Object Storage**: 10 GB
- **Archive Storage**: 10 GB

## 📋 Prerequisites

### 1. OCI Account Setup

1. **Create OCI Account**
   - Sign up at [oracle.com/cloud/free](https://www.oracle.com/cloud/free/)
   - Verify your email and complete registration
   - No credit card required for Always Free resources

2. **Generate API Key**
   ```bash
   mkdir -p ~/.oci
   openssl genrsa -out ~/.oci/oci_api_key.pem 2048
   openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
   ```

3. **Add API Key to OCI Console**
   - Go to: Profile → User Settings → API Keys
   - Click "Add API Key"
   - Upload `oci_api_key_public.pem`
   - Copy the configuration file preview

4. **Get Required OCIDs**
   - **Tenancy OCID**: Profile → Tenancy → OCID
   - **User OCID**: Profile → User Settings → OCID
   - **Compartment OCID**: Identity → Compartments → Select compartment → OCID
   - **Fingerprint**: Shown when you added the API key

### 2. Local Tools

- **Terraform** >= 1.3.0
- **SSH** client
- **Git** (optional)

## 🚀 Quick Start (5 Minutes)

### Option A: Automated Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-org/vscode-server-cloud.git
cd vscode-server-cloud/oci

# Run the automated setup script
./setup-credentials.sh

# This script will:
# 1. Generate OCI API keys (if needed)
# 2. Guide you through credential setup
# 3. Create terraform.tfvars file
# 4. Optionally run terraform init
```

### Option B: Manual Setup

#### Step 1: Clone and Configure

```bash
# Clone the repository
git clone https://github.com/your-org/vscode-server-cloud.git
cd vscode-server-cloud/oci

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

#### Step 2: Minimum Configuration

Edit `terraform.tfvars` with your OCI details:

```hcl
# Required - Get these from OCI Console
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaa..."
user_ocid        = "ocid1.user.oc1..aaaaaaa..."
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
compartment_id   = "ocid1.compartment.oc1..aaaaaaa..."

# Required - Set a strong password
vscode_password = "YourSecurePassword123!"

# Recommended - Use ARM for better performance
instance_shape         = "VM.Standard.A1.Flex"
instance_ocpus         = 2
instance_memory_in_gbs = 12
```

**Need help getting these values? See [OCI_AUTH_SETUP.md](./OCI_AUTH_SETUP.md)**

### Step 3: Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy (takes 3-5 minutes)
terraform apply
```

### Step 4: Access

```bash
# Get access information
terraform output access_instructions

# Access VS Code Server
# Open browser to: http://YOUR_PUBLIC_IP:8080
```

## 🎨 Configuration Options

### Instance Shapes

#### Option 1: ARM-based (Recommended)
```hcl
instance_shape         = "VM.Standard.A1.Flex"
instance_ocpus         = 2              # 1-4 OCPUs
instance_memory_in_gbs = 12             # 6 GB per OCPU recommended
boot_volume_size_in_gbs = 100           # Up to 200 GB
```

**Benefits:**
- ✅ Better performance (ARM Ampere A1)
- ✅ More resources (up to 4 OCPUs, 24 GB RAM)
- ✅ Lower power consumption
- ✅ Modern architecture

#### Option 2: AMD-based
```hcl
instance_shape          = "VM.Standard.E2.1.Micro"
boot_volume_size_in_gbs = 50
```

**Benefits:**
- ✅ x86 compatibility
- ✅ Can run 2 instances
- ✅ Simpler configuration

### Operating Systems

```hcl
# Ubuntu 22.04 (Recommended)
os_type = "ubuntu"

# Oracle Linux 8
os_type = "oracle-linux"
```

### Security

```hcl
# Restrict SSH to your IP (recommended)
allowed_ssh_cidr = "203.0.113.42/32"

# Allow HTTPS from anywhere
allowed_https_cidr = "0.0.0.0/0"

# Custom VS Code Server port
vscode_port = 8080

# Enable HTTPS
enable_https = true
```

## 📊 Cost Analysis

### Always Free Resources

| Resource | Free Tier Limit | This Deployment | Cost |
|----------|----------------|-----------------|------|
| Compute (ARM) | 4 OCPUs, 24 GB RAM | 2 OCPUs, 12 GB RAM | **$0** |
| Boot Volume | 200 GB | 100 GB | **$0** |
| Outbound Transfer | 10 TB/month | ~100 GB/month | **$0** |
| Public IP | 1 per instance | 1 | **$0** |
| VCN | 2 VCNs | 1 VCN | **$0** |
| **Total** | | | **$0/month** |

### Comparison with Other Clouds

| Provider | Free Tier | Monthly Cost |
|----------|-----------|--------------|
| **OCI** | Always Free (no time limit) | **$0** |
| AWS | 12 months free | $8-15 after |
| GCP | $300 credit (90 days) | $8-15 after |
| Azure | $200 credit (30 days) | $10-20 after |

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    OCI Tenancy                          │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Virtual Cloud Network                │  │
│  │                 (10.0.0.0/16)                     │  │
│  │                                                   │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │         Public Subnet (10.0.1.0/24)        │  │  │
│  │  │                                             │  │  │
│  │  │  ┌────────────────────────────────────┐    │  │  │
│  │  │  │   Compute Instance                 │    │  │  │
│  │  │  │   VM.Standard.A1.Flex              │    │  │  │
│  │  │  │   - 2 OCPUs, 12 GB RAM             │    │  │  │
│  │  │  │   - Ubuntu 22.04                   │    │  │  │
│  │  │  │   - VS Code Server :8080           │    │  │  │
│  │  │  │   - Public IP                      │    │  │  │
│  │  │  └────────────────────────────────────┘    │  │  │
│  │  │                                             │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  Security:                                        │  │
│  │  - Internet Gateway                               │  │
│  │  - Security List (Firewall)                       │  │
│  │  - Network Security Group                         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  Monitoring & Management:                              │
│  - OCI Monitoring (Always Free)                        │
│  - Cloud Shell Access                                  │
│  - Console Access                                      │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Operations

### Accessing Your Instance

#### Via Web Browser
```
http://YOUR_PUBLIC_IP:8080
```

#### Via SSH
```bash
# Ubuntu
ssh ubuntu@YOUR_PUBLIC_IP

# Oracle Linux
ssh opc@YOUR_PUBLIC_IP
```

### Managing VS Code Server

```bash
# Check status
sudo systemctl status code-server

# Restart
sudo systemctl restart code-server

# View logs
sudo journalctl -u code-server -f

# Stop
sudo systemctl stop code-server

# Start
sudo systemctl start code-server
```

### Updating VS Code Server

```bash
# SSH into instance
ssh ubuntu@YOUR_PUBLIC_IP

# Update code-server
curl -fsSL https://code-server.dev/install.sh | sh

# Restart service
sudo systemctl restart code-server
```

### Scaling Resources

To change instance resources (ARM Flex only):

```hcl
# Edit terraform.tfvars
instance_ocpus         = 4   # Increase to 4 OCPUs
instance_memory_in_gbs = 24  # Increase to 24 GB

# Apply changes
terraform apply
```

**Note:** You'll need to stop the instance first:
```bash
# Stop instance
oci compute instance action --instance-id <INSTANCE_ID> --action STOP

# Apply Terraform changes
terraform apply

# Start instance
oci compute instance action --instance-id <INSTANCE_ID> --action START
```

## 🔒 Security Best Practices

### 1. Restrict SSH Access
```hcl
# Only allow SSH from your IP
allowed_ssh_cidr = "YOUR_IP/32"
```

### 2. Use Strong Passwords
```hcl
# Minimum 12 characters with mixed case, numbers, and symbols
vscode_password = "MyStr0ng!P@ssw0rd2024"
```

### 3. Enable HTTPS
```hcl
enable_https = true
```

### 4. Regular Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y  # Ubuntu
sudo yum update -y                       # Oracle Linux
```

### 5. Enable OCI Security Features
- Use OCI Bastion service for SSH access
- Enable Cloud Guard for threat detection
- Configure Security Zones
- Enable audit logging

## 📈 Monitoring

### OCI Console
- Navigate to: Compute → Instances → Your Instance
- View metrics: CPU, Memory, Network, Disk

### Command Line
```bash
# Check system resources
htop

# Check disk usage
df -h

# Check memory
free -h

# Check network
ss -tulpn
```

## 🐛 Troubleshooting

### Issue: 401-NotAuthenticated Error

**Error Message:**
```
Error: 401-NotAuthenticated, The required information to complete 
authentication was not provided or was incorrect.
```

**This means Terraform cannot authenticate with OCI.** 

**Quick Fix:**
```bash
# Run the automated setup script
cd oci
./setup-credentials.sh
```

**Manual Fix:**

1. **Verify your `terraform.tfvars` file exists and contains:**
   ```hcl
   tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaa..."
   user_ocid        = "ocid1.user.oc1..aaaaaaa..."
   fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
   private_key_path = "~/.oci/oci_api_key.pem"
   compartment_id   = "ocid1.compartment.oc1..aaaaaaa..."
   region           = "us-phoenix-1"
   vscode_password  = "YourSecurePassword123!"
   ```

2. **Verify private key file exists:**
   ```bash
   ls -la ~/.oci/oci_api_key.pem
   chmod 600 ~/.oci/oci_api_key.pem
   ```

3. **Verify fingerprint matches OCI Console:**
   - Go to: Profile → User Settings → API Keys
   - Compare the fingerprint shown with your `terraform.tfvars`

4. **Test OCI authentication:**
   ```bash
   # Install OCI CLI (optional)
   pip install oci-cli
   
   # Test connection
   oci iam region list --config-file ~/.oci/config
   ```

**See [OCI_AUTH_SETUP.md](./OCI_AUTH_SETUP.md) for detailed authentication setup guide.**

### Issue: Can't access VS Code Server

**Solution 1: Check if service is running**
```bash
ssh ubuntu@YOUR_PUBLIC_IP
sudo systemctl status code-server
```

**Solution 2: Check firewall**
```bash
sudo ufw status
sudo ufw allow 8080/tcp
```

**Solution 3: Check cloud-init logs**
```bash
sudo cat /var/log/cloud-init-output.log
sudo cloud-init status
```

### Issue: Instance not starting

**Solution: Check OCI Console**
- Go to: Compute → Instances
- Check instance state and work requests
- Review any error messages

### Issue: Out of Free Tier resources

**Solution: Check your usage**
```bash
# List all instances
oci compute instance list --compartment-id <COMPARTMENT_ID>

# Check boot volumes
oci bv boot-volume list --compartment-id <COMPARTMENT_ID>
```

### Issue: Terraform errors

**Solution 1: Check credentials**
```bash
# Verify OCI CLI configuration
oci iam region list

# Test authentication
oci iam availability-domain list
```

**Solution 2: Check quotas**
- Go to: Governance → Limits, Quotas and Usage
- Verify you have available Always Free resources

## 📚 Additional Resources

### OCI Documentation
- [Always Free Services](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm)
- [Compute Documentation](https://docs.oracle.com/en-us/iaas/Content/Compute/home.htm)
- [Networking Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)

### VS Code Server
- [Official Documentation](https://coder.com/docs/code-server)
- [GitHub Repository](https://github.com/coder/code-server)

### Terraform
- [OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
- [VS Code Server](https://github.com/coder/code-server)
- [Terraform](https://www.terraform.io/)

---

<div align="center">
  <strong>Deploy your free cloud IDE today! 🚀</strong>
  <br><br>
  Made with ❤️ for the developer community
</div>
