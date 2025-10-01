# 🔧 Fix for 401-NotAuthenticated Error

## Problem
You're seeing this error when running Terraform:
```
Error: 401-NotAuthenticated, The required information to complete 
authentication was not provided or was incorrect.
```

## Root Cause
Terraform cannot authenticate with Oracle Cloud Infrastructure because:
- Missing or incorrect OCI credentials
- `terraform.tfvars` file doesn't exist or is incomplete
- Private API key file is missing or has wrong path
- Fingerprint doesn't match the API key uploaded to OCI

## Quick Fix (Recommended)

Run the automated setup script:

```bash
cd /home/mrbhardw/Documents/vscode-server-remote-dev/oci
./setup-credentials.sh
```

This script will:
1. ✅ Generate OCI API keys (if you don't have them)
2. ✅ Show you the public key to upload to OCI Console
3. ✅ Prompt you for all required credentials
4. ✅ Create a properly formatted `terraform.tfvars` file
5. ✅ Set correct file permissions
6. ✅ Optionally run `terraform init` for you

## Manual Fix

If you prefer to set up manually, follow these steps:

### 1. Generate API Keys (if you don't have them)

```bash
mkdir -p ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
chmod 600 ~/.oci/oci_api_key.pem
chmod 644 ~/.oci/oci_api_key_public.pem
```

### 2. Upload Public Key to OCI Console

1. Display your public key:
   ```bash
   cat ~/.oci/oci_api_key_public.pem
   ```

2. Go to OCI Console: https://cloud.oracle.com/
3. Click profile icon → **User Settings**
4. Click **API Keys** → **Add API Key**
5. Select **Paste Public Key**
6. Paste the public key
7. Click **Add**
8. **Copy the Fingerprint** (format: `xx:xx:xx:xx:...`)

### 3. Get Your OCIDs

#### Tenancy OCID
- Click profile icon → **Tenancy: [Your Tenancy Name]**
- Copy the **OCID** value

#### User OCID
- Click profile icon → **User Settings**
- Copy the **OCID** value

#### Compartment OCID
- Go to: **Identity & Security** → **Compartments**
- Find your compartment (or use root compartment = tenancy OCID)
- Copy the **OCID** value

### 4. Create terraform.tfvars

Create the file at: `/home/mrbhardw/Documents/vscode-server-remote-dev/oci/terraform.tfvars`

```hcl
# OCI Authentication
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "/home/mrbhardw/.oci/oci_api_key.pem"
compartment_id   = "ocid1.compartment.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
region           = "us-phoenix-1"

# Application Configuration
vscode_password = "YourSecurePassword123!"

# Instance Configuration (Optional)
instance_shape          = "VM.Standard.A1.Flex"
instance_ocpus          = 2
instance_memory_in_gbs  = 12
boot_volume_size_in_gbs = 100
os_type                 = "ubuntu"
```

### 5. Set File Permissions

```bash
chmod 600 /home/mrbhardw/Documents/vscode-server-remote-dev/oci/terraform.tfvars
chmod 600 ~/.oci/oci_api_key.pem
```

### 6. Test Authentication

```bash
cd /home/mrbhardw/Documents/vscode-server-remote-dev/oci
terraform init
terraform plan
```

If authentication works, you should see a plan output instead of 401 errors.

## Verification Checklist

Before running Terraform, verify:

- [ ] Private key file exists: `ls -la ~/.oci/oci_api_key.pem`
- [ ] Private key has correct permissions: `600`
- [ ] Public key uploaded to OCI Console
- [ ] Fingerprint in `terraform.tfvars` matches OCI Console
- [ ] All OCIDs start with correct prefix:
  - Tenancy: `ocid1.tenancy.oc1..`
  - User: `ocid1.user.oc1..`
  - Compartment: `ocid1.compartment.oc1..` or `ocid1.tenancy.oc1..`
- [ ] `terraform.tfvars` file exists and is readable
- [ ] Password is at least 12 characters

## Still Having Issues?

### Check Fingerprint
```bash
# Get fingerprint from your private key
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c
```

Compare this with the fingerprint shown in OCI Console → User Settings → API Keys

### Test with OCI CLI
```bash
# Install OCI CLI
pip install oci-cli

# Configure
oci setup config

# Test connection
oci iam region list
```

### Enable Debug Logging
```bash
export TF_LOG=DEBUG
terraform plan
```

## Additional Resources

- **Detailed Setup Guide**: [OCI_AUTH_SETUP.md](./OCI_AUTH_SETUP.md)
- **Main README**: [README.md](./README.md)
- **OCI Documentation**: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm
- **Terraform OCI Provider**: https://registry.terraform.io/providers/oracle/oci/latest/docs

## Next Steps

Once authentication is working:

```bash
cd /home/mrbhardw/Documents/vscode-server-remote-dev/oci

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy the infrastructure
terraform apply

# Get access information
terraform output
```

Your VS Code Server will be accessible at: `http://YOUR_PUBLIC_IP:8080`

---

**Need more help?** Check the troubleshooting section in [README.md](./README.md#-troubleshooting)
