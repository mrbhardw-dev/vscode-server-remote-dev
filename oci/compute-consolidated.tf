# =============================================================================
# CONSOLIDATED COMPUTE CONFIGURATION - REMOTE DEVELOPMENT
# =============================================================================
# Single compute configuration supporting both basic and enhanced setups
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
    for_each = local.instance_config.shape_config != null ? [local.instance_config.shape_config] : []
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  # Operating system and storage configuration
  source_details {
    source_type             = local.instance_config.source_details.source_type
    source_id               = local.instance_config.source_details.image_id
    boot_volume_size_in_gbs = local.instance_config.source_details.boot_volume_size_in_gbs
  }

  # Network configuration
  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnet.id
    display_name              = "${local.resource_prefix}-vnic"
    assign_public_ip          = var.use_reserved_ip ? false : true
    assign_private_dns_record = true
    hostname_label            = "vscodeprod"
    nsg_ids                   = [oci_core_network_security_group.nsg.id]

    freeform_tags = local.common_tags
  }

  # Metadata for SSH and cloud-init
  metadata = local.instance_config.metadata

  # Agent configuration for monitoring and management
  agent_config {
    is_monitoring_disabled = !var.enable_monitoring
    is_management_disabled = false

    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = var.enable_monitoring ? "ENABLED" : "DISABLED"
    }

    plugins_config {
      name          = "Custom Logs Monitoring"
      desired_state = "ENABLED"
    }

    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }

    plugins_config {
      name          = "Block Volume Management"
      desired_state = "ENABLED"
    }
  }

  # Availability configuration
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  # Instance options
  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }

  # Preserve boot volume based on configuration
  preserve_boot_volume = false

  # Tags
  freeform_tags = local.common_tags
  defined_tags = var.defined_tags

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      source_details[0].source_id, # Allow image updates
    ]
  }
}

# =============================================================================
# PERSISTENT WORKSPACE STORAGE (OPTIONAL)
# =============================================================================

# Create workspace volume only if workspace_volume_size_in_gbs > 0
resource "oci_core_volume" "workspace_volume" {
  count = var.workspace_volume_size_in_gbs > 0 ? 1 : 0

  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  display_name        = local.display_names.workspace
  size_in_gbs         = var.workspace_volume_size_in_gbs

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# Attach workspace volume to instance
resource "oci_core_volume_attachment" "workspace_attachment" {
  count = var.workspace_volume_size_in_gbs > 0 ? 1 : 0

  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vscode_server.id
  volume_id       = oci_core_volume.workspace_volume[0].id
  display_name    = "${local.resource_prefix}-workspace-attachment"

  # Use consistent device name
  device = "/dev/oracleoci/oraclevdb"
}

# =============================================================================
# RESERVED PUBLIC IP (OPTIONAL)
# =============================================================================

resource "oci_core_public_ip" "reserved_ip" {
  count = var.use_reserved_ip ? 1 : 0

  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = local.display_names.reserved_ip

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# BACKUP POLICY FOR WORKSPACE (OPTIONAL)
# =============================================================================

# Get available backup policies
data "oci_core_volume_backup_policies" "backup_policies" {
  count = var.enable_workspace_backup && var.workspace_volume_size_in_gbs > 0 ? 1 : 0

  filter {
    name   = "display_name"
    values = ["bronze"]  # Daily backups with 7-day retention
  }
}

# Apply backup policy to workspace volume
resource "oci_core_volume_backup_policy_assignment" "workspace_backup" {
  count = var.enable_workspace_backup && var.workspace_volume_size_in_gbs > 0 ? 1 : 0

  asset_id  = oci_core_volume.workspace_volume[0].id
  policy_id = data.oci_core_volume_backup_policies.backup_policies[0].volume_backup_policies[0].id
}