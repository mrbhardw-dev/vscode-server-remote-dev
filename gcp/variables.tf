# =============================================================================
# INPUT VARIABLES
# =============================================================================
# This file defines all input variables for the Terraform configuration.
# Variables can be set via terraform.tfvars, environment variables, or CLI.
#
# Variable Organization:
# 1. Project & Authentication
# 2. Region & Zone
# 3. Network Configuration
# 4. Compute Instance Settings
# 5. Security & Access
# 6. Application Configuration
#
# Each section is separated by a visual divider for better readability.
# =============================================================================

# =============================================================================
# 1. PROJECT & AUTHENTICATION
# =============================================================================

variable "project_id" {
  type        = string
  description = "The Google Cloud Platform project ID where resources will be created"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP service account JSON key file"
  sensitive   = true

  validation {
    condition     = fileexists(var.credentials_file)
    error_message = "The specified credentials file path does not exist."
  }
}

# =============================================================================
# 2. REGION & ZONE
# =============================================================================

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "The GCP region where resources will be deployed"

  validation {
    condition     = can(regex("^(us|europe|asia|australia|southamerica)-(central|east|north|northeast|south|southeast|southwest|west)[0-9]?$", var.region))
    error_message = "Must be a valid GCP region (e.g., us-central1, europe-west2)."
  }
}

variable "zone" {
  type        = string
  description = "The GCP zone to create resources in (e.g., europe-west2-b)"
  default     = "europe-west2-b"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.zone))
    error_message = "Must be a valid GCP zone format (e.g., europe-west2-b)."
  }
}

# =============================================================================
# 3. NETWORK CONFIGURATION
# =============================================================================

variable "network_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR range for the VPC network"

  validation {
    condition     = can(cidrnetmask(var.network_cidr))
    error_message = "Must be a valid CIDR notation (e.g., 10.0.0.0/16)."
  }
}

variable "subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "List of CIDR ranges for subnets"

  validation {
    condition     = length(var.subnet_cidrs) > 0 && alltrue([for cidr in var.subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All elements must be valid CIDR notations."
  }
}

# =============================================================================
# 4. COMPUTE INSTANCE SETTINGS
# =============================================================================

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "The machine type to create (e.g., e2-micro, n1-standard-1)"

  validation {
    condition     = can(regex("^[a-z0-9]+-[a-z0-9]+$", var.machine_type))
    error_message = "Must be a valid GCP machine type."
  }
}

variable "boot_disk_size_gb" {
  type        = number
  default     = 30
  description = "Size of the boot disk in GB"

  validation {
    condition     = var.boot_disk_size_gb >= 10 && var.boot_disk_size_gb <= 65536
    error_message = "Boot disk size must be between 10GB and 65,536GB."
  }
}

variable "boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "Type of the boot disk (pd-standard, pd-ssd, pd-balanced, pd-extreme)"

  validation {
    condition     = contains(["pd-standard", "pd-ssd", "pd-balanced", "pd-extreme"], var.boot_disk_type)
    error_message = "Must be one of: pd-standard, pd-ssd, pd-balanced, pd-extreme."
  }
}

# =============================================================================
# 5. SECURITY & ACCESS
# =============================================================================

variable "admin_ip_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR block for administrative access (restrict to your IP in production)"

  validation {
    condition     = can(cidrnetmask(var.admin_ip_cidr))
    error_message = "Must be a valid CIDR notation."
  }
}

variable "service_account" {
  type = object({
    email  = string
    scopes = set(string)
  })
  default = {
    email  = null
    scopes = ["cloud-platform"] # Minimal scopes required
  }
  description = "Service account configuration for compute instances"

  validation {
    condition     = var.service_account.email == null || try(can(regex("@[a-z0-9-]+\\.iam\\.gserviceaccount\\.com$", var.service_account.email)), false)
    error_message = "Service account email must be a valid service account format (e.g., name@project.iam.gserviceaccount.com)"
  }

  validation {
    condition     = var.service_account.scopes == null || length(var.service_account.scopes) > 0
    error_message = "At least one scope must be defined if scopes are provided"
  }
}

# =============================================================================
# 6. APPLICATION CONFIGURATION
# =============================================================================

variable "vscode_domain" {
  type        = string
  description = "Domain name for the VS Code Server (e.g., code.example.com)"

  validation {
    condition     = can(regex("^([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,}$", var.vscode_domain))
    error_message = "Must be a valid domain name."
  }
}

variable "vscode_password" {
  type        = string
  description = "Password for the VS Code Server"
  sensitive   = true

  validation {
    condition     = length(var.vscode_password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address for Let's Encrypt certificate notifications"

  validation {
    condition     = can(regex("^[^@ ]+@[^@ ]+\\.[^@ ]+$", var.letsencrypt_email))
    error_message = "Must be a valid email address."
  }
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable Cloud Monitoring and Logging"
}

variable "enable_os_login" {
  type        = bool
  default     = true
  description = "Enable OS Login for better security and IAM integration"
}

# =============================================================================
# 7. SCALING & MAINTENANCE
# =============================================================================

variable "num_instances" {
  type        = number
  default     = 1
  description = "Number of instances to create"

  validation {
    condition     = var.num_instances > 0 && var.num_instances <= 10
    error_message = "Number of instances must be between 1 and 10."
  }
}

variable "auto_delete_disk" {
  type        = bool
  default     = true
  description = "Automatically delete the disk when the instance is deleted"
}

# =============================================================================
# 8. TAGS & LABELS
# =============================================================================

variable "environment" {
  type        = string
  default     = "production"
  description = "Environment (e.g., development, staging, production)"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}

# =============================================================================
# 9. BACKUP & RECOVERY
# =============================================================================

variable "enable_backup" {
  type        = bool
  default     = false
  description = "Enable automated backups"
}

variable "backup_schedule" {
  type        = string
  default     = "0 2 * * *" # 2 AM daily
  description = "Cron schedule for backups"

  validation {
    condition     = can(regex("^(([0-9]|,|-|/|\\.|\\*|\\s*)+ ){4,5}[0-9]?$", var.backup_schedule))
    error_message = "Must be a valid cron expression."
  }
}

# =============================================================================
# 10. NOTIFICATIONS
# =============================================================================

variable "notification_email" {
  type        = string
  default     = ""
  description = "Email address for receiving notifications (alerts, monitoring, etc.)"

  validation {
    condition     = var.notification_email == "" || can(regex("^[^@ ]+@[^@ ]+\\.[^@ ]+$", var.notification_email))
    error_message = "Must be a valid email address or empty string."
  }
}

# =============================================================================
# 11. MISCELLANEOUS
# =============================================================================

variable "managed_by" {
  type        = string
  default     = "devops@example.com"
  description = "Email address of the person or team responsible for these resources"

  validation {
    condition     = can(regex("^[^@ ]+@[^@ ]+\\.[^@ ]+$", var.managed_by))
    error_message = "Must be a valid email address."
  }
}
variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "The machine type for compute instances (e.g., e2-micro, n1-standard-1, e2-medium)"

  validation {
    condition     = can(regex("^(e2|n1|n2|c2|m1|m2|a2|t2d|c3|m3|g2)-.+", var.machine_type))
    error_message = "Machine type must be a valid GCP machine type format."
  }
}

# Boot Disk Image for Compute Instances
# Specify the OS image for the boot disk
variable "boot_disk_image" {
  type        = string
  default     = "debian-cloud/debian-11"
  description = "The OS image for the boot disk (e.g., debian-cloud/debian-11, ubuntu-os-cloud/ubuntu-2004-lts)"

  validation {
    condition     = can(regex("^[a-z0-9-]+/[a-z0-9-]+(-.+)*$", var.boot_disk_image))
    error_message = "Boot disk image must be in format 'project/image' (e.g., debian-cloud/debian-11, ubuntu-os-cloud/ubuntu-2004-lts)."
  }
}

# -----------------------------------------------------------------------------
# NETWORKING CONFIGURATION
# -----------------------------------------------------------------------------

# Static Public IP Address
# Optional external IP address for compute instances
# Set to null for ephemeral (auto-assigned) IP addresses
variable "nat_ip" {
  type        = string
  default     = null
  description = "Static public IP address to assign to instances. Leave null for ephemeral (auto-assigned) IP."

  validation {
    condition     = var.nat_ip == null || can(cidrhost("${var.nat_ip}/32", 0))
    error_message = "NAT IP must be a valid IPv4 address or null."
  }
}

# Network Performance Tier
# Choose between standard and premium network performance
variable "network_tier" {
  type        = string
  default     = "PREMIUM"
  description = "Network performance tier for external IP addresses (STANDARD or PREMIUM)"

  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.network_tier)
    error_message = "Network tier must be either STANDARD or PREMIUM."
  }
}

# -----------------------------------------------------------------------------
# VS CODE SERVER CONFIGURATION
# -----------------------------------------------------------------------------

# Domain name for VS Code Server
variable "vscode_domain" {
  type        = string
  default     = "vscode.mbtux.com"
  description = "Domain name for the VS Code Server (must have valid DNS pointing to the instance)"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]\\.[a-z]{2,}$", var.vscode_domain))
    error_message = "VS Code domain must be a valid domain name format."
  }
}

# Admin email for Let's Encrypt certificate
variable "letsencrypt_email" {
  type        = string
  default     = "admin@mbtux.com"
  description = "Email address for Let's Encrypt certificate registration and notifications"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.letsencrypt_email))
    error_message = "Let's Encrypt email must be a valid email address format."
  }
}

# VS Code Server password
variable "vscode_password" {
  type        = string
  default     = "P@ssw0rd@123"
  description = "Password for VS Code Server authentication"
  sensitive   = true

  validation {
    condition     = length(var.vscode_password) >= 8
    error_message = "VS Code password must be at least 8 characters long."
  }
}

# Your public IP for firewall restrictions
variable "admin_ip_cidr" {
  type        = string
  default     = "208.127.201.111/32"
  description = "Your public IP address in CIDR format for firewall access restrictions"

  validation {
    condition     = can(cidrhost(var.admin_ip_cidr, 0))
    error_message = "Admin IP CIDR must be a valid CIDR notation (e.g., 192.168.1.1/32)."
  }
}