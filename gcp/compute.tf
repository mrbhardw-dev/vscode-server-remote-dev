# =============================================================================
# COMPUTE INFRASTRUCTURE
# =============================================================================
# This file defines the compute instances for VS Code Server on GCP.
# =============================================================================

# -----------------------------------------------------------------------------
# COMPUTE INSTANCE
# -----------------------------------------------------------------------------
resource "google_compute_instance" "vscode_server" {
  count        = var.num_instances
  name         = "${local.name_prefix}-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [
    local.network_tags.ssh,
    local.network_tags.http,
    local.network_tags.https
  ]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
    auto_delete = var.auto_delete_disk
  }

  network_interface {
    network    = module.network.network_name
    subnetwork = module.network.subnets_self_links[0]

    access_config {
      nat_ip       = var.nat_ip
      network_tier = var.network_tier
    }
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  metadata = {
    enable-oslogin         = var.enable_os_login ? "TRUE" : "FALSE"
    block-project-ssh-keys = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install-vscode-server.sh", {
    vscode_domain     = local.vscode_config.domain
    vscode_password   = local.vscode_config.password
    letsencrypt_email = local.vscode_config.email
    bind_addr         = local.vscode_config.bind_addr
    log_file          = local.vscode_config.log_file
  })

  labels = merge(local.common_labels, {
    role = "vscode-server"
  })

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"],
    ]
  }
}
