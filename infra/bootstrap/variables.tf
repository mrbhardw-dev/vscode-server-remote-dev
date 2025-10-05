variable "project_id" {
  description = "The GCP project ID for bootstrap."
  type        = string
  default     = "solid-choir-472607-r1"
}

variable "region" {
  description = "The GCP region for bootstrap resources."
  type        = string
  default     = "europe-west4"
}

variable "github_owner" {
  description = "The GitHub owner for the repository."
  type        = string
  default     = "mrbhardw-dev"
}

variable "github_repo" {
  description = "The GitHub repository name."
  type        = string
  default     = "vscode-server-remote-dev"
}

variable "workload_project_id" {
  description = "The GCP project ID for the workload."
  type        = string
  default     = "solid-choir-472607-r1"
}

variable "cloudbuild_config_path" {
  description = "Relative path to the Cloud Build configuration file in the repository (e.g., 'infra/workload/cloudbuild.yaml')."
  type        = string
  default     = "infra/workload/cloudbuild.yaml"

  validation {
    condition     = !startswith(var.cloudbuild_config_path, "/") && (endswith(var.cloudbuild_config_path, ".yaml") || endswith(var.cloudbuild_config_path, ".yml"))
    error_message = "The cloudbuild_config_path must be a relative path (no leading '/') and end with '.yaml' or '.yml'."
  }
}

variable "github_oauth_token_secret" {
  description = "Secret version for GitHub OAuth token (e.g., projects/project/secrets/github-token/versions/latest). Required for Cloud Build connection."
  type        = string
  default     = ""
}
