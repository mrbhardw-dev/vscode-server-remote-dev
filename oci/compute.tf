# =============================================================================
# COMPUTE CONFIGURATION
# =============================================================================
# This file defines the compute instance and its associated resources.
# =============================================================================

# =============================================================================
# MAIN COMPUTE INSTANCE
# =============================================================================
resource "oci_core_instance" "vscode_server" {
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  display_name        = local.display_names.instance
  shape               = var.instance_shape

  # Dynamic shape configuration for Flex instances
  dynamic "shape_config" {
    for_each = local.shape_config != null ? [local.shape_config] : []
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  # Operating system and storage configuration
  source_details {
    source_type             = "image"
    source_id               = local.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  # Network configuration
  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnet.id
    display_name              = "${local.resource_prefix}-vnic"
    assign_public_ip          = false # Public IP is handled by oci_core_public_ip
    assign_private_dns_record = true
    hostname_label            = local.resource_prefix
    nsg_ids                   = [oci_core_network_security_group.nsg.id]
  }

  # Metadata for SSH and cloud-init
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(templatefile("${path.module}/scripts/install-vscode-server.sh", {
      code_user         = var.code_user
      vscode_password   = var.vscode_password
      vscode_domain     = var.vscode_domain
      letsencrypt_email = var.letsencrypt_email
      http_port         = var.http_port
    }))
  }

  # Agent configuration for monitoring and management
  agent_config {
    is_monitoring_disabled = false
    is_management_disabled = false
  }

  # Tags
  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# RESERVED PUBLIC IP
# =============================================================================

resource "oci_core_public_ip" "reserved_ip" {
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${local.resource_prefix}-ip"

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

resource "oci_core_public_ip_attachment" "ip_attachment" {
  public_ip_id    = oci_core_public_ip.reserved_ip.id
  private_ip_id   = data.oci_core_private_ip.primary_vnic_private_ip.id
  display_name    = "${local.resource_prefix}-ip-attachment"
  lifecycle {
    # The primary VNIC is created and deleted with the instance, so we need to
    # create the attachment before destroying the old one during an update.
    create_before_destroy = true
  }
}