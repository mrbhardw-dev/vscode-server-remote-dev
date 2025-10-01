# =============================================================================
# COMPUTE INFRASTRUCTURE - ORACLE CLOUD
# =============================================================================
# This file defines the compute instance for VS Code Server on OCI.
# Optimized for OCI Always Free Tier.
#
# Free Tier Options:
# - VM.Standard.E2.1.Micro (AMD): 1 OCPU, 1 GB RAM (2 instances)
# - VM.Standard.A1.Flex (ARM): Up to 4 OCPUs, 24 GB RAM (shared across instances)
# =============================================================================

# =============================================================================
# COMPUTE INSTANCE
# =============================================================================

resource "oci_core_instance" "vscode_server" {
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  display_name        = local.display_names.instance
  shape               = local.instance_config.shape

  # Shape configuration (only for Flex shapes)
  dynamic "shape_config" {
    for_each = local.instance_config.shape_config != null ? [local.instance_config.shape_config] : []
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  # Source details (boot volume and image)
  source_details {
    source_type             = local.instance_config.source_details.source_type
    source_id               = local.instance_config.source_details.image_id
    boot_volume_size_in_gbs = local.instance_config.source_details.boot_volume_size_in_gbs
  }

  # Network configuration
  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnet.id
    display_name              = "${local.resource_prefix}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = replace(local.resource_prefix, "-", "")
    nsg_ids                   = [oci_core_network_security_group.nsg.id]

    freeform_tags = merge(
      local.common_tags,
      {
        "Name" = "${local.resource_prefix}-vnic"
        "Type" = "VNIC"
      }
    )
  }

  # Metadata for cloud-init and SSH
  metadata = local.instance_config.metadata

  # Agent configuration
  agent_config {
    is_monitoring_disabled = !var.enable_monitoring
    is_management_disabled = false

    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = var.enable_monitoring ? "ENABLED" : "DISABLED"
    }

    plugins_config {
      name          = "Bastion"
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

  # Preserve boot volume on instance termination (optional)
  preserve_boot_volume = false

  # Tags
  freeform_tags = merge(
    local.common_tags,
    {
      "Name"  = local.resource_names.instance
      "Type"  = "ComputeInstance"
      "Shape" = var.instance_shape
      "OS"    = var.os_type
    }
  )
  defined_tags = var.defined_tags

  # Lifecycle
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,  # Ignore image updates
    ]
  }
}

# =============================================================================
# RESERVED PUBLIC IP (OPTIONAL - For static IP)
# =============================================================================

# Uncomment this block if you want a reserved public IP that persists
# even if the instance is stopped or recreated

# resource "oci_core_public_ip" "reserved_ip" {
#   compartment_id = var.compartment_id
#   lifetime       = "RESERVED"
#   display_name   = local.resource_names.public_ip
#
#   freeform_tags = merge(
#     local.common_tags,
#     {
#       "Name" = local.resource_names.public_ip
#       "Type" = "PublicIP"
#     }
#   )
#   defined_tags = var.defined_tags
# }

# =============================================================================
# BLOCK VOLUME (OPTIONAL - For additional storage)
# =============================================================================

# Uncomment this block if you need additional storage
# Free Tier includes up to 200 GB total block storage

# resource "oci_core_volume" "data_volume" {
#   compartment_id      = var.compartment_id
#   availability_domain = local.availability_domain
#   display_name        = "${local.resource_prefix}-data"
#   size_in_gbs         = 50  # Adjust as needed (max 200 GB total for Free Tier)
#
#   freeform_tags = merge(
#     local.common_tags,
#     {
#       "Name" = "${local.resource_prefix}-data"
#       "Type" = "BlockVolume"
#     }
#   )
#   defined_tags = var.defined_tags
# }

# resource "oci_core_volume_attachment" "data_volume_attachment" {
#   attachment_type = "paravirtualized"
#   instance_id     = oci_core_instance.vscode_server.id
#   volume_id       = oci_core_volume.data_volume.id
#   display_name    = "${local.resource_prefix}-data-attachment"
#
#   # Device path
#   device = "/dev/oracleoci/oraclevdb"
# }

# =============================================================================
# BOOT VOLUME BACKUP POLICY (OPTIONAL)
# =============================================================================

# Uncomment to enable automated backups of the boot volume
# Note: Backups consume storage quota

# data "oci_core_volume_backup_policies" "backup_policies" {
#   filter {
#     name   = "display_name"
#     values = ["bronze"]  # bronze, silver, or gold
#   }
# }

# resource "oci_core_volume_backup_policy_assignment" "boot_volume_backup" {
#   asset_id  = oci_core_instance.vscode_server.boot_volume_id
#   policy_id = data.oci_core_volume_backup_policies.backup_policies.volume_backup_policies[0].id
# }
