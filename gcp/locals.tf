# =============================================================================
# LOCAL VALUES
# =============================================================================
# This file defines local values that are computed or derived from variables.
# Locals help reduce repetition and create computed values that can be
# referenced throughout the configuration.
# =============================================================================

locals {
  # Base configuration
  project_id  = var.project_id
  region      = var.region
  zone        = var.zone
  environment = var.environment
  name_prefix = "vscode-server"

  # Common labels for all resources
  common_labels = merge(
    {
      "app-name"       = local.name_prefix
      "app-instance"   = "${local.name_prefix}-${local.environment}"
      "managed-by"     = "terraform"
      "environment"    = local.environment
      "owner"          = "devops"
    },
    var.additional_tags
  )
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

locals {
  # Network tags for firewall rules
  network_tags = {
    ssh    = "ssh-iap"
    http   = "http-server"
    https  = "https-server"
    vscode = "vscode-server"
  }

  # Firewall ranges
  firewall_ranges = {
    iap_ssh   = ["35.235.240.0/20"] # IAP's IP range
    anywhere  = ["0.0.0.0/0"]
    admin     = [var.admin_ip_cidr]
  }

  # Ports
  ports = {
    ssh   = ["22"]
    http  = ["80"]
    https = ["443"]
  }
}

# =============================================================================
# VS CODE CONFIGURATION
# =============================================================================

locals {
  vscode_config = {
    domain   = var.vscode_domain
    password = var.vscode_password
    email    = var.letsencrypt_email
    bind_addr = "0.0.0.0"
    log_file  = "/var/log/vscode-server.log"
  }
}
