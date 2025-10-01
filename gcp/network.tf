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
  network_name = "${module.labels.id}-vpc-01" # VPC name using labels module

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
      subnet_name           = "${module.labels.id}-sbt-01" # Subnet 1 with standardized naming
      subnet_ip             = "100.64.0.0/24"              # Private IP range (254 IPs)
      subnet_region         = var.region                   # Deploy in configured region
      subnet_private_access = "false"                      # Disable private Google access
      subnet_flow_logs      = "false"                      # Disable flow logs for cost optimization
    },

    # Secondary subnet for additional workloads or isolation
    {
      subnet_name           = "${module.labels.id}-sbt-02" # Subnet 2 with standardized naming
      subnet_ip             = "100.64.1.0/24"              # Adjacent private IP range (254 IPs)
      subnet_region         = var.region                   # Same region as primary subnet
      subnet_private_access = "false"                      # Consistent security posture
      subnet_flow_logs      = "false"                      # Cost-optimized configuration
    }
  ]
}

# -----------------------------------------------------------------------------
# FIREWALL RULES MODULE
# -----------------------------------------------------------------------------
# Creates firewall rules for secure network access
# Includes rules for SSH access via Identity-Aware Proxy (IAP)
module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "~> 12.0"                   # Pin to compatible version
  project_id   = var.project_id              # Target GCP project
  network_name = module.network.network_name # Reference created network

  # Define firewall rules using local configuration for DRY approach
  rules = [
    # SSH access via Identity-Aware Proxy
    {
      name                    = "${module.labels.id}-allow-ssh-iap"
      description             = "Allow SSH access via Identity-Aware Proxy"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = local.firewall_ranges.iap_ssh
      source_tags             = null
      source_service_accounts = null
      target_tags             = [local.network_tags.ssh]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = local.ports.ssh
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    # HTTP access for Let's Encrypt verification
    {
      name                    = "${module.labels.id}-allow-http-letsencrypt"
      description             = "Allow HTTP access on port 80 for Let's Encrypt verification"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = local.firewall_ranges.anywhere
      source_tags             = null
      source_service_accounts = null
      target_tags             = [local.network_tags.http]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = local.ports.http
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    # HTTPS access for VS Code Server (restricted to admin IP)
    {
      name                    = "${module.labels.id}-allow-https-personal"
      description             = "Allow HTTPS access on port 443 for VS Code Server"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = local.firewall_ranges.admin
      source_tags             = null
      source_service_accounts = null
      target_tags             = [local.network_tags.https]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = local.ports.https
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}

# -----------------------------------------------------------------------------
# NETWORK ROUTES MODULE
# -----------------------------------------------------------------------------
# Creates custom routes for network traffic management
# This module adds an internet egress route for external connectivity
module "google_compute_route" {
  source       = "terraform-google-modules/network/google//modules/routes"
  version      = "~> 11.0"                   # Pin to compatible version
  project_id   = var.project_id              # Target GCP project
  network_name = module.network.network_name # Reference created network

  # Define custom routes for the network
  routes = [
    {
      name              = "${module.labels.id}-egress-internet"                # Route name with labels
      description       = "Route through Internet Gateway for external access" # Clear description
      destination_range = "0.0.0.0/0"                                          # All external traffic
      tags              = "egress-inet"                                        # Route tags for firewall rules
      next_hop_internet = "true"                                               # Route via internet gateway
    }
  ]
}


