# Cloud Build Connection - Connects GCP project to GitHub
resource "google_cloudbuildv2_connection" "tf_github_connection" {
  project  = var.project_id
  location = var.region
  name     = "github-developer-connect"

  github_config {
    app_installation_id = 86612216
    authorizer_credential {
      oauth_token_secret_version = "projects/solid-choir-472607-r1/secrets/github-developer-connect-github-oauthtoken-2b8ff0/versions/latest"
    }
  }
}

# Cloud Build Repository - Links GitHub repository to the connection
resource "google_cloudbuildv2_repository" "tf_workload_repo" {
  project           = var.project_id
  location          = google_cloudbuildv2_connection.tf_github_connection.location
  parent_connection = google_cloudbuildv2_connection.tf_github_connection.name
  name              = "mrbhardw-dev-vscode-server-remote-dev"
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
}

# Cloud Build Trigger - Runs builds on repository push events
resource "google_cloudbuild_trigger" "tf_trigger" {
  project  = var.project_id
  location = google_cloudbuildv2_connection.tf_github_connection.location
  name     = "vscode-server-remote-dev-trigger"
  filename = var.cloudbuild_config_path

  repository_event_config {
    repository = google_cloudbuildv2_repository.tf_workload_repo.id
    push {
      branch = "^master$"
    }
  }

  service_account = "projects/solid-choir-472607-r1/serviceAccounts/mrbhardw-dev-terraform-sa@solid-choir-472607-r1.iam.gserviceaccount.com"
}

# Cloud Build Service Identity - Required for Cloud Build operations
resource "google_project_service_identity" "cloudbuild_identity" {
  provider = google-beta
  project  = var.workload_project_id
  service  = "cloudbuild.googleapis.com"
}