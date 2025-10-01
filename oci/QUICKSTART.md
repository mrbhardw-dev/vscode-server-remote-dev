# ⚡ Quick Start - VS Code Server on OCI

Deploy VS Code Server on Oracle Cloud's **Always Free Tier** in 5 minutes!

## 🎯 What You'll Get

- **Free Forever**: $0/month using OCI Always Free Tier
- **High Performance**: ARM-based Ampere A1 (2 OCPUs, 12 GB RAM)
- **100 GB Storage**: SSD-backed boot volume
- **Web-based IDE**: Access from anywhere

## 📋 Before You Start

### 1. Create OCI Account (2 minutes)
1. Go to [oracle.com/cloud/free](https://www.oracle.com/cloud/free/)
2. Sign up (no credit card required for Always Free)
3. Verify your email

### 2. Generate API Key (1 minute)
```bash
mkdir -p ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

### 3. Add API Key to OCI (1 minute)
1. Login to OCI Console
2. Click Profile → User Settings → API Keys
3. Click "Add API Key"
4. Upload `~/.oci/oci_api_key_public.pem`
5. Copy the fingerprint shown

### 4. Get Your OCIDs (1 minute)
- **Tenancy OCID**: Profile → Tenancy → Copy OCID
- **User OCID**: Profile → User Settings → Copy OCID
- **Compartment OCID**: Identity → Compartments → Copy OCID

## 🚀 Deploy (5 minutes)

### Step 1: Download and Configure
```bash
# Clone repository
git clone https://github.com/your-org/vscode-server-cloud.git
cd vscode-server-cloud/oci

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

### Step 2: Minimum Configuration
```hcl
# Paste your OCI details
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaa..."  # From step 4
user_ocid        = "ocid1.user.oc1..aaaaaaa..."     # From step 4
fingerprint      = "xx:xx:xx:xx:..."                # From step 3
private_key_path = "~/.oci/oci_api_key.pem"         # From step 2
compartment_id   = "ocid1.compartment.oc1..aaaa..." # From step 4

# Set a strong password
vscode_password = "YourSecurePassword123!"

# Use ARM for best performance (recommended)
instance_shape         = "VM.Standard.A1.Flex"
instance_ocpus         = 2
instance_memory_in_gbs = 12
```

### Step 3: Deploy
```bash
# Initialize
terraform init

# Deploy
terraform apply
# Type 'yes' when prompted
```

### Step 4: Access
```bash
# Get your public IP
terraform output public_ip

# Open in browser
# http://YOUR_PUBLIC_IP:8080
```

## 🎉 You're Done!

Your VS Code Server is now running on Oracle Cloud's Always Free Tier!

## 🔧 Quick Commands

### Get Access Info
```bash
terraform output access_instructions
```

### SSH Access
```bash
# Ubuntu (default)
ssh ubuntu@$(terraform output -raw public_ip)

# Oracle Linux
ssh opc@$(terraform output -raw public_ip)
```

### Check Status
```bash
ssh ubuntu@$(terraform output -raw public_ip) 'sudo systemctl status code-server'
```

### View Logs
```bash
ssh ubuntu@$(terraform output -raw public_ip) 'sudo journalctl -u code-server -f'
```

### Destroy Everything
```bash
terraform destroy
```

## 💡 Pro Tips

### 1. Restrict SSH Access
```hcl
# In terraform.tfvars
allowed_ssh_cidr = "YOUR_IP/32"  # Replace with your IP
```

### 2. Use More Resources (Still Free!)
```hcl
# Maximum Free Tier ARM resources
instance_ocpus         = 4
instance_memory_in_gbs = 24
boot_volume_size_in_gbs = 200
```

### 3. Enable HTTPS
```hcl
enable_https = true
```

### 4. Change VS Code Port
```hcl
vscode_port = 8443
```

## 🐛 Troubleshooting

### Can't Access VS Code Server?

**Wait 2-3 minutes** after deployment for installation to complete.

Check installation status:
```bash
ssh ubuntu@YOUR_PUBLIC_IP 'sudo cloud-init status'
```

### Terraform Errors?

**Check your OCIDs** are correct:
```bash
# Test OCI CLI
oci iam region list
```

### Out of Free Tier Resources?

**Check your usage**:
1. Go to OCI Console
2. Navigate to: Governance → Limits, Quotas and Usage
3. Check "Always Free" resources

## 📚 Next Steps

1. **Secure Your Instance**: Restrict SSH to your IP
2. **Install Extensions**: Add your favorite VS Code extensions
3. **Set Up Git**: Configure git with your credentials
4. **Customize**: Adjust resources as needed
5. **Backup**: Enable boot volume backups

## 🆘 Need Help?

- **Full Documentation**: See [README.md](README.md)
- **OCI Free Tier**: [docs.oracle.com/free-tier](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm)
- **VS Code Server**: [coder.com/docs/code-server](https://coder.com/docs/code-server)

---

<div align="center">
  <strong>Happy Coding! 🚀</strong>
</div>
