# VS Code Server Deployment on Cloud Platforms

This project provides Terraform configurations for deploying VS Code Server on both Google Cloud Platform (GCP) and Oracle Cloud Infrastructure (OCI).

## Project Structure

```
vscode-server-remote-dev/
├── gcp/                    # GCP deployment configuration
│   ├── compute.tf          # Compute instance configuration
│   ├── labels.tf           # Resource labeling module
│   ├── locals.tf           # Local values and configuration
│   ├── network.tf          # VPC network and firewall rules
│   ├── outputs.tf         # Output values
│   ├── provider.tf         # Terraform providers
│   ├── variables.tf        # Input variables
│   ├── terraform.tfvars    # Variable values (configured)
│   ├── terraform.tfvars.example  # Example variable file
│   ├── scripts/
│   │   └── install-vscode-server.sh  # VS Code Server installation script
│   └── secrets/
│       └── solid-choir-472607-r1-f68352350e87.json  # GCP service account key
├── oci/                    # OCI deployment configuration
│   ├── compute.tf          # Compute instance configuration
│   ├── locals.tf           # Local values and configuration
│   ├── network.tf          # VCN and security configuration
│   ├── outputs.tf          # Output values
│   ├── variables.tf        # Input variables
│   ├── versions.tf         # Terraform and provider versions
│   ├── terraform.tfvars    # Variable values (configured)
│   ├── terraform.tfvars.example  # Example variable file
│   └── scripts/
│       └── cloud-init.yaml  # Cloud-init configuration
└── README.md              # This file
```

## Deployment Instructions

### GCP Deployment

1. Navigate to the GCP directory:
```bash
cd gcp
```

2. Initialize Terraform with GCS backend:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="secrets/solid-choir-472607-r1-f68352350e87.json"
terraform init -backend-config=backend.hcl
```

3. Review the configuration:
```bash
./terraform.sh plan
```

4. Deploy the infrastructure:
```bash
./terraform.sh apply
```

**Note:** The GCP project is configured to use a GCS backend for state storage in bucket `mbtux-dev-tf-01` with prefix `vscode-server`. Use the `./terraform.sh` script for all Terraform operations to ensure proper authentication.

### OCI Deployment

1. Navigate to the OCI directory:
```bash
cd oci
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the configuration:
```bash
terraform plan
```

4. Deploy the infrastructure:
```bash
terraform apply
```

## Features

### GCP Configuration
- Uses Google Cloud Platform with Always Free tier resources
- Deploys VS Code Server with Let's Encrypt SSL certificate
- Includes VPC network with firewall rules
- Supports multiple instances with load balancing
- **GitHub Actions**: Automated deployment with CI/CD pipeline

### OCI Configuration
- Uses Oracle Cloud Infrastructure with Always Free tier resources
- Deploys VS Code Server with optional HTTPS
- Includes VCN with security lists and network security groups
- Optimized for Free Tier limits
- **GitHub Actions**: Automated deployment with CI/CD pipeline

### GitHub Actions Workflows
- **Automated Deployment**: Push to main/develop triggers deployment
- **Pull Request Validation**: Automatic Terraform validation and planning
- **Security Scanning**: Daily security scans with Trivy and TFSec
- **Dependency Updates**: Automated dependency updates with Dependabot
- **Manual Triggers**: Workflow dispatch for manual deployments

## Prerequisites

### GCP
- GCP project with billing enabled
- Service account with appropriate permissions
- Domain name for SSL certificate (optional)

### OCI
- OCI tenancy with Always Free tier access
- API key configured for authentication
- SSH key pair for instance access

## Configuration

Both projects are pre-configured with example values. Update the `terraform.tfvars` files with your specific values before deployment.

## GitHub Actions Setup

For automated deployment, see the [GitHub Setup Guide](GITHUB_SETUP.md) for detailed instructions.

### Quick Setup Steps:

1. **Push to GitHub Repository**
2. **Configure Secrets** (see GITHUB_SETUP.md for details)
3. **Set up Environments** (optional, for production protection)
4. **Test Workflows** with a pull request

### Available Workflows:

- **`gcp-deploy.yml`**: GCP deployment automation
- **`oci-deploy.yml`**: OCI deployment automation  
- **`security-scan.yml`**: Security and code quality scanning
- **`dependabot.yml`**: Automated dependency updates

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Support

Both configurations are optimized for production use and include comprehensive documentation and error handling.