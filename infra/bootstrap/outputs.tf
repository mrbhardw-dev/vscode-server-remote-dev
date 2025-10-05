output "bucket_name" {
  description = "The name of the GCS bucket for workload Terraform state."
  value       = google_storage_bucket.workload_state.name
}