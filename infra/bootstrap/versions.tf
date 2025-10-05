terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.18.0"
    }
  }
  required_version = ">= 1.5.0"
}