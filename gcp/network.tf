# =============================================================================
# VPC NETWORK INFRASTRUCTURE
# =============================================================================
# This file defines the Virtual Private Cloud (VPC) network and associated
# subnets using the official terraform-google-modules/network module.
#
# Architecture:
# - Custom VPC with regional routing
# - Multiple subnets for workload separation
# - Standardized naming using labels module
# - No auto-created subnetworks (custom design)
# =============================================================================

# -----------------------------------------------------------------------------
# GOOGLE CLOUD VPC NETWORK MODULE
# -----------------------------------------------------------------------------
# Creates a custom VPC network with specified subnets
# Uses the official Google Cloud network module for best practices
module "network" {
  source  = "terraform-google-modules/network/google"
  version = "12.0.0" # Pin to specific version for stability

  # -----------------------------------------------------------------------------
  # CORE NETWORK CONFIGURATION
  # -----------------------------------------------------------------------------
  project_id   = var.project_id               # Target GCP project
  network_name = "${local.name_prefix}-vpc-01" # VPC name using labels module

  # Network behavior settings
  auto_create_subnetworks = false      # Use custom subnets only
  routing_mode            = "REGIONAL" # Regional routing for better performance
  mtu                     = 1460       # Maximum Transmission Unit (standard for GCP)

  # -----------------------------------------------------------------------------
  # SUBNET DEFINITIONS
  # -----------------------------------------------------------------------------
  # Define custom subnets for different workload types or availability
  subnets = [
    # Primary subnet for main workloads
    {
      subnet_name           = "${local.name_prefix}-sbt-01" # Subnet 1 with standardized naming
      subnet_ip             = "100.64.0.0/24"              # Private IP range (254 IPs)
      subnet_region         = var.region                   # Deploy in configured region
      subnet_private_access = "false"                      # Disable private Google access
      subnet_flow_logs      = "false"                      # Disable flow logs for cost optimization
    },

    # Secondary subnet for additional workloads or isolation
    {
      subnet_name           = "${local.name_prefix}-sbt-02" # Subnet 2 with standardized naming
      subnet_ip             = "100.64.1.0/24"              # Adjacent private IP range (254 IPs)
      subnet_region         = var.region                   # Same region as primary subnet
      subnet_private_access = "false"                      # Consistent security posture
      subnet_flow_logs      = "false"                      # Cost-optimized configuration
    }
  ]
}

# -----------------------------------------------------------------------------
# FIREWALL RULES
# -----------------------------------------------------------------------------
# Creates firewall rules for secure network access

# SSH access via Identity-Aware Proxy
resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${local.name_prefix}-allow-ssh-iap"
  network = module.network.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP's IP range
  target_tags   = [local.network_tags.ssh]

  description = "Allow SSH access via Identity-Aware Proxy"
}

# HTTP access for Let's Encrypt verification
resource "google_compute_firewall" "allow_http" {
  name    = "${local.name_prefix}-allow-http"
  network = module.network.network_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.network_tags.http]

  description = "Allow HTTP access for Let's Encrypt verification"
}

# HTTPS access for VS Code Server
resource "google_compute_firewall" "allow_https" {
  name    = "${local.name_prefix}-allow-https"
  network = module.network.network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [var.admin_ip_cidr]
  target_tags   = [local.network_tags.https]

  description = "Allow HTTPS access for VS Code Server"
}
