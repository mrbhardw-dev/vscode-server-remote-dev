provider "google" {
  project = var.project_id
  region  = var.region
}
import {
  to = google_storage_bucket.workload_state
  id = "tf-state-solid-choir-472607-r1"
}

import {
  to = google_service_account.tf_runner
  id = "projects/solid-choir-472607-r1/serviceAccounts/terraform-runner@solid-choir-472607-r1.iam.gserviceaccount.com"
}

import {
  to = google_secret_manager_secret.tf_sa_key
  id = "projects/solid-choir-472607-r1/secrets/terraform-sa-key"
}


# ------------------------------

# ------------------------------
# GCS Bucket for Workload State
# ------------------------------
resource "google_storage_bucket" "workload_state" {
  name     = "tf-state-${var.workload_project_id}"
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

# ------------------------------
# Service Account for Workload Terraform
# ------------------------------
resource "google_service_account" "tf_runner" {
  account_id   = "terraform-runner"
  display_name = "Terraform Runner for Workload Infra"
}

# Give limited access to workload project
resource "google_project_iam_member" "tf_runner_editor" {
  project = var.workload_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tf_runner.email}"
}

# ------------------------------
# Secret Manager for Storing SA Key
# ------------------------------
resource "google_service_account_key" "tf_runner_key" {
  service_account_id = google_service_account.tf_runner.name
}

resource "google_secret_manager_secret" "tf_sa_key" {
  secret_id = "terraform-sa-key"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "tf_sa_key_version" {
  secret      = google_secret_manager_secret.tf_sa_key.id
  secret_data = base64decode(google_service_account_key.tf_runner_key.private_key)
}

# ------------------------------
# Cloud Build Trigger
# ------------------------------
# Commented out due to invalid argument error - requires proper GitHub connection
# resource "google_cloudbuild_trigger" "tf_trigger" {
#   name        = "terraform-workload-deploy"
#   description = "CI/CD pipeline for workload Terraform"

#   github {
#     owner = var.github_owner
#     name  = var.github_repo
#     push {
#       branch = "^main$"
#     }
#   }

#   filename = "infra/workload/cloudbuild.yaml"

#   included_files = ["infra/workload/**"]
# }