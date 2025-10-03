# =============================================================================
# GCP - COMPUTE RESOURCES
# =============================================================================
# This file defines the static IP, service account, and Compute Engine instance.
# =============================================================================

# -----------------------------------------------------------------------------
# This file defines the static IP, service account, and Compute Engine instance.
# =============================================================================

# -----------------------------------------------------------------------------
# Static External IP Address
# -----------------------------------------------------------------------------
resource "google_compute_address" "static_ip" {
  name   = "${local.resource_prefix}-static-ip"
  region = var.region
}

# -----------------------------------------------------------------------------
# Dedicated Service Account for the Instance
# -----------------------------------------------------------------------------
resource "google_service_account" "instance_sa" {
  account_id   = "${local.resource_prefix}-sa"
  display_name = "Service Account for VS Code Server Instance"
}

# -----------------------------------------------------------------------------
# Compute Instance
# -----------------------------------------------------------------------------

resource "google_compute_instance" "vscode_server" {
  name         = "${local.resource_prefix}-instance"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["vscode-server"]
  labels       = local.common_tags

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
  }
  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    startup-script = file("${path.module}/scripts/install-vscode-server.sh")
  }
  service_account {
    email  = google_service_account.instance_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  allow_stopping_for_update = true
}
