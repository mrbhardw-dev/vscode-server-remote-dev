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

  # Template variables for the startup script
  startup_script_vars = {
    CODE_SERVER_USER     = var.code_server_user
    CODE_SERVER_PASSWORD = var.code_server_password
    CODE_SERVER_DOMAIN   = var.code_server_domain
    LETSENCRYPT_EMAIL    = var.letsencrypt_email
    HTTP_PORT            = var.http_port
  }
}