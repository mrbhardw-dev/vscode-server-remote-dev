# ⚡ Quick Start Guide

Get your VS Code Server running on GCP in 5 minutes!

## 📋 Prerequisites Checklist

- [ ] GCP account with billing enabled
- [ ] Terraform >= 1.3.0 installed
- [ ] gcloud CLI installed and configured
- [ ] Service account key file (JSON)
- [ ] Domain name (optional, for HTTPS)

## 🚀 5-Minute Setup

### Step 1: Clone and Navigate
```bash
git clone https://github.com/your-org/vscode-server-gcp.git
cd vscode-server-gcp/terraform
```

### Step 2: Configure Variables
```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Minimum Required Configuration:**
```hcl
project_id         = "your-gcp-project-id"
vscode_domain      = "code.yourdomain.com"
vscode_password    = "YourSecurePassword123!"
letsencrypt_email  = "your-email@example.com"
credentials_file   = "/path/to/service-account-key.json"
```

### Step 3: Initialize Terraform
```bash
terraform init
```

### Step 4: Review Plan
```bash
terraform plan
```

### Step 5: Deploy
```bash
terraform apply
```

Type `yes` when prompted.

### Step 6: Access Your Server
```bash
# Get the access information
terraform output access_instructions

# Access via browser
https://code.yourdomain.com
```

## 🎯 Common Configurations

### Development Environment
```hcl
environment        = "development"
machine_type       = "e2-micro"
boot_disk_size_gb  = 30
enable_monitoring  = false
enable_backup      = false
```

### Production Environment
```hcl
environment        = "production"
machine_type       = "e2-medium"
boot_disk_size_gb  = 50
enable_monitoring  = true
enable_backup      = true
admin_ip_cidr      = "YOUR_IP/32"  # Restrict access
```

### High-Performance Setup
```hcl
machine_type       = "n2-standard-4"
boot_disk_size_gb  = 100
boot_disk_type     = "pd-ssd"
```

## 🔧 Essential Commands

### View Outputs
```bash
terraform output
```

### SSH into Instance
```bash
gcloud compute ssh vscode-server-production-vm-0 \
  --zone=europe-west2-b \
  --project=your-project-id
```

### Update Configuration
```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Apply changes
terraform apply
```

### Destroy Infrastructure
```bash
terraform destroy
```

## 🐛 Quick Troubleshooting

### Issue: "Error: Invalid credentials"
**Solution:** Verify your service account key path in `credentials_file`

### Issue: "Error: API not enabled"
**Solution:** Enable required APIs:
```bash
gcloud services enable compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com
```

### Issue: "Error: Quota exceeded"
**Solution:** Check your GCP quotas and request increases if needed

### Issue: Can't access VS Code Server
**Solution:** 
1. Check firewall rules: `gcloud compute firewall-rules list`
2. Verify instance is running: `gcloud compute instances list`
3. Check startup script logs:
```bash
gcloud compute ssh vscode-server-production-vm-0 \
  --command="sudo journalctl -u google-startup-scripts.service"
```

## 📊 Cost Estimation

### Minimal Setup (e2-micro)
- **Compute**: ~$6/month
- **Storage (30GB)**: ~$1/month
- **Network**: ~$1/month
- **Total**: ~$8/month

### Production Setup (e2-medium)
- **Compute**: ~$25/month
- **Storage (50GB)**: ~$2/month
- **Network**: ~$2/month
- **Total**: ~$29/month

*Prices are estimates and may vary by region*

## 🔐 Security Checklist

- [ ] Use strong password (12+ characters)
- [ ] Restrict `admin_ip_cidr` to your IP
- [ ] Enable OS Login (`enable_os_login = true`)
- [ ] Enable monitoring (`enable_monitoring = true`)
- [ ] Never commit `terraform.tfvars` to git
- [ ] Rotate service account keys regularly
- [ ] Enable backups for production (`enable_backup = true`)

## 📚 Next Steps

1. **Customize**: Review `variables.tf` for all configuration options
2. **Secure**: Implement network restrictions and monitoring
3. **Backup**: Enable automated backups
4. **Monitor**: Set up Cloud Monitoring dashboards
5. **Scale**: Adjust `machine_type` and `boot_disk_size_gb` as needed

## 🆘 Need Help?

- **Documentation**: See [README.md](README.md)
- **Issues**: Check [IMPROVEMENTS.md](IMPROVEMENTS.md)
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)
- **Changes**: See [CHANGELOG.md](CHANGELOG.md)

## 💡 Pro Tips

1. **Use terraform workspaces** for multiple environments:
   ```bash
   terraform workspace new production
   terraform workspace new staging
   ```

2. **Enable remote state** for team collaboration:
   ```hcl
   # In versions.tf
   backend "gcs" {
     bucket = "your-terraform-state-bucket"
     prefix = "vscode-server/state"
   }
   ```

3. **Use variables for sensitive data**:
   ```bash
   export TF_VAR_vscode_password="SecurePassword123!"
   terraform apply
   ```

4. **Format and validate before applying**:
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan
   ```

5. **Tag resources for cost tracking**:
   ```hcl
   additional_tags = {
     team        = "engineering"
     cost-center = "development"
     project     = "vscode-server"
   }
   ```

---

<div align="center">
  <strong>Ready to code in the cloud! 🚀</strong>
</div>
