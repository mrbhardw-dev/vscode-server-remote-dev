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
  default="solid-choir-472607-r1"
}

variable "region" {
  description = "The GCP region for the resources."
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The GCP zone for the compute instance."
  type        = string
  default     = "europe-west4-a"
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
  default     = "e2-medium"
}

variable "boot_disk_image" {
  description = "The boot disk image for the instance."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

