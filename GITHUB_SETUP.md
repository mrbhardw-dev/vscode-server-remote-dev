# GitHub Actions Setup Guide

This guide explains how to set up GitHub Actions for automated deployment of VS Code Server to both GCP and OCI.

## Prerequisites

1. **GitHub Repository**: Your code should be in a GitHub repository
2. **Cloud Provider Access**: 
   - GCP: Service account with appropriate permissions
   - OCI: API key and user credentials
3. **GitHub Secrets**: Configure the required secrets (see below)

## GitHub Secrets Configuration

### For GCP Deployment

Navigate to your GitHub repository → Settings → Secrets and variables → Actions → Repository secrets

Add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `GCP_SA_KEY` | GCP Service Account JSON key | Contents of your service account JSON file |
| `GCP_PROJECT_ID` | GCP Project ID | `solid-choir-472607-r1` |
| `GCP_REGION` | GCP Region | `europe-west2` |

### For OCI Deployment

Add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `OCI_TENANCY_OCID` | OCI Tenancy OCID | `ocid1.tenancy.oc1..aaaaaaaayovub2jj7ege5ceiafsxinoae7m4h676sruh6suucpyfkmrvpq3q` |
| `OCI_USER_OCID` | OCI User OCID | `ocid1.user.oc1..aaaaaaaalmxpngsey463cewp3v3fnafwgf736fsa6konrb6tqqj5qsfhzd4q` |
| `OCI_FINGERPRINT` | API Key Fingerprint | `7a:25:7e:26:80:ca:89:6f:f1:b4:4b:4d:3d:ed:30:8c` |
| `OCI_PRIVATE_KEY` | Private Key Content | Contents of your private key file |
| `OCI_COMPARTMENT_ID` | Compartment OCID | `ocid1.tenancy.oc1..aaaaaaaayovub2jj7ege5ceiafsxinoae7m4h676sruh6suucpyfkmrvpq3q` |
| `VSCODE_PASSWORD` | VS Code Server Password | `P@ssw0rd@12345678` |

## Workflow Features

### GCP Workflow (`gcp-deploy.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual dispatch with environment selection

**Jobs:**
1. **Validate**: Terraform format check and validation
2. **Plan**: Infrastructure planning (PR only)
3. **Deploy**: Infrastructure deployment (main branch)
4. **Destroy**: Infrastructure destruction (manual only)

### OCI Workflow (`oci-deploy.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual dispatch with environment selection

**Jobs:**
1. **Validate**: Terraform format check and validation
2. **Plan**: Infrastructure planning (PR only)
3. **Deploy**: Infrastructure deployment (main branch)
4. **Destroy**: Infrastructure destruction (manual only)

## Setup Steps

### 1. Repository Setup

1. **Push your code to GitHub:**
```bash
git init
git add .
git commit -m "Initial commit: VS Code Server deployment"
git branch -M main
git remote add origin https://github.com/yourusername/your-repo-name.git
git push -u origin main
```

### 2. Configure GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret from the tables above

### 3. Environment Protection Rules (Optional)

For production deployments, set up environment protection rules:

1. Go to **Settings** → **Environments**
2. Create environments: `production`, `staging`, `development`
3. Add protection rules:
   - Required reviewers
   - Wait timer
   - Deployment branches

### 4. Test the Workflows

1. **Create a test branch:**
```bash
git checkout -b test-workflow
git push origin test-workflow
```

2. **Create a pull request** to trigger the validation and plan jobs

3. **Manual deployment:**
   - Go to **Actions** tab
   - Select the workflow
   - Click **Run workflow**
   - Choose environment and run

## Workflow Behavior

### Automatic Triggers

- **Push to main**: Deploys to production
- **Push to develop**: Deploys to staging
- **Pull Request**: Runs validation and plan only

### Manual Triggers

- **Workflow Dispatch**: Manual deployment with environment selection
- **Destroy**: Manual infrastructure destruction

## Security Best Practices

1. **Use Environment Secrets**: Store sensitive data in GitHub Secrets
2. **Limit Permissions**: Use least-privilege service accounts
3. **Review Changes**: Require PR reviews for production
4. **Monitor Deployments**: Set up notifications for deployment status

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify secrets are correctly set
2. **Permission Errors**: Check service account permissions
3. **Backend Errors**: Ensure GCS bucket exists and is accessible
4. **Resource Conflicts**: Check for existing resources with same names

### Debug Steps

1. Check workflow logs in GitHub Actions
2. Verify secrets are set correctly
3. Test locally with same credentials
4. Check cloud provider console for errors

## Monitoring and Notifications

### Set up Notifications

1. Go to **Settings** → **Notifications**
2. Configure workflow notifications
3. Set up email/Slack notifications for deployment status

### Monitoring Deployments

- Check **Actions** tab for workflow status
- Monitor cloud provider dashboards
- Set up monitoring for deployed resources

## Advanced Configuration

### Custom Environments

To add more environments, modify the workflow files:

```yaml
options:
  - production
  - staging
  - development
  - testing  # Add new environment
```

### Branch Protection

Set up branch protection rules:

1. Go to **Settings** → **Branches**
2. Add rule for `main` branch
3. Require status checks
4. Require pull request reviews

### Workflow Permissions

Configure workflow permissions in repository settings:

1. Go to **Settings** → **Actions** → **General**
2. Configure workflow permissions
3. Set up OIDC for cloud providers (recommended)

## Next Steps

1. **Test the workflows** with a test branch
2. **Set up monitoring** for deployed resources
3. **Configure notifications** for deployment status
4. **Set up branch protection** for production deployments
5. **Document your deployment process** for your team

## Support

For issues with the workflows:
1. Check GitHub Actions logs
2. Verify all secrets are configured
3. Test Terraform locally
4. Check cloud provider permissions
