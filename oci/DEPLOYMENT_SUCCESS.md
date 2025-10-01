# ✓ VS Code Server Deployment - SUCCESS

**Deployment Date:** October 1, 2025, 20:05 UTC

## Instance Information

- **Shape:** VM.Standard.E2.1.Micro (AMD)
- **CPU:** 1 OCPU
- **RAM:** 1 GB
- **Storage:** 100 GB
- **Region:** uk-london-1 (London, UK)
- **Status:** RUNNING
- **Cost:** $0/month (Always Free Tier)

## Network Details

- **Public IP:** `193.123.190.9`
- **Private IP:** `10.0.1.92`
- **VCN CIDR:** 10.0.0.0/16
- **Subnet CIDR:** 10.0.1.0/24

## Access Information

### VS Code Server (Web IDE)

```
URL: http://193.123.190.9:8080
HTTPS: https://193.123.190.9:8080
```

**Note:** Wait 2-3 minutes after deployment for VS Code Server to install automatically.

### SSH Access

```bash
ssh ubuntu@193.123.190.9
```

**User:** ubuntu  
**Key:** ~/.ssh/id_rsa (the key you configured)

## First Time Setup

1. **Wait for Installation** (2-3 minutes)
   - Cloud-init is installing VS Code Server in the background
   - The instance is ready when you can access the web interface

2. **Access VS Code Server**
   - Open: http://193.123.190.9:8080
   - Enter your VS Code password (set in terraform.tfvars)

3. **Verify Installation** (via SSH)
   ```bash
   ssh ubuntu@193.123.190.9
   sudo systemctl status code-server
   ```

## Management Commands

### Check Installation Status
```bash
# SSH into the instance
ssh ubuntu@193.123.190.9

# Check cloud-init status
sudo cloud-init status

# View installation logs
sudo cat /var/log/cloud-init-output.log

# Follow cloud-init progress
sudo journalctl -u cloud-final -f
```

### Manage VS Code Server
```bash
# Check status
sudo systemctl status code-server

# Start service
sudo systemctl start code-server

# Stop service
sudo systemctl stop code-server

# Restart service
sudo systemctl restart code-server

# View logs
sudo journalctl -u code-server -f

# Check configuration
cat ~/.config/code-server/config.yaml
```

### System Management
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
htop

# Reboot instance
sudo reboot
```

## Security Configuration

### Current Settings
- **SSH Access:** Open from 0.0.0.0/0 (all IPs)
- **HTTPS Access:** Open from 0.0.0.0/0 (all IPs)
- **VS Code Port:** 8080
- **HTTPS Enabled:** Yes (self-signed certificate)

### Recommended: Restrict SSH Access

Edit `terraform.tfvars`:
```hcl
allowed_ssh_cidr = "YOUR_IP_ADDRESS/32"
```

Then apply:
```bash
terraform apply
```

### Change VS Code Password

1. SSH into the instance
2. Edit the config:
   ```bash
   sudo nano ~/.config/code-server/config.yaml
   ```
3. Update the password
4. Restart the service:
   ```bash
   sudo systemctl restart code-server
   ```

## Troubleshooting

### Can't Access VS Code Server

1. **Check if service is running:**
   ```bash
   ssh ubuntu@193.123.190.9
   sudo systemctl status code-server
   ```

2. **Check if installation completed:**
   ```bash
   sudo cloud-init status
   sudo cat /var/log/cloud-init-output.log
   ```

3. **Restart the service:**
   ```bash
   sudo systemctl restart code-server
   ```

4. **Check firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 8080/tcp
   ```

### SSH Connection Issues

1. **Verify SSH key:**
   ```bash
   ls -la ~/.ssh/id_rsa
   chmod 600 ~/.ssh/id_rsa
   ```

2. **Use verbose mode:**
   ```bash
   ssh -v ubuntu@193.123.190.9
   ```

3. **Check security group rules in OCI Console**

### Instance Not Responding

1. **Check instance status in OCI Console:**
   - Go to: Compute → Instances
   - Verify instance is in "Running" state

2. **Reboot from console if needed**

3. **Check work requests for any errors**

## Upgrading Resources

### Switch Back to ARM (Better Performance)

If you want to try ARM again when capacity is available:

1. Edit `terraform.tfvars`:
   ```hcl
   instance_shape = "VM.Standard.A1.Flex"
   instance_ocpus = 2
   instance_memory_in_gbs = 12
   ```

2. Destroy and recreate:
   ```bash
   terraform destroy
   terraform apply
   ```

### Increase Storage

Edit `terraform.tfvars`:
```hcl
boot_volume_size_in_gbs = 150  # Up to 200 GB for Free Tier
```

Then apply:
```bash
terraform apply
```

## Monitoring

### OCI Console
- Navigate to: Compute → Instances → VS Code Server Instance
- View metrics: CPU, Memory, Network, Disk

### Enable Notifications

Edit `terraform.tfvars`:
```hcl
notification_email = "your-email@example.com"
```

Apply changes:
```bash
terraform apply
```

## Backup and Disaster Recovery

### Manual Backup
1. Go to OCI Console → Compute → Boot Volumes
2. Select your boot volume
3. Click "Create Boot Volume Backup"

### Automated Backups
Uncomment backup policy in `compute.tf` and apply

### Restore from Backup
1. Create new instance from boot volume backup
2. Update DNS/IP references

## Cost Optimization

- **Current Usage:** $0/month (Always Free)
- **Free Tier Limits:**
  - 2x AMD instances OR
  - 4 OCPUs + 24 GB RAM (ARM)
  - 200 GB boot volume storage
  - 10 TB/month outbound data transfer

**You're well within Free Tier limits!**

## Useful Links

- **OCI Console:** https://cloud.oracle.com/
- **Instance Details:** https://cloud.oracle.com/compute/instances
- **VS Code Server Docs:** https://coder.com/docs/code-server
- **OCI Free Tier:** https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm

## Terraform Commands

```bash
# View current state
terraform show

# View outputs
terraform output

# Refresh state
terraform refresh

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy all resources
terraform destroy
```

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review logs via SSH
3. Check OCI Console for work requests/errors
4. Refer to documentation in the `oci/` directory

---

**Deployment completed successfully!** 🎉

Your VS Code Server is now running at: **http://193.123.190.9:8080**
