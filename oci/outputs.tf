# =============================================================================
# OUTPUT VALUES - ORACLE CLOUD INFRASTRUCTURE
# =============================================================================
# This file defines output values shown after successful deployment.
# Provides important information about created resources for access and management.
#
# Organization:
# 1. Instance Information
# 2. Network Information
# 3. Access Information
# 4. Free Tier Usage
# 5. Monitoring & Management
# =============================================================================

# =============================================================================
# 1. INSTANCE INFORMATION
# =============================================================================

output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.vscode_server.id
}

output "instance_name" {
  description = "Display name of the compute instance"
  value       = oci_core_instance.vscode_server.display_name
}

output "instance_shape" {
  description = "Shape of the compute instance"
  value       = oci_core_instance.vscode_server.shape
}

output "instance_state" {
  description = "Current state of the compute instance"
  value       = oci_core_instance.vscode_server.state
}

output "availability_domain" {
  description = "Availability domain where the instance is deployed"
  value       = oci_core_instance.vscode_server.availability_domain
}

output "instance_ocpus" {
  description = "Number of OCPUs allocated to the instance"
  value       = try(oci_core_instance.vscode_server.shape_config[0].ocpus, 1)
}

output "instance_memory_gb" {
  description = "Amount of memory in GB allocated to the instance"
  value       = try(oci_core_instance.vscode_server.shape_config[0].memory_in_gbs, 1)
}

# =============================================================================
# 2. NETWORK INFORMATION
# =============================================================================

output "vcn_id" {
  description = "OCID of the Virtual Cloud Network"
  value       = oci_core_vcn.vcn.id
}

output "vcn_name" {
  description = "Display name of the VCN"
  value       = oci_core_vcn.vcn.display_name
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.vcn.cidr_blocks[0]
}

output "subnet_id" {
  description = "OCID of the subnet"
  value       = oci_core_subnet.subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = oci_core_subnet.subnet.cidr_block
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = oci_core_instance.vscode_server.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.vscode_server.private_ip
}

# =============================================================================
# 3. ACCESS INFORMATION
# =============================================================================

output "vscode_url" {
  description = "URL to access VS Code Server"
  value       = "http://${oci_core_instance.vscode_server.public_ip}:${var.vscode_port}"
}

output "vscode_https_url" {
  description = "HTTPS URL to access VS Code Server (if HTTPS is enabled)"
  value       = var.enable_https ? "https://${oci_core_instance.vscode_server.public_ip}" : "HTTPS not enabled"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = var.os_type == "ubuntu" ? "ssh ubuntu@${oci_core_instance.vscode_server.public_ip}" : "ssh opc@${oci_core_instance.vscode_server.public_ip}"
}

output "ssh_user" {
  description = "SSH username for the instance"
  value       = var.os_type == "ubuntu" ? "ubuntu" : "opc"
}

output "access_instructions" {
  description = "Instructions for accessing the VS Code Server"
  value = [
    "1. Wait 2-3 minutes for VS Code Server to install",
    "2. Access via browser: http://${oci_core_instance.vscode_server.public_ip}:${var.vscode_port}",
    var.enable_https ? "3. HTTPS access: https://${oci_core_instance.vscode_server.public_ip}" : "3. HTTPS is not enabled",
    "4. SSH access: ${var.os_type == "ubuntu" ? "ssh ubuntu@${oci_core_instance.vscode_server.public_ip}" : "ssh opc@${oci_core_instance.vscode_server.public_ip}"}",
    "5. Check installation: sudo journalctl -u cloud-final -f"
  ]
  sensitive = false
}

# =============================================================================
# 4. FREE TIER USAGE
# =============================================================================

output "free_tier_info" {
  description = "Information about Free Tier usage"
  value = {
    shape           = var.instance_shape
    is_free_tier    = contains(["VM.Standard.E2.1.Micro", "VM.Standard.A1.Flex"], var.instance_shape)
    ocpus_used      = local.free_tier_config.current_ocpus
    memory_used_gb  = local.free_tier_config.current_memory
    storage_used_gb = local.free_tier_config.current_storage
    
    limits = {
      max_amd_instances = local.free_tier_config.max_amd_instances
      max_arm_ocpus     = local.free_tier_config.max_arm_ocpus
      max_arm_memory_gb = local.free_tier_config.max_arm_memory
      max_storage_gb    = local.free_tier_config.max_boot_volume
    }
    
    recommendations = {
      shape   = local.free_tier_config.recommended_shape
      ocpus   = local.free_tier_config.recommended_ocpus
      memory  = local.free_tier_config.recommended_memory
      storage = local.free_tier_config.recommended_storage
    }
  }
}

output "cost_estimate" {
  description = "Cost estimate (should be $0 for Free Tier)"
  value       = contains(["VM.Standard.E2.1.Micro", "VM.Standard.A1.Flex"], var.instance_shape) ? "$0/month (Always Free)" : "Check OCI Cost Estimator"
}

# =============================================================================
# 5. MONITORING & MANAGEMENT
# =============================================================================

output "console_url" {
  description = "OCI Console URL for the instance"
  value       = "https://cloud.oracle.com/compute/instances/${oci_core_instance.vscode_server.id}?region=${var.region}"
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled for the instance"
  value       = var.enable_monitoring
}

output "region" {
  description = "OCI region where resources are deployed"
  value       = var.region
}

output "compartment_id" {
  description = "OCID of the compartment"
  value       = var.compartment_id
}

# =============================================================================
# 6. SECURITY INFORMATION
# =============================================================================

output "security_notes" {
  description = "Security configuration notes"
  value = {
    ssh_access_from    = var.allowed_ssh_cidr
    https_access_from  = var.allowed_https_cidr
    vscode_port        = var.vscode_port
    https_enabled      = var.enable_https
    recommendation     = "For production, restrict allowed_ssh_cidr to your specific IP address"
    nsg_id             = oci_core_network_security_group.nsg.id
  }
}

# =============================================================================
# 7. TAGS AND METADATA
# =============================================================================

output "tags" {
  description = "Tags applied to resources"
  value       = local.common_tags
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

# =============================================================================
# 8. TROUBLESHOOTING
# =============================================================================

output "troubleshooting_commands" {
  description = "Commands for troubleshooting"
  value = [
    "Check cloud-init status: ssh ${var.os_type == "ubuntu" ? "ubuntu" : "opc"}@${oci_core_instance.vscode_server.public_ip} 'sudo cloud-init status'",
    "View cloud-init logs: ssh ${var.os_type == "ubuntu" ? "ubuntu" : "opc"}@${oci_core_instance.vscode_server.public_ip} 'sudo cat /var/log/cloud-init-output.log'",
    "Check VS Code Server: ssh ${var.os_type == "ubuntu" ? "ubuntu" : "opc"}@${oci_core_instance.vscode_server.public_ip} 'sudo systemctl status code-server'",
    "View VS Code logs: ssh ${var.os_type == "ubuntu" ? "ubuntu" : "opc"}@${oci_core_instance.vscode_server.public_ip} 'sudo journalctl -u code-server -f'"
  ]
}
