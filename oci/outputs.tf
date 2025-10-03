# =============================================================================
# CONSOLIDATED OUTPUT VALUES - REMOTE DEVELOPMENT
# =============================================================================
# Single outputs configuration providing all necessary access information
# =============================================================================

# =============================================================================
# INSTANCE ACCESS INFORMATION
# =============================================================================

output "instance_id" {
  description = "OCID of the created compute instance"
  value       = oci_core_instance.vscode_server.id
}

output "instance_name" {
  description = "Display name of the compute instance"
  value       = oci_core_instance.vscode_server.display_name
}

output "instance_shape" {
  description = "Shape configuration of the compute instance"
  value = {
    shape             = oci_core_instance.vscode_server.shape
    ocpus            = try(oci_core_instance.vscode_server.shape_config[0].ocpus, null)
    memory_in_gbs    = try(oci_core_instance.vscode_server.shape_config[0].memory_in_gbs, null)
    baseline_ocpu_utilization = try(oci_core_instance.vscode_server.shape_config[0].baseline_ocpu_utilization, null)
  }
}

output "instance_state" {
  description = "Current state of the compute instance"
  value       = oci_core_instance.vscode_server.state
}

# =============================================================================
# NETWORK ACCESS INFORMATION
# =============================================================================

output "public_ip" {
  description = "Public IP address of the instance (ephemeral or reserved)"
  value = var.use_reserved_ip ? (
    length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : null
  ) : oci_core_instance.vscode_server.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.vscode_server.private_ip
}

output "reserved_ip_ocid" {
  description = "OCID of reserved public IP (if created)"
  value       = var.use_reserved_ip ? (
    length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].id : null
  ) : null
}

# =============================================================================
# SSH CONNECTION INFORMATION
# =============================================================================

output "ssh_connection" {
  description = "SSH connection information for the instance"
  sensitive   = true
  value = {
    host         = var.use_reserved_ip ? (
      length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
    ) : oci_core_instance.vscode_server.public_ip
    user         = local.access_info.ssh_user
    port         = 22
    private_key  = var.private_key_path
    command      = "ssh -i ${var.private_key_path} ${local.access_info.ssh_user}@${
      var.use_reserved_ip ? (
        length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
      ) : oci_core_instance.vscode_server.public_ip
    }"
  }
}

# =============================================================================
# VS CODE REMOTE DEVELOPMENT INFORMATION
# =============================================================================

output "vscode_remote_info" {
  description = "Information for setting up VS Code Remote Development"
  sensitive   = true
  value = {
    ssh_host_config = {
      host           = "oci-remote-dev"
      hostname       = var.use_reserved_ip ? (
        length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
      ) : oci_core_instance.vscode_server.public_ip
      user           = local.access_info.ssh_user
      identity_file  = var.private_key_path
      port           = 22
    }
    workspace_path    = local.access_info.workspace
    installed_tools   = local.access_info.installed_tools
    setup_complete    = "Connect using VS Code Remote-SSH extension"
    connection_test   = "ssh -o ConnectTimeout=10 ${local.access_info.ssh_user}@${
      var.use_reserved_ip ? (
        length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
      ) : oci_core_instance.vscode_server.public_ip
    } 'echo Connected successfully'"
  }
}

# =============================================================================
# WORKSPACE STORAGE INFORMATION
# =============================================================================

output "workspace_volume_info" {
  description = "Information about the persistent workspace volume"
  value = var.workspace_volume_size_in_gbs > 0 ? {
    volume_ocid       = oci_core_volume.workspace_volume[0].id
    size_in_gbs      = oci_core_volume.workspace_volume[0].size_in_gbs
    attachment_ocid   = oci_core_volume_attachment.workspace_attachment[0].id
    mount_point      = "/home/${local.access_info.ssh_user}/workspace"
    backup_enabled   = var.enable_workspace_backup
    backup_policy    = var.enable_workspace_backup ? "bronze" : "none"
  } : {
    message = "No persistent workspace volume configured (workspace_volume_size_in_gbs = 0)"
  }
}

# =============================================================================
# NETWORK INFRASTRUCTURE
# =============================================================================

output "network_info" {
  description = "Network infrastructure information"
  value = {
    vcn_id              = oci_core_vcn.vcn.id
    vcn_cidr_blocks     = oci_core_vcn.vcn.cidr_blocks
    subnet_id           = oci_core_subnet.subnet.id
    subnet_cidr_block   = oci_core_subnet.subnet.cidr_block
    internet_gateway_id = oci_core_internet_gateway.igw.id
    route_table_id      = oci_core_route_table.rt.id
    security_list_id    = oci_core_security_list.sl.id
    nsg_id              = oci_core_network_security_group.nsg.id
  }
}

# =============================================================================
# DEVELOPMENT ENVIRONMENT SUMMARY
# =============================================================================

output "development_environment" {
  description = "Summary of the development environment setup"
  value = local.access_info
}

# =============================================================================
# RESOURCE TAGS AND METADATA
# =============================================================================

output "resource_tags" {
  description = "Common tags applied to all resources"
  value = local.common_tags
}

output "resource_names" {
  description = "Names of all created resources"
  value = local.resource_names
}

# =============================================================================
# QUICK START COMMANDS
# =============================================================================

output "quick_start_commands" {
  description = "Quick start commands for immediate use"
  sensitive   = true
  value = {
    ssh_connect = "ssh -i ${var.private_key_path} ${local.access_info.ssh_user}@${
      var.use_reserved_ip ? (
        length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
      ) : oci_core_instance.vscode_server.public_ip
    }"
    
    test_connection = "ping -c 4 ${
      var.use_reserved_ip ? (
        length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
      ) : oci_core_instance.vscode_server.public_ip
    }"
    
    vscode_remote = "code --remote ssh-remote+oci-remote-dev"
    
    workspace_setup = var.workspace_volume_size_in_gbs > 0 ? "mkdir -p /home/${local.access_info.ssh_user}/workspace && sudo mount /dev/oracleoci/oraclevdb /home/${local.access_info.ssh_user}/workspace" : "cd /home/${local.access_info.ssh_user}"
      
    development_tools = {
      docker    = "docker --version"
      node      = "node --version"
      npm       = "npm --version"
      python    = "python3 --version"
      pip       = "pip3 --version"
      git       = "git --version"
      go        = "go version"
      java      = "java --version"
      rust      = "rustc --version"
    }
  }
}

# =============================================================================
# MONITORING AND BACKUP STATUS
# =============================================================================

output "monitoring_and_backup" {
  description = "Status of monitoring and backup configurations"
  value = {
    monitoring_enabled    = var.enable_monitoring
    workspace_backup     = var.enable_workspace_backup
    backup_policy        = var.enable_workspace_backup && var.workspace_volume_size_in_gbs > 0 ? "bronze" : "none"
    agent_plugins        = ["Compute Instance Monitoring", "Custom Logs Monitoring", "Bastion", "Block Volume Management"]
  }
}

# =============================================================================
# TROUBLESHOOTING INFORMATION
# =============================================================================

output "troubleshooting" {
  description = "Troubleshooting and diagnostic information"
  sensitive   = true
  value = {
    cloud_init_log      = "/var/log/cloud-init-output.log"
    system_logs         = "/var/log/syslog"
    ssh_debug_command   = "ssh -v -i ${var.private_key_path} ${local.access_info.ssh_user}@${
      var.use_reserved_ip ? (
        length(oci_core_public_ip.reserved_ip) > 0 ? oci_core_public_ip.reserved_ip[0].ip_address : oci_core_instance.vscode_server.public_ip
      ) : oci_core_instance.vscode_server.public_ip
    }"
    instance_console    = "Available through OCI Console -> Compute -> Instances -> ${oci_core_instance.vscode_server.display_name}"
    support_bundle      = "sudo journalctl -u cloud-init-local -u cloud-init -u cloud-config -u cloud-final --no-pager"
  }
}