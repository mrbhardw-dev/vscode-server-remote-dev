# =============================================================================
# TERRAFORM AND PROVIDER VERSIONS
# =============================================================================
# This file defines the required Terraform version and OCI provider
# configuration for deploying VS Code Server on Oracle Cloud Infrastructure.
#
# OCI Free Tier Resources Used:
# - 2x AMD Compute VMs (Always Free)
# - 1x VCN with Internet Gateway (Always Free)
# - 200 GB Block Storage (Always Free)
# - 10 GB Object Storage (Always Free)
# =============================================================================

terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    # Oracle Cloud Infrastructure provider
    oci = {
      source  = "oracle/oci"
      version = "~> 5.20.0"
    }

    # Template provider for startup scripts
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
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

    # TLS for SSH key generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }

  # Backend configuration (uncomment and configure as needed)
  # backend "s3" {
  #   bucket   = "terraform-state-bucket"
  #   key      = "vscode-server/terraform.tfstate"
  #   region   = "us-phoenix-1"
  #   endpoint = "https://namespace.compat.objectstorage.us-phoenix-1.oraclecloud.com"
  # }
}

# =============================================================================
# PROVIDER CONFIGURATION
# =============================================================================

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
# =============================================================================
# DATA SOURCES
# =============================================================================

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get the latest Oracle Linux image (Always Free eligible)
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Get the latest Ubuntu image (Always Free eligible)
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
