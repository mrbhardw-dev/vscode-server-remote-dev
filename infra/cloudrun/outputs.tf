# Cloud Run service outputs
output "cloud_run_service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.vscode_server.status[0].url
}

output "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_service.vscode_server.name
}

output "cloud_run_service_location" {
  description = "The location of the Cloud Run service"
  value       = google_cloud_run_service.vscode_server.location
}

# Storage outputs
output "storage_type" {
  description = "Type of storage used for persistence"
  value       = "Temporary in-memory (${var.memory_limit} limit)"
}

# Service account output
output "service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = google_service_account.cloud_run_sa.email
}

# GCS bucket output (if enabled)
output "backup_bucket_name" {
  description = "The name of the backup GCS bucket"
  value       = var.enable_backup ? google_storage_bucket.backup_bucket[0].name : null
}

# Access information
output "access_instructions" {
  description = "Instructions for accessing VS Code Server"
  sensitive   = true
  value       = <<EOF
VS Code Server is now deployed on Cloud Run!

Access URL: ${google_cloud_run_service.vscode_server.status[0].url}
Password: ${var.vscode_password}

⚠️  IMPORTANT: This deployment uses temporary in-memory storage.
- Data persists only while the instance is running
- Data will be lost when the instance restarts or scales to zero
- Not suitable for long-term development work

For persistent storage, consider upgrading to Filestore or implementing GCS-based persistence.
EOF
}