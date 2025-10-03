# =============================================================================
# GCP - NETWORK RESOURCES
# =============================================================================
# This file defines the VPC, subnet, and firewall rules.
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Network
# -----------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  name                    = "${local.resource_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# -----------------------------------------------------------------------------
# Subnet
# -----------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.resource_prefix}-subnet"
  ip_cidr_range = "10.10.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# -----------------------------------------------------------------------------
# Firewall Rules
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_web_access" {
  name    = "${local.resource_prefix}-allow-web-access"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "7080", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vscode-server"]
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${local.resource_prefix}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # IAP traffic comes from a specific CIDR block owned by Google.
  # See: https://cloud.google.com/iap/docs/using-tcp-forwarding
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["vscode-server"]
}