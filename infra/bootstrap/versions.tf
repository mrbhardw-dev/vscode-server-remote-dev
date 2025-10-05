terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.18.0"
    }
  }
  required_version = ">= 1.5.0"
}

resource "google_project_service_identity" "cloudbuild_identity" {
  provider = google-beta
  project  = var.workload_project_id
  service  = "cloudbuild.googleapis.com"
}