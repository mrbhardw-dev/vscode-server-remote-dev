# 🚀 VS Code Server - Multi-Cloud Deployment

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://www.oracle.com/cloud/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Production-ready Terraform configurations for deploying VS Code Server on multiple cloud providers. Choose your cloud, deploy in minutes, and start coding from anywhere!

## 🌟 Overview

This repository contains elegant, well-documented Terraform configurations for deploying VS Code Server (code-server) on:

- **Google Cloud Platform (GCP)** - Enterprise-grade deployment with advanced features
- **Oracle Cloud Infrastructure (OCI)** - **Always Free Tier** deployment ($0/month forever!)

## 🎯 Quick Links

| Cloud Provider | Documentation | Quick Start | Cost |
|----------------|---------------|-------------|------|
| **Oracle Cloud (OCI)** | [📖 README](oci/README.md) | [⚡ Quick Start](oci/QUICKSTART.md) | **$0/month** (Always Free) |
| **Google Cloud (GCP)** | [📖 README](gcp/README.md) | [⚡ Quick Start](gcp/QUICKSTART.md) | ~$8-30/month |

## 💰 Cost Comparison

### Oracle Cloud Infrastructure (OCI) - **Recommended for Free Tier**

| Resource | Specification | Cost |
|----------|--------------|------|
| Compute | ARM Ampere A1 (2 OCPUs, 12 GB RAM) | **$0** |
| Storage | 100 GB SSD | **$0** |
| Network | 10 TB/month egress | **$0** |
| **Total** | | **$0/month forever** |

**✨ Always Free - No time limit, no credit card required!**

### Google Cloud Platform (GCP)

| Resource | Specification | Cost |
|----------|--------------|------|
| Compute | e2-micro (1 vCPU, 1 GB RAM) | ~$8/month |
| Compute | e2-medium (2 vCPU, 4 GB RAM) | ~$25/month |
| Storage | 30-50 GB SSD | ~$1-2/month |
| Network | ~100 GB/month | ~$1/month |
| **Total** | | **$8-30/month** |

**💡 GCP offers $300 free credit for 90 days**

## 🚀 Quick Start

### Option 1: Oracle Cloud (Free Forever)

```bash
# Clone repository
git clone https://github.com/your-org/vscode-server-cloud.git
cd vscode-server-cloud/oci

# Configure
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your OCI credentials

# Deploy
terraform init
terraform apply

# Access
# Open browser to: http://YOUR_PUBLIC_IP:8080
```

**Time to deploy**: ~5 minutes  
**Cost**: $0/month forever

### Option 2: Google Cloud Platform

```bash
# Clone repository
git clone https://github.com/your-org/vscode-server-cloud.git
cd vscode-server-cloud/gcp

# Configure
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your GCP credentials

# Deploy
terraform init
terraform apply

# Access
# Open browser to: https://your-domain.com
```

**Time to deploy**: ~5 minutes  
**Cost**: ~$8-30/month

## 📊 Feature Comparison

| Feature | OCI | GCP |
|---------|-----|-----|
| **Cost** | ✅ Free Forever | ⚠️ Paid (~$8-30/month) |
| **Performance** | ✅ ARM Ampere A1 | ✅ Intel/AMD |
| **RAM** | ✅ Up to 24 GB (Free) | ⚠️ 1-4 GB |
| **Storage** | ✅ 200 GB (Free) | ⚠️ 30-50 GB |
| **Setup Time** | ✅ 5 minutes | ✅ 5 minutes |
| **HTTPS** | ✅ Self-signed | ✅ Let's Encrypt |
| **Monitoring** | ✅ OCI Monitoring | ✅ Cloud Monitoring |
| **Auto-scaling** | ❌ Manual | ✅ Supported |
| **Load Balancer** | ⚠️ Paid | ✅ Supported |
| **Global Regions** | ✅ 40+ regions | ✅ 35+ regions |

## 🏗 Architecture

### Oracle Cloud Infrastructure (OCI)
```
┌─────────────────────────────────────┐
│         OCI Tenancy                 │
│  ┌───────────────────────────────┐  │
│  │    Virtual Cloud Network      │  │
│  │      (10.0.0.0/16)            │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │  Public Subnet          │  │  │
│  │  │  ┌──────────────────┐   │  │  │
│  │  │  │  Compute VM      │   │  │  │
│  │  │  │  ARM A1 Flex     │   │  │  │
│  │  │  │  2 OCPUs, 12GB   │   │  │  │
│  │  │  │  VS Code :8080   │   │  │  │
│  │  │  └──────────────────┘   │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Google Cloud Platform (GCP)
```
┌─────────────────────────────────────┐
│         GCP Project                 │
│  ┌───────────────────────────────┐  │
│  │    VPC Network                │  │
│  │      (10.0.0.0/16)            │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │  Subnet 1               │  │  │
│  │  │  ┌──────────────────┐   │  │  │
│  │  │  │  Compute VM      │   │  │  │
│  │  │  │  e2-micro/medium │   │  │  │
│  │  │  │  VS Code :8080   │   │  │  │
│  │  │  │  Let's Encrypt   │   │  │  │
│  │  │  └──────────────────┘   │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## 📚 Documentation

### Oracle Cloud Infrastructure (OCI)
- [📖 Full Documentation](oci/README.md)
- [⚡ Quick Start Guide](oci/QUICKSTART.md)
- [📝 Configuration Examples](oci/terraform.tfvars.example)
- [🔧 Troubleshooting](oci/README.md#-troubleshooting)

### Google Cloud Platform (GCP)
- [📖 Full Documentation](gcp/README.md)
- [⚡ Quick Start Guide](gcp/QUICKSTART.md)
- [📝 Configuration Examples](gcp/terraform.tfvars.example)
- [🔧 Troubleshooting](gcp/README.md#troubleshooting)
- [📊 Improvements Log](gcp/IMPROVEMENTS.md)
- [🤝 Contributing Guide](gcp/CONTRIBUTING.md)

## 🎯 Use Cases

### Perfect for OCI (Free Tier)
- ✅ Personal development environment
- ✅ Learning and experimentation
- ✅ Side projects and hobbies
- ✅ Open source contributions
- ✅ Student projects
- ✅ Portfolio development

### Perfect for GCP (Production)
- ✅ Team development environments
- ✅ Production workloads
- ✅ Enterprise deployments
- ✅ High-availability setups
- ✅ Auto-scaling requirements
- ✅ Advanced monitoring needs

## 🔒 Security

Both deployments include:
- ✅ VPC/VCN isolation
- ✅ Security groups/lists
- ✅ SSH key authentication
- ✅ Firewall rules
- ✅ HTTPS support
- ✅ Password protection

### Security Best Practices
1. **Restrict SSH access** to your IP address
2. **Use strong passwords** (minimum 12 characters)
3. **Enable HTTPS** for encrypted connections
4. **Regular updates** of system packages
5. **Monitor access logs** regularly

## 🛠 Prerequisites

### Common Requirements
- Terraform >= 1.3.0
- SSH client
- Git (optional)

### OCI-Specific
- OCI account (free tier)
- API key pair
- Tenancy, User, and Compartment OCIDs

### GCP-Specific
- GCP account with billing enabled
- Service account key (JSON)
- Project ID

## 📦 What's Included

### Infrastructure as Code
- ✅ Complete Terraform configurations
- ✅ Modular and reusable code
- ✅ Comprehensive variable validation
- ✅ Detailed outputs
- ✅ Example configurations

### Documentation
- ✅ Comprehensive README files
- ✅ Quick start guides
- ✅ Architecture diagrams
- ✅ Troubleshooting guides
- ✅ Best practices

### Automation
- ✅ Cloud-init scripts
- ✅ Automated VS Code Server installation
- ✅ Service configuration
- ✅ Firewall setup
- ✅ HTTPS configuration

## 🚀 Getting Started

### 1. Choose Your Cloud Provider

**Want it free?** → Choose **Oracle Cloud (OCI)**  
**Need enterprise features?** → Choose **Google Cloud (GCP)**

### 2. Follow the Quick Start

- [OCI Quick Start](oci/QUICKSTART.md) - 5 minutes to free VS Code Server
- [GCP Quick Start](gcp/QUICKSTART.md) - 5 minutes to production-ready deployment

### 3. Customize

Both deployments are highly customizable:
- Instance size and type
- Storage capacity
- Network configuration
- Security settings
- Monitoring options

## 💡 Tips & Tricks

### For OCI Users
1. **Use ARM instances** (VM.Standard.A1.Flex) for best free tier value
2. **Max out resources**: 4 OCPUs, 24 GB RAM, 200 GB storage - all free!
3. **Enable monitoring** - it's free and helpful
4. **Use OCI Bastion** for secure SSH access

### For GCP Users
1. **Start with e2-micro** to minimize costs
2. **Use preemptible instances** for development (60-90% cheaper)
3. **Enable Cloud Monitoring** for insights
4. **Set up budget alerts** to avoid surprises
5. **Use sustained use discounts** for long-running instances

## 🔄 Migration

Want to move from one cloud to another? Both configurations use similar structure:

```bash
# Export your VS Code settings
# On current instance
tar -czf ~/vscode-backup.tar.gz ~/.local/share/code-server

# Download backup
scp user@old-ip:~/vscode-backup.tar.gz .

# Upload to new instance
scp vscode-backup.tar.gz user@new-ip:~/

# Restore on new instance
tar -xzf ~/vscode-backup.tar.gz -C ~/
```

## 🤝 Contributing

Contributions are welcome! Please see:
- [Contributing Guidelines](gcp/CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [VS Code Server (code-server)](https://github.com/coder/code-server)
- [Terraform](https://www.terraform.io/)
- [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
- [Google Cloud Platform](https://cloud.google.com/)

## 📞 Support

### Documentation
- [OCI Documentation](oci/README.md)
- [GCP Documentation](gcp/README.md)

### Community
- Open an [Issue](https://github.com/your-org/vscode-server-cloud/issues)
- Submit a [Pull Request](https://github.com/your-org/vscode-server-cloud/pulls)

### Official Resources
- [OCI Always Free Tier](https://www.oracle.com/cloud/free/)
- [GCP Free Tier](https://cloud.google.com/free)
- [VS Code Server Docs](https://coder.com/docs/code-server)

---

<div align="center">

## 🌟 Star this repo if you find it helpful!

**Choose your cloud and start coding in the cloud today!**

### Quick Decision Guide

**I want it FREE** → [Deploy on OCI](oci/QUICKSTART.md) 🎉  
**I need production features** → [Deploy on GCP](gcp/QUICKSTART.md) 🚀

---

Made with ❤️ for developers who code everywhere

</div>
