# =============================================================================
# GCP - OUTPUTS
# =============================================================================
# This file defines the output values from the Terraform deployment.
# =============================================================================

output "instance_public_ip" {
  description = "The public IP address of the VS Code Server instance."
  value       = google_compute_address.static_ip.address
}



output "ssh_instructions" {
  description = "Instructions for connecting to the instance via secure IAP SSH."
  value       = <<-EOT
  SSH access is handled securely through GCP's Identity-Aware Proxy (IAP).
  Connect using the gcloud CLI:
  gcloud compute ssh --zone "${var.zone}" "${local.resource_prefix}-instance" --project "${var.project_id}"
  EOT
}

