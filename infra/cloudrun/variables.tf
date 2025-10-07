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
  default     = ""
  sensitive   = true
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