# =============================================================================
# GCP - INPUT VARIABLES
# =============================================================================
# This file defines the input variables for the GCP deployment.
# A `terraform.tfvars` file should be created to provide values.
# =============================================================================

# -----------------------------------------------------------------------------
# GCP Project Configuration
# -----------------------------------------------------------------------------
variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The GCP region for the resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for the compute instance."
  type        = string
  default     = "us-central1-a"
}



variable "environment" {
  description = "The deployment environment name (e.g., 'dev', 'prod')."
  type        = string
  default     = "dev"
}

# -----------------------------------------------------------------------------
# Compute Instance Configuration
# -----------------------------------------------------------------------------
variable "machine_type" {
  description = "The machine type for the VS Code server instance."
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_image" {
  description = "The boot disk image for the instance."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

# -----------------------------------------------------------------------------
# VS Code Server Configuration
# -----------------------------------------------------------------------------
variable "code_server_password" {
  description = "Password for code-server"
  type        = string
  default     = "P@ssw0rd@123"
}

variable "code_server_domain" {
  description = "Domain for code-server"
  type        = string
  default     = "vscode.mbtux.com"
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt SSL"
  type        = string
  default     = "mritunjay.bhardwaj@mbtux.com"
}

variable "code_server_user" {
  description = "User to run code-server"
  type        = string
  default     = "codeuser"
}

variable "http_port" {
  description = "Port for code-server"
  type        = number
  default     = 8080
}