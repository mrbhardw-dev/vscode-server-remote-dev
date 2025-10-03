# =============================================================================
# GCP - OUTPUTS
# =============================================================================
# This file defines the output values from the Terraform deployment.
# =============================================================================

output "instance_public_ip" {
  description = "The public IP address of the VS Code Server instance."
  value       = google_compute_address.static_ip.address
}

output "access_instructions" {
  description = "Instructions to access the VS Code Server."
  value       = <<-EOT
  VS Code Server is being installed. It may take 5-10 minutes to become available.

  1. DNS Setup: Point your domain's A record ('${var.code_server_domain}') to the public IP: ${google_compute_address.static_ip.address}
  2. Access your VS Code Server at: https://${var.code_server_domain}
  3. Login with the password you provided in your .tfvars file.
  EOT
}

output "ssh_instructions" {
  description = "Instructions for connecting to the instance via secure IAP SSH."
  value       = <<-EOT
  SSH access is handled securely through GCP's Identity-Aware Proxy (IAP).
  Connect using the gcloud CLI:
  gcloud compute ssh --zone "${var.zone}" "${local.resource_prefix}-instance" --project "${var.project_id}"
  EOT
}