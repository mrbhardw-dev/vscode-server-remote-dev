# =============================================================================
# COMPUTE INFRASTRUCTURE
# =============================================================================
# This file defines the compute instances and related resources using the
# official terraform-google-modules/vm modules.
#
# Components:
# - Instance template for standardized VM configuration
# - Compute instances deployed from the template
# - Network configuration and access controls
# =============================================================================

# -----------------------------------------------------------------------------
# INSTANCE TEMPLATE
# -----------------------------------------------------------------------------
# Creates a reusable instance template with standardized configuration
# This template defines the base configuration for all VM instances
module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0" # Pin to compatible version

  # Basic configuration
  region       = var.region       # Target region for template
  project_id   = var.project_id   # Target GCP project
  machine_type = var.machine_type # Machine type specification

  # Boot disk configuration
  source_image_family  = "debian-11"    # OS image family for boot disk
  source_image_project = "debian-cloud" # Project containing the image
  disk_size_gb         = 10             # Boot disk size in GB
  disk_type            = "pd-standard"  # Disk type for cost optimization
  auto_delete          = true           # Delete disk with instance

  # Network configuration
  subnetwork         = module.network.subnets_self_links[0] # Use first subnet from network module
  subnetwork_project = var.project_id                       # Project containing the subnetwork

  # Security and access configuration
  service_account = var.service_account # Service account for instances
  tags = [
    local.network_tags.ssh,
    local.network_tags.http,
    local.network_tags.https
  ] # Tags for firewall rules (SSH via IAP, HTTP/HTTPS access)

  # Startup script to install and configure code-server with Let's Encrypt
  startup_script = templatefile("${path.module}/scripts/install-vscode-server.sh", {
    vscode_domain     = local.vscode_config.domain
    vscode_password   = local.vscode_config.password
    letsencrypt_email = local.vscode_config.email
    bind_addr         = local.vscode_config.bind_addr
    log_file          = local.vscode_config.log_file
  })
}

# -----------------------------------------------------------------------------
# COMPUTE INSTANCES
# -----------------------------------------------------------------------------
# Creates compute instances based on the instance template
# Instances are deployed in the specified network and zone
module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 13.0" # Pin to compatible version

  # Location configuration
  region = var.region # Target region
  zone   = var.zone   # Specific zone for instance placement

  # Network configuration
  subnetwork         = module.network.subnets_self_links[0] # Same subnet as template
  subnetwork_project = var.project_id                       # Project containing the subnetwork

  # Instance configuration
  num_instances       = var.num_instances                  # Number of instances to create
  hostname            = "vscode"                           # Hostname for the VS Code server
  instance_template   = module.instance_template.self_link # Template to use
  deletion_protection = false                              # Allow deletion via Terraform

  # External network access configuration
  access_config = [{
    nat_ip       = var.nat_ip       # Static IP or null for ephemeral
    network_tier = var.network_tier # Network performance tier
  }]
}
