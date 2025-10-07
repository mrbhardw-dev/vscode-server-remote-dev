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
  shape               = local.instance_config.shape

  # Dynamic shape configuration for Flex instances
  dynamic "shape_config" {
    for_each = local.instance_config.shape_config != null ? [local.instance_config.shape_config] : []
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  # Operating system and storage configuration
  source_details {
    source_type             = "image"
    source_id               = local.instance_config.image_id
    boot_volume_size_in_gbs = local.instance_config.boot_volume_size
  }

  # Network configuration
  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnet.id
    display_name              = "${local.resource_prefix}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = local.resource_prefix
    nsg_ids                   = [oci_core_network_security_group.nsg.id]
  }

  # Metadata for SSH and cloud-init
  metadata = {
    ssh_authorized_keys = local.ssh_public_key_content
    user_data           = base64encode(templatefile("${path.module}/scripts/install-vscode-server.sh", {
      code_user         = var.dev_username
      vscode_password   = var.vscode_password
      http_port         = var.vscode_web_port
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
