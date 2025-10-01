# =============================================================================
# INPUT VARIABLES - ORACLE CLOUD INFRASTRUCTURE
# =============================================================================
# This file defines all input variables for deploying VS Code Server on OCI.
# Optimized for OCI Always Free Tier resources.
#
# Variable Organization:
# 1. OCI Authentication
# 2. Region & Compartment
# 3. Network Configuration
# 4. Compute Instance Settings (Free Tier)
# 5. Security & Access
# 6. Application Configuration
# 7. Tags & Labels
# =============================================================================

# =============================================================================
# 1. OCI AUTHENTICATION
# =============================================================================

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of your tenancy"

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "Tenancy OCID must start with 'ocid1.tenancy.'"
  }
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user calling the API"

  validation {
    condition     = can(regex("^ocid1\\.user\\.", var.user_ocid))
    error_message = "User OCID must start with 'ocid1.user.'"
  }
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint for the key pair being used"
  sensitive   = true

  validation {
    condition     = can(regex("^[a-f0-9]{2}(:[a-f0-9]{2}){15}$", var.fingerprint))
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

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where resources will be created"

  validation {
    condition     = can(regex("^ocid1\\.(compartment|tenancy)\\.", var.compartment_id))
    error_message = "Compartment OCID must start with 'ocid1.compartment.' or 'ocid1.tenancy.'"
  }
}

# =============================================================================
# 2. REGION & AVAILABILITY DOMAIN
# =============================================================================

variable "region" {
  type        = string
  default     = "us-phoenix-1"
  description = "OCI region (e.g., us-phoenix-1, us-ashburn-1, eu-frankfurt-1)"

  validation {
    condition = contains([
      "us-phoenix-1", "us-ashburn-1", "eu-frankfurt-1", "uk-london-1",
      "ap-tokyo-1", "ap-seoul-1", "ap-mumbai-1", "ap-sydney-1",
      "ca-toronto-1", "sa-saopaulo-1", "eu-amsterdam-1", "me-jeddah-1"
    ], var.region)
    error_message = "Must be a valid OCI region."
  }
}

variable "availability_domain_number" {
  type        = number
  default     = 1
  description = "Availability domain number (1, 2, or 3)"

  validation {
    condition     = var.availability_domain_number >= 1 && var.availability_domain_number <= 3
    error_message = "Availability domain number must be 1, 2, or 3."
  }
}

# =============================================================================
# 3. NETWORK CONFIGURATION
# =============================================================================

variable "vcn_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the Virtual Cloud Network (VCN)"

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr_block))
    error_message = "Must be a valid CIDR notation."
  }
}

variable "subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the subnet"

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "Must be a valid CIDR notation."
  }
}

# =============================================================================
# 4. COMPUTE INSTANCE SETTINGS (FREE TIER OPTIMIZED)
# =============================================================================

variable "instance_shape" {
  type        = string
  default     = "VM.Standard.E2.1.Micro"
  description = "Instance shape (Free Tier: VM.Standard.E2.1.Micro or VM.Standard.A1.Flex)"

  validation {
    condition = contains([
      "VM.Standard.E2.1.Micro",  # AMD - Always Free (1 OCPU, 1GB RAM)
      "VM.Standard.A1.Flex"       # ARM - Always Free (up to 4 OCPUs, 24GB RAM)
    ], var.instance_shape)
    error_message = "For Free Tier, use VM.Standard.E2.1.Micro (AMD) or VM.Standard.A1.Flex (ARM)."
  }
}

variable "instance_ocpus" {
  type        = number
  default     = 1
  description = "Number of OCPUs (only for Flex shapes, max 4 for Free Tier ARM)"

  validation {
    condition     = var.instance_ocpus >= 1 && var.instance_ocpus <= 4
    error_message = "For Free Tier ARM, OCPUs must be between 1 and 4."
  }
}

variable "instance_memory_in_gbs" {
  type        = number
  default     = 6
  description = "Amount of memory in GBs (only for Flex shapes, max 24 for Free Tier ARM)"

  validation {
    condition     = var.instance_memory_in_gbs >= 1 && var.instance_memory_in_gbs <= 24
    error_message = "For Free Tier ARM, memory must be between 1 and 24 GB."
  }
}

variable "boot_volume_size_in_gbs" {
  type        = number
  default     = 50
  description = "Size of the boot volume in GBs (Free Tier: up to 200 GB total)"

  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 200
    error_message = "Boot volume size must be between 50 and 200 GB."
  }
}

variable "os_type" {
  type        = string
  default     = "ubuntu"
  description = "Operating system type (oracle-linux or ubuntu)"

  validation {
    condition     = contains(["oracle-linux", "ubuntu"], var.os_type)
    error_message = "OS type must be either 'oracle-linux' or 'ubuntu'."
  }
}

# =============================================================================
# 5. SECURITY & ACCESS
# =============================================================================

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to SSH public key for instance access"
}

variable "allowed_ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR block allowed for SSH access (restrict to your IP in production)"

  validation {
    condition     = can(cidrnetmask(var.allowed_ssh_cidr))
    error_message = "Must be a valid CIDR notation."
  }
}

variable "allowed_https_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR block allowed for HTTPS access"

  validation {
    condition     = can(cidrnetmask(var.allowed_https_cidr))
    error_message = "Must be a valid CIDR notation."
  }
}

# =============================================================================
# 6. APPLICATION CONFIGURATION
# =============================================================================

variable "vscode_password" {
  type        = string
  description = "Password for VS Code Server"
  sensitive   = true

  validation {
    condition     = length(var.vscode_password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}

variable "vscode_port" {
  type        = number
  default     = 8080
  description = "Port for VS Code Server"

  validation {
    condition     = var.vscode_port >= 1024 && var.vscode_port <= 65535
    error_message = "Port must be between 1024 and 65535."
  }
}

variable "enable_https" {
  type        = bool
  default     = true
  description = "Enable HTTPS with self-signed certificate"
}

# =============================================================================
# 7. TAGS & LABELS
# =============================================================================

variable "environment" {
  type        = string
  default     = "production"
  description = "Environment name (development, staging, production)"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "project_name" {
  type        = string
  default     = "vscode-server"
  description = "Project name for resource tagging"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "freeform_tags" {
  type        = map(string)
  default     = {}
  description = "Additional freeform tags to apply to all resources"
}

variable "defined_tags" {
  type        = map(string)
  default     = {}
  description = "Defined tags to apply to all resources"
}

# =============================================================================
# 8. MONITORING & NOTIFICATIONS
# =============================================================================

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable OCI monitoring for the instance"
}

variable "notification_email" {
  type        = string
  default     = ""
  description = "Email address for notifications (optional)"

  validation {
    condition     = var.notification_email == "" || can(regex("^[^@ ]+@[^@ ]+\\.[^@ ]+$", var.notification_email))
    error_message = "Must be a valid email address or empty string."
  }
}
