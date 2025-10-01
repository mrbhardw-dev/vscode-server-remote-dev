# =============================================================================
# PROVIDER VERSIONS AND REQUIREMENTS
# =============================================================================
# This file defines the required providers and their version constraints
# for the Terraform configuration.
#
# Benefits of version pinning:
# - Ensures consistent behavior across environments
# - Prevents unexpected updates that might introduce breaking changes
# - Makes the configuration more maintainable
# =============================================================================

terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    # Google Cloud Platform provider
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"  # Last stable version as of knowledge cutoff
    }

    # Google Cloud Platform Beta provider
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.80.0"  # Match stable provider version
    }

    # External data source provider
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.0"
    }

    # Local file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }

    # Null resource for provisioners
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }

  # Backend configuration (uncomment and configure as needed)
  # backend "gcs" {
  #   bucket = "tf-state-bucket-name"
  #   prefix = "vscode-server/state"
  # }
}

# =============================================================================
# PROVIDER CONFIGURATIONS
# =============================================================================

# Google Cloud Platform provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Uncomment and configure if using service account impersonation
  # impersonate_service_account = "service-account@project.iam.gserviceaccount.com"
  
  # Add any additional provider configurations here
  # user_project_override = true
  # billing_project      = var.billing_project_id
}

# Google Cloud Platform Beta provider configuration
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  
  # Match the same configuration as the stable provider
  # impersonate_service_account = "service-account@project.iam.gserviceaccount.com"
}
