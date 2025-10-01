# OCI Authentication Setup Guide

## Error: 401-NotAuthenticated

You're seeing this error because Terraform cannot authenticate with Oracle Cloud Infrastructure.

## Required Credentials

You need the following OCI credentials:

1. **Tenancy OCID** - Your OCI tenancy identifier
2. **User OCID** - Your OCI user identifier
3. **API Key Fingerprint** - Fingerprint of your API signing key
4. **Private Key** - Your API signing private key file
5. **Compartment OCID** - Where resources will be created
6. **Region** - OCI region (e.g., us-phoenix-1)

## How to Get These Credentials

### 1. Get Your Tenancy OCID
- Log in to OCI Console: https://cloud.oracle.com/
- Click on your profile icon (top right) → Tenancy: [Your Tenancy Name]
- Copy the **OCID** value

### 2. Get Your User OCID
- In OCI Console, click profile icon → User Settings
- Copy the **OCID** value

### 3. Generate API Key (if you don't have one)
```bash
# Create directory for OCI credentials
mkdir -p ~/.oci

# Generate API key pair
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

# Set proper permissions
chmod 600 ~/.oci/oci_api_key.pem
chmod 644 ~/.oci/oci_api_key_public.pem

# Display public key (you'll need to upload this)
cat ~/.oci/oci_api_key_public.pem
```

### 4. Upload Public Key to OCI
- In OCI Console, go to User Settings → API Keys
- Click "Add API Key"
- Select "Paste Public Key"
- Paste the contents of `~/.oci/oci_api_key_public.pem`
- Click "Add"
- **Copy the Fingerprint** that appears (format: xx:xx:xx:xx:...)

### 5. Get Compartment OCID
- In OCI Console, go to Identity & Security → Compartments
- Find your compartment (or use root compartment = tenancy OCID)
- Copy the **OCID** value

## Setup Options

### Option 1: Local Development (terraform.tfvars)

Create `oci/terraform.tfvars` file:

```hcl
# Required OCI Authentication
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
compartment_id   = "ocid1.compartment.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
region           = "us-phoenix-1"

# Required Application Configuration
vscode_password = "YourSecurePassword123!"

# Optional: Customize instance
instance_shape         = "VM.Standard.A1.Flex"
instance_ocpus         = 2
instance_memory_in_gbs = 12
os_type                = "ubuntu"
```

### Option 2: Environment Variables

Export these in your terminal:

```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaxxxxx..."
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaxxxxx..."
export TF_VAR_fingerprint="xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_compartment_id="ocid1.compartment.oc1..aaaaaaaxxxxx..."
export TF_VAR_region="us-phoenix-1"
export TF_VAR_vscode_password="YourSecurePassword123!"
```

### Option 3: GitHub Actions (CI/CD)

Set these as GitHub Secrets in your repository:
- Settings → Secrets and variables → Actions → New repository secret

Required secrets:
- `OCI_TENANCY_OCID`
- `OCI_USER_OCID`
- `OCI_FINGERPRINT`
- `OCI_PRIVATE_KEY` (entire contents of ~/.oci/oci_api_key.pem)
- `OCI_COMPARTMENT_ID`
- `OCI_REGION`
- `VSCODE_PASSWORD`
- `SSH_PUBLIC_KEY` (contents of ~/.ssh/id_rsa.pub)

## Verify Setup

After configuring credentials, test the connection:

```bash
cd oci
terraform init
terraform plan
```

If authentication works, you should see a plan output instead of 401 errors.

## Troubleshooting

### Still getting 401 errors?

1. **Verify private key path exists:**
   ```bash
   ls -la ~/.oci/oci_api_key.pem
   ```

2. **Check fingerprint matches:**
   - Compare the fingerprint in your config with the one shown in OCI Console → User Settings → API Keys

3. **Verify OCIDs format:**
   - Tenancy OCID starts with: `ocid1.tenancy.oc1..`
   - User OCID starts with: `ocid1.user.oc1..`
   - Compartment OCID starts with: `ocid1.compartment.oc1..` or `ocid1.tenancy.oc1..`

4. **Check private key permissions:**
   ```bash
   chmod 600 ~/.oci/oci_api_key.pem
   ```

5. **Test with OCI CLI (optional):**
   ```bash
   # Install OCI CLI
   pip install oci-cli
   
   # Configure
   oci setup config
   
   # Test
   oci iam region list
   ```

## Security Best Practices

1. **Never commit credentials to git**
   - `terraform.tfvars` is already in `.gitignore`
   - Never commit private keys

2. **Use restrictive file permissions**
   ```bash
   chmod 600 ~/.oci/oci_api_key.pem
   ```

3. **Rotate API keys regularly**
   - Generate new keys every 90 days
   - Delete old keys from OCI Console

4. **Use compartments for isolation**
   - Don't use root compartment for resources
   - Create dedicated compartment for this project

## Quick Start Command

Once credentials are configured:

```bash
cd oci
terraform init
terraform plan
terraform apply
```

## Need Help?

- OCI Documentation: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm
- Terraform OCI Provider: https://registry.terraform.io/providers/oracle/oci/latest/docs
