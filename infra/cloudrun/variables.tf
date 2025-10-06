# GCP Project Configuration
variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
  default = "solid-choir-472607-r1"
}

variable "region" {
  description = "The GCP region for the resources."
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The GCP zone for Filestore instance."
  type        = string
  default     = "europe-west4-a"
}

variable "environment" {
  description = "The deployment environment name (e.g., 'dev', 'prod')."
  type        = string
  default     = "dev"
}

# Cloud Run Configuration
variable "service_name" {
  description = "Name of the Cloud Run service."
  type        = string
  default     = "vscode-server-cloudrun"
}

variable "container_image" {
  description = "Container image for VS Code Server."
  type        = string
  default     = "codercom/code-server:latest"
}

variable "vscode_password" {
  description = "Password for VS Code Server authentication (used when GitHub OAuth not configured)."
  type        = string
  default     = "P@ssw0rd@123"
  sensitive   = true
}

# GitHub OAuth Configuration
variable "github_client_id" {
  description = "GitHub OAuth App Client ID (leave empty to use password auth)."
  type        = string
  default     = "Ov23li0eKopVqwBJQHZq"
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub OAuth App Client Secret (leave empty to use password auth)."
  type        = string
  default     = "62e3db27fbb170aabe1bfdab5727813a849abbc5"
  sensitive   = true
}

variable "github_redirect_uri" {
  description = "GitHub OAuth redirect URI (optional, auto-generated if not provided)."
  type        = string
  default     = "https://vscode-server-cloudrun-6xhznsmgzq-ez.a.run.app/login/github/callback"
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run service."
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run service."
  type        = string
  default     = "2Gi"
}

variable "max_instances" {
  description = "Maximum number of instances for Cloud Run service."
  type        = number
  default     = 1
}

# Storage Configuration
variable "temp_storage_size_gb" {
  description = "Temporary in-memory storage size in GB."
  type        = number
  default     = 1
}

# GCS Bucket for backups
variable "backup_bucket_name" {
  description = "Name of the GCS bucket for backups."
  type        = string
  default     = ""
}

variable "enable_backup" {
  description = "Enable automated backups to GCS."
  type        = bool
  default     = false
}