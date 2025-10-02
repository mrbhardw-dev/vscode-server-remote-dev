# =============================================================================
# OUTPUT VALUES
# =============================================================================
# This file defines output values that are shown after successful deployment.
# Outputs provide important information about created resources for external
# access and resource management.
#
# Organization:
# 1. Core Information
# 2. Network Information
# 3. Compute Information
# 4. Security Information
# 5. Access Information
# =============================================================================

# =============================================================================
# 1. CORE INFORMATION
# =============================================================================

output "project_id" {
  description = "The GCP project ID where resources are deployed"
  value       = var.project_id
}

output "region" {
  description = "The GCP region where resources are deployed"
  value       = var.region
}

output "environment" {
  description = "The deployment environment (e.g., development, staging, production)"
  value       = var.environment
}

# =============================================================================
# 2. NETWORK INFORMATION
# =============================================================================

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.network.network_name
  sensitive   = false
}

output "vpc_network_self_link" {
  description = "The URI of the VPC network"
  value       = module.network.network_self_link
}

output "subnets" {
  description = "A map of subnet information"
  value = {
    names       = module.network.subnets_names
    cidr_blocks = module.network.subnets_ips
    self_links  = module.network.subnets_self_links
    regions     = [for s in module.network.subnets : s.region]
  }
}

output "firewall_rules" {
  description = "List of created firewall rules"
  value = [
    {
      name          = google_compute_firewall.allow_ssh_iap.name
      direction     = "INGRESS"
      source_ranges = google_compute_firewall.allow_ssh_iap.source_ranges
      target_tags   = google_compute_firewall.allow_ssh_iap.target_tags
    },
    {
      name          = google_compute_firewall.allow_http.name
      direction     = "INGRESS"
      source_ranges = google_compute_firewall.allow_http.source_ranges
      target_tags   = google_compute_firewall.allow_http.target_tags
    },
    {
      name          = google_compute_firewall.allow_https.name
      direction     = "INGRESS"
      source_ranges = google_compute_firewall.allow_https.source_ranges
      target_tags   = google_compute_firewall.allow_https.target_tags
    }
  ]
}

# =============================================================================
# 3. COMPUTE INFORMATION
# =============================================================================

output "instance_names" {
  description = "List of created instance names"
  value       = google_compute_instance.vscode_server[*].name
}

output "instance_self_links" {
  description = "List of instance self-links"
  value       = google_compute_instance.vscode_server[*].self_link
}

output "instance_ips" {
  description = "List of instance IP addresses"
  value = {
    internal = google_compute_instance.vscode_server[*].network_interface[0].network_ip
    external = google_compute_instance.vscode_server[*].network_interface[0].access_config[0].nat_ip
  }
}

output "service_account" {
  description = "Service account details used by the instances"
  value = {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }
  sensitive = true
}

# =============================================================================
# 4. SECURITY INFORMATION
# =============================================================================

output "security_groups" {
  description = "Security group IDs and names"
  value = {
    ssh   = google_compute_firewall.allow_ssh_iap.id
    http  = google_compute_firewall.allow_http.id
    https = google_compute_firewall.allow_https.id
  }
}

# =============================================================================
# 5. ACCESS INFORMATION
# =============================================================================

output "access_instructions" {
  description = "Instructions for accessing the VS Code Server"
  value = var.vscode_domain != "" ? [
    "VS Code Server will be available at: https://${var.vscode_domain}",
    "Initial password: ${var.vscode_password}",
    "SSH Access: gcloud compute ssh ${local.name_prefix}-0 --zone ${var.zone} --project ${var.project_id}"
  ] : ["VS Code Server domain not configured"]
  sensitive = true
}

output "monitoring_links" {
  description = "Links to monitoring dashboards"
  value = var.enable_monitoring ? [
    "Cloud Monitoring: https://console.cloud.google.com/monitoring?project=${var.project_id}",
    "Logs Explorer: https://console.cloud.google.com/logs/query?project=${var.project_id}"
  ] : ["Monitoring is disabled"]
}

# =============================================================================
# 6. LABELS AND TAGS
# =============================================================================

output "labels" {
  description = "Standardized labels applied to all resources"
  value       = local.common_labels
}

# =============================================================================
# 7. DEPLOYMENT INFORMATION
# =============================================================================

output "deployment_timestamp" {
  description = "The timestamp when the deployment was completed"
  value       = timestamp()
}

output "terraform_version" {
  description = "The Terraform version used for the deployment"
  value       = terraform.workspace
}

output "module_versions" {
  description = "Versions of the main modules used in this deployment"
  value = {
    network = "12.0.0"
    compute = "13.0.0"
    labels  = "1.0.0"
  }
}

# VS Code Server instance information
output "vscode_instance_name" {
  description = "Name of the VS Code Server compute instance"
  value       = google_compute_instance.vscode_server[0].name
}

output "vscode_external_ip" {
  description = "External IP address of the VS Code Server instance"
  value       = google_compute_instance.vscode_server[0].network_interface[0].access_config[0].nat_ip
}

output "vscode_internal_ip" {
  description = "Internal IP address of the VS Code Server instance"
  value       = google_compute_instance.vscode_server[0].network_interface[0].network_ip
}

# -----------------------------------------------------------------------------
# VS CODE SERVER ACCESS INFORMATION
# -----------------------------------------------------------------------------

output "vscode_access_info" {
  description = "VS Code Server access information"
  value = {
    domain_url = "https://${local.vscode_config.domain}"
    http_url   = "http://${google_compute_instance.vscode_server[0].network_interface[0].access_config[0].nat_ip}:80"
    https_url  = "https://${google_compute_instance.vscode_server[0].network_interface[0].access_config[0].nat_ip}:443"
    password   = "Check terraform.tfvars for configured password"
  }
}

# -----------------------------------------------------------------------------
# SSH ACCESS INFORMATION
# -----------------------------------------------------------------------------

output "ssh_command" {
  description = "gcloud command to SSH into the VS Code Server instance"
  value       = "gcloud compute ssh ${google_compute_instance.vscode_server[0].name} --zone=${google_compute_instance.vscode_server[0].zone} --tunnel-through-iap"
}
