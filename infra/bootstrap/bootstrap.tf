# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# GCS Bucket for Workload Terraform State
resource "google_storage_bucket" "workload_state" {
  name     = "tf-state-${var.project_id}"
  location = var.region

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

