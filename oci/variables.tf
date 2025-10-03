# =============================================================================
# CONSOLIDATED VARIABLES - VS CODE REMOTE DEVELOPMENT
# =============================================================================
# Single consolidated variables file for all configurations
# Combines original variables with enhanced remote development features
# =============================================================================

# =============================================================================
# 1. OCI AUTHENTICATION & BASIC CONFIGURATION
# =============================================================================

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of your OCI tenancy"
  sensitive   = true

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "Tenancy OCID must start with 'ocid1.tenancy.'"
  }
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the OCI user"
  sensitive   = true

  validation {
    condition     = can(regex("^ocid1\\.user\\.", var.user_ocid))
    error_message = "User OCID must start with 'ocid1.user.'"
  }
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of your OCI API key"
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-f]{2}(:[0-9a-f]{2}){15}$", var.fingerprint))
    error_message = "Fingerprint must be in the format: xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
  }
}

variable "private_key_path" {
  type        = string
  description = "Path to your private key file"
  sensitive   = true

  validation {
    condition     = fileexists(var.private_key_path)
    error_message = "The specified private key file does not exist."
  }
}

variable "private_key_password" {
  type        = string
  description = "Password for the private key file (if encrypted)"
  sensitive   = true
  default     = ""
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where resources will be created"

  validation {
    condition     = can(regex("^ocid1\\.(compartment|tenancy)\\.", var.compartment_id))
    error_message = "Compartment OCID must start with 'ocid1.compartment.' or 'ocid1.tenancy.'"
  }
}

variable "region" {
  type        = string
  description = "The OCI region where resources will be created"
  default     = "uk-london-1"

  validation {
    condition = contains([
      "uk-london-1", "us-phoenix-1", "us-ashburn-1", "eu-frankfurt-1",
      "ap-tokyo-1", "ap-mumbai-1", "ap-sydney-1", "ca-toronto-1"
    ], var.region)
    error_message = "Region must be a valid OCI region."
  }
}

# =============================================================================
# 2. NETWORK CONFIGURATION
# =============================================================================

variable "vcn_cidr_block" {
  type        = string
  description = "CIDR block for the VCN"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr_block))
    error_message = "VCN CIDR block must be a valid CIDR notation."
  }
}

variable "subnet_cidr_block" {
  type        = string
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "Subnet CIDR block must be a valid CIDR notation."
  }
}

variable "ssh_port" {
  type        = number
  description = "SSH port number (default 22, consider changing for security)"
  default     = 22
  
  validation {
    condition     = var.ssh_port >= 22 && var.ssh_port <= 65535
    error_message = "SSH port must be between 22 and 65535."
  }
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR block allowed for SSH access"
  default     = "0.0.0.0/0"
}

variable "allowed_dev_access_cidr" {
  type        = string
  description = "CIDR block allowed for development server access"
  default     = "0.0.0.0/0"
}

variable "dev_server_ports" {
  type        = list(number)
  description = "List of ports to open for development servers"
  default     = [3000, 8000, 8080, 9000]
}

variable "use_reserved_ip" {
  type        = bool
  description = "Whether to use a reserved public IP for static access"
  default     = true
}

# =============================================================================
# 3. COMPUTE CONFIGURATION
# =============================================================================

variable "instance_shape" {
  type        = string
  description = "The shape of the compute instance"
  default     = "VM.Standard.A1.Flex"

  validation {
    condition = contains([
      "VM.Standard.E2.1.Micro", "VM.Standard.A1.Flex"
    ], var.instance_shape)
    error_message = "Instance shape must be compatible with Always Free tier."
  }
}

variable "instance_ocpus" {
  type        = number
  description = "Number of OCPUs for Flex shape instances"
  default     = 2
  
  validation {
    condition     = var.instance_ocpus >= 1 && var.instance_ocpus <= 4
    error_message = "OCPUs must be between 1 and 4 for Always Free tier."
  }
}

variable "instance_memory_in_gbs" {
  type        = number
  description = "Memory in GBs for Flex shape instances"
  default     = 8
  
  validation {
    condition     = var.instance_memory_in_gbs >= 1 && var.instance_memory_in_gbs <= 24
    error_message = "Memory must be between 1 and 24 GB for Always Free tier."
  }
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Size of the boot volume in GBs"
  default     = 100

  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 200
    error_message = "Boot volume size must be between 50 and 200 GB."
  }
}

variable "workspace_volume_size_in_gbs" {
  type        = number
  description = "Size of the persistent workspace volume in GBs"
  default     = 50
  
  validation {
    condition     = var.workspace_volume_size_in_gbs >= 10 && var.workspace_volume_size_in_gbs <= 200
    error_message = "Workspace volume size must be between 10 and 200 GB."
  }
}

variable "os_type" {
  type        = string
  description = "Operating system type"
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "oracle_linux"], var.os_type)
    error_message = "OS type must be either 'ubuntu' or 'oracle_linux'."
  }
}

# =============================================================================
# 4. DEVELOPMENT TOOLS CONFIGURATION
# =============================================================================

variable "nodejs_version" {
  type        = string
  description = "Node.js version to install"
  default     = "20"
  
  validation {
    condition     = contains(["18", "20", "21"], var.nodejs_version)
    error_message = "Node.js version must be one of: 18, 20, 21."
  }
}

variable "python_version" {
  type        = string
  description = "Python version to install"
  default     = "3.12"
  
  validation {
    condition     = contains(["3.10", "3.11", "3.12"], var.python_version)
    error_message = "Python version must be one of: 3.10, 3.11, 3.12."
  }
}

variable "go_version" {
  type        = string
  description = "Go version to install"
  default     = "1.21.5"
}

variable "java_version" {
  type        = string
  description = "Java JDK version to install"
  default     = "17"
  
  validation {
    condition     = contains(["11", "17", "21"], var.java_version)
    error_message = "Java version must be one of: 11, 17, 21."
  }
}

# =============================================================================
# 5. USER & SECURITY CONFIGURATION
# =============================================================================

variable "dev_username" {
  type        = string
  description = "Development user username"
  default     = "developer"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]*$", var.dev_username))
    error_message = "Username must start with a lowercase letter and contain only lowercase letters, numbers, underscores, and hyphens."
  }
}

variable "git_username" {
  type        = string
  description = "Git global username"
  default     = "Developer"
}

variable "git_email" {
  type        = string
  description = "Git global email"
  default     = "dev@example.com"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key file"
  default     = "~/.ssh/id_rsa.pub"
}

variable "disable_password_auth" {
  type        = bool
  description = "Disable SSH password authentication (keys only)"
  default     = true
}

variable "enable_firewall" {
  type        = bool
  description = "Enable UFW firewall configuration"
  default     = true
}

# =============================================================================
# 6. VS CODE & DEVELOPMENT FEATURES
# =============================================================================

variable "vscode_password" {
  type        = string
  description = "Password for VS Code Server web interface"
  default     = "SecureRemoteDev2025!"
  sensitive   = true

  validation {
    condition     = length(var.vscode_password) >= 12
    error_message = "VS Code password must be at least 12 characters long."
  }
}

variable "vscode_web_port" {
  type        = number
  description = "Port for VS Code Server web interface"
  default     = 8080
  
  validation {
    condition     = var.vscode_web_port >= 1024 && var.vscode_web_port <= 65535
    error_message = "VS Code web port must be between 1024 and 65535."
  }
}

variable "enable_vscode_web" {
  type        = bool
  description = "Enable VS Code Server web interface (in addition to SSH remote)"
  default     = false
}

variable "install_docker" {
  type        = bool
  description = "Install Docker and Docker Compose"
  default     = true
}

variable "install_code_server" {
  type        = bool
  description = "Install VS Code Server for web access"
  default     = true
}

variable "setup_zsh" {
  type        = bool
  description = "Setup Zsh with Oh My Zsh for development user"
  default     = true
}

variable "install_cloud_tools" {
  type        = bool
  description = "Install cloud CLI tools (AWS, Azure, kubectl, etc.)"
  default     = true
}

# =============================================================================
# 7. BACKUP & MONITORING
# =============================================================================

variable "enable_workspace_backup" {
  type        = bool
  description = "Enable automatic backup of workspace volume"
  default     = true
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain workspace backups"
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 30
    error_message = "Backup retention must be between 1 and 30 days."
  }
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable OCI monitoring for the instance"
  default     = true
}

# =============================================================================
# 8. PROJECT & TAGGING
# =============================================================================

variable "project_name" {
  type        = string
  description = "Name of the project (used in resource naming and tagging)"
  default     = "vscode-remote-dev"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens, and cannot start or end with a hyphen."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "development"

  validation {
    condition = contains([
      "development", "dev", "staging", "stage", "production", "prod"
    ], var.environment)
    error_message = "Environment must be one of: development, dev, staging, stage, production, prod."
  }
}

variable "freeform_tags" {
  type        = map(string)
  description = "Free-form tags to apply to resources"
  default = {
    "Purpose"    = "Remote Development Environment"
    "Tools"      = "VS Code, Docker, Multiple Languages"
    "Access"     = "SSH Remote Development"
    "Storage"    = "Persistent Workspace"
  }
}

variable "defined_tags" {
  type        = map(string)
  description = "Defined tags to apply to resources"
  default     = {}
}

# =============================================================================
# 9. LEGACY COMPATIBILITY (DEPRECATED - USE CONSOLIDATED VERSIONS ABOVE)
# =============================================================================

# These variables maintain compatibility with existing configurations
# They are mapped to the consolidated variables above

variable "availability_domain_number" {
  type        = number
  description = "[DEPRECATED] Use automatic availability domain selection instead"
  default     = 1
}

variable "allowed_https_cidr" {
  type        = string
  description = "[DEPRECATED] Use allowed_dev_access_cidr instead"
  default     = "0.0.0.0/0"
}