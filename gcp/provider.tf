# =============================================================================
# TERRAFORM CONFIGURATION
# =============================================================================
# This file defines the Terraform providers and their configurations
# for managing Google Cloud Platform resources.
#
# Providers:
# - google: Standard GCP provider for most resources
# - google-beta: Beta GCP provider for preview features
# - null: Utility provider for local execution and resource management
# =============================================================================

# -----------------------------------------------------------------------------
# TERRAFORM BLOCK
# -----------------------------------------------------------------------------
# Defines the required providers and their version constraints
# This ensures consistent provider versions across environments
terraform {
  required_providers {
    # Google Cloud Platform provider - stable features
    google = {
      source  = "hashicorp/google"
      version = "~> 7.5" # Use latest 6.x version for stability
    }

    # Google Cloud Platform Beta provider - preview features
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0" # Keep in sync with stable provider
    }

    # Null provider - for local execution and triggers
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0" # Stable version for resource management
    }
  }
}

# -----------------------------------------------------------------------------
# GOOGLE CLOUD PROVIDER - STABLE
# -----------------------------------------------------------------------------
# Primary provider for Google Cloud Platform resources
# Uses service account authentication from credentials file
provider "google" {
  credentials = file(var.credentials_file) # Service account JSON key file
  project     = var.project_id             # Target GCP project
  region      = var.region                 # Default region for resources
}

# -----------------------------------------------------------------------------
# GOOGLE CLOUD PROVIDER - BETA
# -----------------------------------------------------------------------------
# Beta provider for accessing preview features and resources
# Configuration mirrors the stable provider for consistency
provider "google-beta" {
  credentials = file(var.credentials_file) # Same service account as stable provider
  project     = var.project_id             # Same target project
  region      = var.region                 # Same default region
}
