locals {
  container_image = var.container_image
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "cloudbuild_api" {
  service = "cloudbuild.googleapis.com"
}

# Cloud Run Service Account
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for VS Code Server Cloud Run"
}

# Cloud Run Service
resource "google_cloud_run_service" "vscode_server" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email

      containers {
        image = local.container_image

        ports {
          container_port = 8080
        }

        env {
          name  = "PASSWORD"
          value = var.vscode_password
        }

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cpu-throttling"        = "false"
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/maxScale"              = var.max_instances
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.cloud_run_api]
}

# GCS Bucket for backups (conditional on enable_backup)
resource "google_storage_bucket" "backup_bucket" {
  count         = var.enable_backup ? 1 : 0
  name          = var.backup_bucket_name != "" ? var.backup_bucket_name : "${var.service_name}-backups-${var.project_id}"
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }
}

# Allow public HTTP (Cloudflare Access will protect externally)
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.vscode_server.name
  location = google_cloud_run_service.vscode_server.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
