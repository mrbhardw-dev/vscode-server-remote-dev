# 🚀 VS Code Server Remote Dev Infrastructure

This project provides comprehensive Terraform configurations for deploying and managing VS Code Server infrastructure on Google Cloud Platform, including CI/CD pipelines and automated deployments.

## 🏗 Infrastructure Components

| Component | Description | Purpose |
| :--- | :--- | :--- |
| **[Bootstrap](./infra/bootstrap/)** | CI/CD Foundation | Sets up Cloud Build, GitHub integration, and state management |
| **[Workload](./infra/workload/)** | VS Code Server Deployment | Deploys the actual VS Code Server instances and networking |
| **[OCI](./oci/)** | Alternative Cloud Deployment | Oracle Cloud Infrastructure deployment option |

## 🚀 Getting Started

### Bootstrap Infrastructure (Required First)

The bootstrap infrastructure must be deployed first as it creates the CI/CD pipeline and state storage:

1. **Deploy Bootstrap:**
   ```bash
   cd infra/bootstrap
   terraform init
   terraform apply
   ```

2. **Verify Bootstrap:**
   - Cloud Build connection to GitHub
   - GCS bucket for Terraform state
   - Build triggers configured

### Workload Deployment

Once bootstrap is complete, deploy the VS Code Server:

1. **Deploy Workload:**
   ```bash
   cd infra/workload
   terraform init
   terraform apply
   ```

2. **Access VS Code Server:**
   - Web interface via configured domain
   - SSH access through IAP

### Alternative: OCI Deployment

For Oracle Cloud deployment:

1. **Navigate to OCI:**
   ```bash
   cd oci
   ```

2. **Follow OCI instructions:**
   - OCI README.md

## 📁 Project Structure

```plaintext
.
├── infra/
│   ├── bootstrap/
│   │   ├── README.md
│   │   ├── backend.tf
│   │   ├── bootstrap.tf
│   │   ├── codebuild.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── workload/
│       ├── README.md
│       ├── backend.tf
│       ├── cloudbuild.yaml
│       ├── compute.tf
│       ├── locals.tf
│       ├── network.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── scripts/
│           └── install-vscode-server.sh
├── oci/
│   ├── README.md
│   ├── compute.tf
│   ├── locals.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   └── scripts/
│       └── cloud-init.yaml
├── README.md
└── .gitignore
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any bugs, improvements, or new features.

1.  Fork the repository.
2.  Create a new feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add some amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.