# --- 1. Cloud Build Connection (Host) ---
# This resource connects your GCP project to GitHub (the host)
resource "google_cloudbuildv2_connection" "tf_github_connection" {
  project  = var.project_id
  location = var.region
  name     = "github-developer-connect"

  github_config {
    authorizer_credential {
      oauth_token_secret_version = var.github_oauth_token_secret
    }
  }
}

# --- 2. Cloud Build Repository (Link) ---
# This links your specific GitHub repository to the host connection.
# NOTE: The 'remote_uri' must end with .git
resource "google_cloudbuildv2_repository" "tf_workload_repo" {
  project             = var.project_id
  location            = google_cloudbuildv2_connection.tf_github_connection.location
  parent_connection   = google_cloudbuildv2_connection.tf_github_connection.name
  name                = "vscode-server-remote-dev-repo" # A custom name for the linked repo

  # *** FIX FROM PREVIOUS ERROR: Added .git suffix ***
  remote_uri          = "https://github.com/${var.github_owner}/${var.github_repo}.git"
}

# --- 3. Cloud Build Trigger ---
# This trigger is configured to run builds from the new 2nd Gen Repository
resource "google_cloudbuild_trigger" "tf_trigger" {
  project  = var.project_id
  location = google_cloudbuildv2_connection.tf_github_connection.location
  name     = "vscode-server-remote-dev-trigger"

  # Path to your cloudbuild.yaml in the repository root (relative path required)
  filename = var.cloudbuild_config_path
  
  # IMPORTANT: The trigger MUST use the repository_event_config block
  # to reference the 2nd Gen Repository (v2) resource.
  repository_event_config {
    # *** FIX FOR Error 400: Reference the full FCRN of the v2 repository ***
    repository = google_cloudbuildv2_repository.tf_workload_repo.id
    
    # Define the event that triggers the build
    push {
      branch = "main" # Change this regex if needed
    }
  }

  # IMPORTANT: Explicitly setting the service account often resolves generic 400 errors.
  # Ensure this service account is created and has the necessary permissions 
  # (e.g., roles/cloudbuild.builds.builder)
  # service_account = google_service_account.cloudbuild_sa.id # Uncomment if using a custom SA
}

# --- 4. Custom Service Account (Optional but Recommended) ---
# You should have a service account defined for running builds
/*
resource "google_service_account" "cloudbuild_sa" {
  project      = var.project_id
  account_id   = "cloudbuild-worker-sa"
  display_name = "Cloud Build Worker Service Account"
}
*/

# --- 5. Variables (Partial Example) ---
/*
variable "project_id" {
  description = "The ID of the Google Cloud Project"
  type        = string
}

# In your terraform.tfvars or environment variables:
# project_id = "your-gcp-project-id"
*/