# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated deployment and validation of VS Code Server infrastructure to GCP and OCI.

## Workflows

### 1. Deploy to GCP (`deploy-gcp.yml`)
Deploys VS Code Server infrastructure to Google Cloud Platform.

**Trigger:** Manual (workflow_dispatch)

**Inputs:**
- `action`: Choose between `plan`, `apply`, or `destroy`
- `environment`: Select `development`, `staging`, or `production`

**Required Secrets:**
- `GCP_CREDENTIALS` - GCP service account JSON key (entire file content)
- `GCP_PROJECT_ID` - Your GCP project ID
- `VSCODE_PASSWORD` - Password for VS Code Server (min 12 characters)
- `VSCODE_DOMAIN` - Domain name for VS Code Server
- `LETSENCRYPT_EMAIL` - Email for Let's Encrypt certificate notifications

### 2. Deploy to OCI (`deploy-oci.yml`)
Deploys VS Code Server infrastructure to Oracle Cloud Infrastructure.

**Trigger:** Manual (workflow_dispatch)

**Inputs:**
- `action`: Choose between `plan`, `apply`, or `destroy`
- `environment`: Select `development`, `staging`, or `production`

**Required Secrets:**
- `OCI_TENANCY_OCID` - Your OCI tenancy OCID
- `OCI_USER_OCID` - Your OCI user OCID
- `OCI_FINGERPRINT` - API key fingerprint
- `OCI_PRIVATE_KEY` - API private key (PEM format)
- `OCI_COMPARTMENT_ID` - Compartment OCID where resources will be created
- `OCI_REGION` - OCI region (e.g., us-phoenix-1)
- `VSCODE_PASSWORD` - Password for VS Code Server (min 12 characters)
- `SSH_PUBLIC_KEY` - SSH public key for instance access

### 3. Terraform Validate (`terraform-validate.yml`)
Automatically validates Terraform configuration on pull requests and pushes.

**Trigger:** Automatic on PR/push to main/master branch

**Features:**
- Terraform format checking
- Terraform validation
- Security scanning with Trivy
- Uploads security scan results to GitHub Security tab

## Setup Instructions

### Step 1: Configure GitHub Secrets

Navigate to your repository → Settings → Secrets and variables → Actions → New repository secret

#### For GCP Deployment:

1. **GCP_CREDENTIALS**
   ```bash
   # Copy the entire content of your service account JSON file
   cat path/to/your-service-account-key.json
   ```

2. **GCP_PROJECT_ID**
   ```
   your-gcp-project-id
   ```

3. **VSCODE_PASSWORD**
   ```
   YourSecurePassword123!
   ```

4. **VSCODE_DOMAIN**
   ```
   vscode.yourdomain.com
   ```

5. **LETSENCRYPT_EMAIL**
   ```
   admin@yourdomain.com
   ```

#### For OCI Deployment:

1. **OCI_TENANCY_OCID**
   ```
   ocid1.tenancy.oc1..aaaaaaa...
   ```

2. **OCI_USER_OCID**
   ```
   ocid1.user.oc1..aaaaaaa...
   ```

3. **OCI_FINGERPRINT**
   ```
   aa:bb:cc:dd:ee:ff:11:22:33:44:55:66:77:88:99:00
   ```

4. **OCI_PRIVATE_KEY**
   ```bash
   # Copy your entire private key including headers
   cat ~/.oci/oci_api_key.pem
   ```

5. **OCI_COMPARTMENT_ID**
   ```
   ocid1.compartment.oc1..aaaaaaa...
   ```

6. **OCI_REGION**
   ```
   us-phoenix-1
   ```

7. **VSCODE_PASSWORD**
   ```
   YourSecurePassword123!
   ```

8. **SSH_PUBLIC_KEY**
   ```bash
   # Copy your SSH public key
   cat ~/.ssh/id_rsa.pub
   ```

### Step 2: Configure Environments (Optional but Recommended)

For better control and approval workflows:

1. Go to Settings → Environments
2. Create environments: `development`, `staging`, `production`
3. For `production`, enable "Required reviewers" to require approval before deployment
4. Set environment-specific secrets if needed

### Step 3: Run Workflows

#### To Deploy:

1. Go to Actions tab in your repository
2. Select "Deploy to GCP" or "Deploy to OCI"
3. Click "Run workflow"
4. Select:
   - Branch (usually `main` or `master`)
   - Action (`plan` to preview, `apply` to deploy, `destroy` to tear down)
   - Environment
5. Click "Run workflow"

#### Workflow Execution Order:

**First Time Deployment:**
1. Run with `action: plan` to preview changes
2. Review the plan output
3. Run with `action: apply` to deploy

**To Destroy Infrastructure:**
1. Run with `action: destroy`
2. Confirm the destruction in the workflow logs

## Workflow Features

### Security Features
- ✅ Credentials are stored as GitHub secrets (encrypted)
- ✅ Credentials files are created temporarily and cleaned up after use
- ✅ Sensitive outputs are masked in logs
- ✅ Security scanning with Trivy on every PR
- ✅ Environment protection rules can require approvals

### Best Practices
- ✅ Separate workflows for each cloud provider
- ✅ Manual approval for production deployments (via environments)
- ✅ Terraform state is managed (configure backend in your Terraform files)
- ✅ Automatic validation on pull requests
- ✅ Artifact retention for Terraform outputs (30 days)

## Terraform State Management

**Important:** These workflows do not configure remote state storage. You should configure a backend in your Terraform files:

### GCP Backend (recommended):
```hcl
# Add to gcp/provider.tf
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "vscode-server/gcp"
  }
}
```

### OCI Backend (recommended):
```hcl
# Add to oci/versions.tf
terraform {
  backend "s3" {
    bucket   = "your-terraform-state-bucket"
    key      = "vscode-server/oci/terraform.tfstate"
    region   = "us-phoenix-1"
    endpoint = "https://your-namespace.compat.objectstorage.us-phoenix-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style           = true
  }
}
```

## Troubleshooting

### Common Issues

1. **"Credentials file not found"**
   - Ensure secrets are properly configured
   - Check secret names match exactly

2. **"Terraform init failed"**
   - Verify Terraform version compatibility
   - Check provider credentials are valid

3. **"Plan failed with validation error"**
   - Review variable values in secrets
   - Ensure all required secrets are set

4. **"Permission denied"**
   - GCP: Verify service account has necessary IAM roles
   - OCI: Verify user has required policies

### Getting Help

- Check workflow logs in the Actions tab
- Review Terraform error messages
- Verify all secrets are correctly configured
- Ensure your cloud provider credentials have necessary permissions

## Cost Considerations

**Important:** Running these workflows will create billable resources in your cloud account.

- **GCP:** Uses e2-micro instance (Free Tier eligible)
- **OCI:** Uses VM.Standard.E2.1.Micro or VM.Standard.A1.Flex (Always Free eligible)

Always run `terraform destroy` when you're done to avoid unnecessary charges.

## Contributing

When modifying workflows:
1. Test changes in a development environment first
2. Use `terraform plan` before `terraform apply`
3. Document any new secrets or configuration requirements
4. Update this README with any changes

## License

See the main repository LICENSE file.
