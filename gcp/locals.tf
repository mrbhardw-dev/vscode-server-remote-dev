# =============================================================================
# LOCAL VALUES
# =============================================================================
# This file defines local values that are computed or derived from variables.
# Locals help reduce repetition and create computed values that can be
# referenced throughout the configuration.
#
# Organization:
# 1. Core Configuration
# 2. Naming & Labels
# 3. Network Configuration
# 4. Compute Configuration
# 5. Security & Access
# 6. Monitoring & Logging
# =============================================================================

# =============================================================================
# 1. CORE CONFIGURATION
# =============================================================================

locals {
  # Base configuration
  project_id  = var.project_id
  region      = var.region
  zone        = var.zone
  environment = var.environment
  name_prefix = "vscode-server"

  # Timestamp for unique resource naming
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())

  # Common labels for all resources
  common_labels = merge(
    {
      "app.kubernetes.io/name"       = local.name_prefix
      "app.kubernetes.io/instance"   = "${local.name_prefix}-${local.environment}"
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = local.environment
      "managed-by"                   = "terraform"
      "owner"                        = "devops"
    },
    var.additional_tags
  )
}

# =============================================================================
# 2. NAMING & LABELS
# =============================================================================

locals {
  # Resource naming
  resource_prefix = "${local.name_prefix}-${local.environment}"

  # Standardized resource names
  resource_names = {
    vpc_network     = "${local.resource_prefix}-vpc"
    subnet          = "${local.resource_prefix}-subnet"
    firewall        = "${local.resource_prefix}-fw"
    instance        = "${local.resource_prefix}-vm"
    instance_group  = "${local.resource_prefix}-ig"
    service_account = "${local.resource_prefix}-sa"
  }

  # Standardized descriptions
  descriptions = {
    vpc_network     = "VPC Network for ${local.resource_prefix}"
    subnet          = "Subnet for ${local.resource_prefix} in ${local.region}"
    firewall        = "Firewall rules for ${local.resource_prefix}"
    instance        = "Compute instance for ${local.resource_prefix}"
    service_account = "Service account for ${local.resource_prefix}"
  }
}

# =============================================================================
# 3. NETWORK CONFIGURATION
# =============================================================================

locals {
  # Network configuration
  network_cidr = var.network_cidr
  subnet_cidrs = var.subnet_cidrs

  # Network tags for firewall rules
  network_tags = {
    ssh           = "ssh-iap"
    http          = "http-server"
    https         = "https-server"
    vscode        = "vscode-server"
    internal      = "internal"
    external      = "external"
    load_balancer = "load-balancer"
  }

  # Firewall rules configuration
  firewall_rules = {
    allow_ssh = {
      name        = "${local.resource_prefix}-allow-ssh"
      description = "Allow SSH access from IAP"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["35.235.240.0/20"] # IAP's IP range
      target_tags = [local.network_tags.ssh]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    allow_http = {
      name        = "${local.resource_prefix}-allow-http"
      description = "Allow HTTP traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      target_tags = [local.network_tags.http]
      allow = [{
        protocol = "tcp"
        ports    = ["80"]
      }]
    },
    allow_https = {
      name        = "${local.resource_prefix}-allow-https"
      description = "Allow HTTPS traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      target_tags = [local.network_tags.https]
      allow = [{
        protocol = "tcp"
        ports    = ["443"]
      }]
    },
    allow_internal = {
      name        = "${local.resource_prefix}-allow-internal"
      description = "Allow all internal traffic"
      direction   = "INGRESS"
      priority    = 1000
      source_tags = [local.network_tags.internal]
      target_tags = [local.network_tags.internal]
      allow = [{
        protocol = "all"
      }]
    }
  }
}

# =============================================================================
# 4. COMPUTE CONFIGURATION
# =============================================================================

locals {
  # Instance configuration
  instance_config = {
    name_prefix      = local.resource_prefix
    machine_type     = var.machine_type
    min_cpu_platform = "Intel Skylake"

    # Boot disk configuration
    boot_disk = {
      type          = var.boot_disk_type
      size_gb       = var.boot_disk_size_gb
      auto_delete   = var.auto_delete_disk
      image         = "debian-11-bullseye-v20230629"
      image_project = "debian-cloud"
    }

    # Metadata
    metadata = {
      enable-oslogin         = var.enable_os_login ? "TRUE" : "FALSE"
      block-project-ssh-keys = "TRUE"
    }

    # Labels
    labels = merge(local.common_labels, {
      role = "vscode-server"
    })

    # Tags
    tags = [
      local.network_tags.ssh,
      local.network_tags.https,
      local.network_tags.vscode
    ]
  }

  # Startup script template
  startup_script = templatefile("${path.module}/scripts/startup.sh", {
    domain            = var.vscode_domain
    password          = var.vscode_password
    letsencrypt_email = var.letsencrypt_email
    enable_monitoring = var.enable_monitoring
  })
}

# =============================================================================
# 5. SECURITY & ACCESS
# =============================================================================

locals {
  # Service account configuration
  service_account = {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  # IAM roles for the service account
  iam_roles = [
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/monitoring.viewer"
  ]

  # Admin users (for IAM bindings)
  admin_users = [
    "user:${var.managed_by}",
    "group:devops@your-domain.com"
  ]
}

# =============================================================================
# 6. MONITORING & LOGGING
# =============================================================================

locals {
  # Monitoring configuration
  monitoring_config = {
    enabled             = var.enable_monitoring
    enable_uptime_check = true
    notification_channels = [
      var.notification_email != "" ? "email:${var.notification_email}" : ""
    ]
  }

  # Logging configuration
  logging_config = {
    enabled        = true
    retention_days = 30
    log_types = [
      "cloudaudit.googleapis.com/activity",
      "cloudaudit.googleapis.com/system_event",
      "compute.googleapis.com/activity_log"
    ]
  }
}