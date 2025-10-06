# Locals for computed values
locals {
  container_image = var.container_image
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}



resource "google_project_service" "cloudbuild_api" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# Cloud Storage bucket for persistent storage (cost-effective alternative to Filestore)
resource "google_storage_bucket" "vscode_storage" {
  name          = "${var.project_id}-vscode-storage"
  location      = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for VS Code Server Cloud Run"
}


# Cloud Run service
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

        dynamic "env" {
          for_each = var.github_client_id != "" ? [1] : []
          content {
            name  = "GITHUB_CLIENT_ID"
            value = var.github_client_id
          }
        }

        dynamic "env" {
          for_each = var.github_client_secret != "" ? [1] : []
          content {
            name  = "GITHUB_CLIENT_SECRET"
            value = var.github_client_secret
          }
        }

        dynamic "env" {
          for_each = var.github_redirect_uri != "" ? [1] : []
          content {
            name  = "GITHUB_REDIRECT_URI"
            value = var.github_redirect_uri
          }
        }

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

        volume_mounts {
          name       = "vscode-data"
          mount_path = "/home/coder"
        }
      }

      volumes {
        name = "vscode-data"
        empty_dir {
          medium = "Memory"
          size_limit = "${var.temp_storage_size_gb}Gi"
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cpu-throttling" = "false"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_run_api
  ]
}

# IAM policy to allow public access
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.vscode_server.name
  location = google_cloud_run_service.vscode_server.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# GCS bucket for backups (optional)
resource "google_storage_bucket" "backup_bucket" {
  count         = var.enable_backup ? 1 : 0
  name          = var.backup_bucket_name != "" ? var.backup_bucket_name : "${var.project_id}-vscode-backup"
  location      = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Cloud Build trigger for automated builds (optional - configure GitHub repo first)
# resource "google_cloudbuild_trigger" "docker_build" {
#   name        = "${var.service_name}-build"
#   description = "Build VS Code Server Docker image"
#
#   github {
#     owner = "your-github-org"  # Replace with your GitHub org
#     name  = "vscode-server-cloudrun"
#     push {
#       branch = "^main$"
#     }
#   }
#
#   build {
#     step {
#       name = "gcr.io/cloud-builders/docker"
#       args = [
#         "build",
#         "-t",
#         "gcr.io/${var.project_id}/${var.service_name}:$COMMIT_SHA",
#         "-t",
#         "gcr.io/${var.project_id}/${var.service_name}:latest",
#         "."
#       ]
#     }
#
#     step {
#       name = "gcr.io/cloud-builders/docker"
#       args = [
#         "push",
#         "gcr.io/${var.project_id}/${var.service_name}:latest"
#       ]
#     }
#
#     step {
#       name = "gcr.io/google.com/cloudsdktool/cloud-sdk"
#       args = [
#         "run",
#         "deploy",
#         var.service_name,
#         "--image",
#         "gcr.io/${var.project_id}/${var.service_name}:latest",
#         "--region",
#         var.region,
#         "--platform",
#         "managed",
#         "--allow-unauthenticated"
#       ]
#     }
#   }
#
#   depends_on = [google_project_service.cloudbuild_api]
# }