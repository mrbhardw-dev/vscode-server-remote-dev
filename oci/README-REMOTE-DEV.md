# 🚀 VS Code Remote Development Environment on Oracle Cloud

**Professional remote development environment optimized for VS Code Remote Development extension**

## ✨ What's New in This Refactored Version

This configuration has been completely refactored to provide a world-class remote development experience:

### 🎯 **Remote Development Focus**
- **SSH-based VS Code Remote Development** (primary method)
- **ARM-based instance** for better price/performance (2 OCPU, 8GB RAM)
- **Persistent workspace storage** (50GB) that survives instance recreation
- **Enhanced development tools** with modern versions

### 🛠️ **Pre-installed Development Stack**
- **🐳 Docker & Docker Compose** - Full containerization support
- **📦 Node.js 20** with npm, yarn, pnpm
- **🐍 Python 3.12** with pyenv, pip, pipenv, poetry
- **⚡ Go 1.21.5** - Latest stable Go compiler
- **🦀 Rust** - Complete Rust toolchain  
- **☕ Java 17** - OpenJDK LTS
- **🔧 Enhanced Git** - Pre-configured with aliases
- **🐚 Zsh + Oh My Zsh** - Modern shell with plugins

### 🔒 **Security & Network Enhancements**
- **SSH key-only authentication** (password auth disabled)
- **Network Security Groups** with development-specific rules
- **Firewall configuration** with common dev ports open
- **Reserved public IP** option for consistent SSH access

### 💾 **Workspace & Backup**
- **Persistent `/workspace` directory** on separate volume
- **Daily automated backups** with configurable retention
- **Volume survives instance termination/recreation**

## 🚀 Quick Start

### 1. Deploy the Environment
```bash
# Navigate to the Terraform directory
cd oci/

# Run the deployment script
./deploy-remote-dev.sh
```

### 2. Connect with VS Code
1. **Install Extension**: Install "Remote - SSH" extension in VS Code
2. **Add SSH Host**: 
   - Host: `developer@YOUR_PUBLIC_IP`
   - Port: `22` (or custom port if configured)
3. **Connect**: Click "Connect to Host in Current Window"
4. **Open Workspace**: Open folder `/workspace`

### 3. Start Developing
Your complete development environment is ready with all tools pre-installed!

## 📁 File Structure

### Enhanced Configuration Files
```
oci/
├── 🆕 terraform-remote-dev.tfvars    # Enhanced configuration
├── 🆕 variables-remote-dev.tf        # New variables for remote dev
├── 🆕 locals-remote-dev.tf          # Enhanced locals
├── 🆕 compute-remote-dev.tf          # ARM instance + storage
├── 🆕 outputs-remote-dev.tf          # Comprehensive outputs
├── 🆕 scripts/cloud-init-remote-dev.yaml  # Enhanced setup script
├── 🆕 deploy-remote-dev.sh           # Automated deployment
└── 🆕 README-REMOTE-DEV.md           # This documentation
```

### Original Files (Backup)
```
oci/
├── terraform.tfvars                  # Original configuration
├── variables.tf                      # Original variables
├── locals.tf                        # Original locals
├── compute.tf                       # Original compute config
├── outputs.tf                       # Original outputs
└── scripts/cloud-init.yaml         # Original cloud-init
```

## 🎛️ Configuration Options

### Instance Configuration
```hcl
# ARM-based for better price/performance
instance_shape = "VM.Standard.A1.Flex"
instance_ocpus = 2                    # 1-4 (Always Free)
instance_memory_in_gbs = 8            # 1-24 (Always Free)

# Storage
boot_volume_size_in_gbs = 100         # System storage  
workspace_volume_size_in_gbs = 50     # Persistent workspace
```

### Development Tools
```hcl
nodejs_version = "20"                 # Node.js LTS
python_version = "3.12"               # Latest Python
go_version = "1.21.5"                # Go stable
java_version = "17"                   # Java LTS

install_docker = true                 # Docker + Compose
setup_zsh = true                      # Zsh + Oh My Zsh
install_cloud_tools = true            # kubectl, terraform, etc.
```

### Security & Network
```hcl
ssh_port = 22                         # SSH port
use_reserved_ip = true                # Static IP
dev_server_ports = [3000, 8000, 8080, 9000]  # Dev ports
enable_workspace_backup = true        # Daily backups
```

## 💻 Development Workflows

### Web Development (React/Next.js)
```bash
cd /workspace
npx create-react-app my-app
cd my-app
npm start  # Accessible on port 3000
```

### Python Development
```bash
cd /workspace
poetry new my-python-app
cd my-python-app
poetry install
poetry run python main.py
```

### Containerized Development
```bash
cd /workspace
# Create your Dockerfile and docker-compose.yml
docker-compose up -d
```

### Go Development
```bash
cd /workspace
go mod init my-go-app
# Write your Go code
go run main.go
```

## 🔧 Management Commands

### Check Setup Status
```bash
# SSH into instance
ssh developer@YOUR_PUBLIC_IP

# Check cloud-init status
sudo cloud-init status

# View setup logs
sudo tail -f /var/log/remote-dev-setup.log

# Check services
sudo systemctl status docker
docker --version
node --version
```

### Workspace Backup
```bash
# Manual backup
sudo /usr/local/bin/backup-workspace.sh

# View backups
ls -la /workspace/.backups/
```

### Development Ports
The following ports are open for development:
- **22**: SSH access
- **80/443**: HTTP/HTTPS for web development
- **3000**: Common dev server (React, etc.)
- **8000**: Python/Django dev server
- **8080**: Alternative dev server
- **9000**: Additional dev server

## 💰 Cost Information

**Always Free Tier Usage:**
- ✅ **2 OCPU ARM** (4 total available)
- ✅ **8 GB RAM** (24 GB total available)
- ✅ **150 GB storage** (200 GB total available)
- ✅ **Network resources** (VCN, Subnet, IGW - all free)
- ✅ **Reserved IP** (free)

**Estimated Cost: $0/month** (within Always Free limits)

## 🆚 Comparison: Original vs Enhanced

| Feature | Original | Enhanced |
|---------|----------|----------|
| **Primary Access** | VS Code Server (web) | SSH Remote Development |
| **Instance Type** | Basic micro instance | ARM Flex (2 OCPU, 8GB) |
| **Storage** | Boot volume only | Persistent workspace volume |
| **Development Tools** | Basic | Complete modern stack |
| **Backup** | None | Daily automated backups |
| **Security** | Basic | Enhanced with NSG |
| **User Experience** | Web-based coding | Full VS Code with extensions |
| **Performance** | Limited | High-performance ARM |

## 🚨 Migration from Original

To migrate from the original configuration:

1. **Backup existing work** (if any)
2. **Destroy original infrastructure** (if desired)
3. **Deploy enhanced version** using `./deploy-remote-dev.sh`
4. **Restore work** to `/workspace` directory

## 🎯 VS Code Remote Development Benefits

### Why SSH Remote Development?
- **Full VS Code experience** with all extensions
- **Better performance** than web-based coding
- **Local VS Code UI** with remote execution
- **Integrated terminal** and debugging
- **Source control integration**
- **Extension marketplace access**

### Setup in VS Code
1. Install "Remote - SSH" extension
2. Command Palette → "Remote-SSH: Add New SSH Host"
3. Enter: `ssh developer@YOUR_PUBLIC_IP`
4. Connect and enjoy full remote development!

## 🛠️ Troubleshooting

### Common Issues

**Can't connect via SSH:**
```bash
# Check security group rules in OCI console
# Verify SSH key is correct
# Check if cloud-init completed: sudo cloud-init status
```

**VS Code Remote connection fails:**
```bash
# Ensure Remote-SSH extension is installed
# Check SSH key is added to your SSH agent
# Verify connection works with terminal SSH first
```

**Development server not accessible:**
```bash
# Check if port is in dev_server_ports list
# Verify service is binding to 0.0.0.0 not localhost
# Check NSG rules allow the port
```

## 📚 Additional Resources

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/ssh)
- [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/)
- [Docker Documentation](https://docs.docker.com/)
- [Modern Development Tools](https://github.com/topics/developer-tools)

---

## 🤝 Contributing

This configuration is designed to be:
- **Modular** - Easy to customize
- **Extensible** - Add your own tools
- **Documented** - Clear and well-commented
- **Production-ready** - Secure and performant

Feel free to customize the configuration for your specific development needs!

---

**🎉 Happy Remote Coding!** 🚀