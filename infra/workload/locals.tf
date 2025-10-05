# =============================================================================
# GCP - LOCAL VALUES
# =============================================================================
# This file defines local values for consistent naming and configuration.
# =============================================================================

locals {
  # A consistent prefix for all resources
  resource_prefix = "vscode-server-${var.environment}"

  # Common tags to apply to all resources for organization and cost tracking
  common_tags = {
    environment = var.environment
    managed-by  = "terraform"
    purpose     = "vscode-server"
  }


}