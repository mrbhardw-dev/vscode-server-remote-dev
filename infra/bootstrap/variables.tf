variable "project_id" {
  description = "The GCP project ID for bootstrap."
  type        = string
  default = "solid-choir-472607-r1"
}

variable "region" {
  description = "The GCP region for bootstrap resources."
  type        = string
  default     = "europe-west4"
}

variable "github_owner" {
  description = "The GitHub owner for the repository."
  type        = string
  default = "mrbhardw-dev"
}

variable "github_repo" {
  description = "The GitHub repository name."
  type        = string
  default = "vscode-server-remote-dev"
}

variable "workload_project_id" {
  description = "The GCP project ID for the workload."
  type        = string
  default = "solid-choir-472607-r1"
}