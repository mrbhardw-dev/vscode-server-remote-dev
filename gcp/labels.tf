# =============================================================================
# RESOURCE LABELING MODULE
# =============================================================================
# This module provides standardized naming and labeling for all GCP resources.
# It uses the eazycloudlife/labels/gcp module to ensure consistency across
# all resources in the infrastructure.
#
# Features:
# - Standardized naming conventions
# - Consistent resource tagging
# - Organizational metadata
# - Resource identification and management
# =============================================================================

# -----------------------------------------------------------------------------
# LABELS MODULE CONFIGURATION
# -----------------------------------------------------------------------------
module "labels" {
  source  = "eazycloudlife/labels/gcp"
  version = "~> 1.0"  # Use compatible version with patch updates

  # -----------------------------------------------------------------------------
  # CORE NAMING CONFIGURATION
  # -----------------------------------------------------------------------------
  name        = local.name_prefix
  environment = local.environment
  
  # Define the order of elements in generated resource names
  # Format: {name}-{environment}-{attributes}
  label_order = ["name", "environment"]

  # -----------------------------------------------------------------------------
  # ORGANIZATIONAL METADATA
  # -----------------------------------------------------------------------------
  business_unit = "Engineering"
  managed_by    = var.managed_by
  
  # Additional attributes (region code, etc.)
  attributes = [
    replace(local.region, "-", ""),  # e.g., "europewest2"
    "${var.environment}-env"
  ]

  # -----------------------------------------------------------------------------
  # TAGS AND LABELS
  # -----------------------------------------------------------------------------
  # Merge common labels with any additional tags
  extra_tags = merge(
    local.common_labels,
    {
      # Application-specific identifier
      application = "vscode-server"
      
      # Cost allocation
      cost-center = "dev-tools"
      
      # Compliance
      compliance = "internal"
      
      # Automation
      managed-by   = "terraform"
      repo         = "https://github.com/your-org/vscode-server-gcp"
      terraform    = "true"
    },
    var.additional_tags
  )
}

# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------
# These outputs can be used by other modules to ensure consistent naming

# Standardized ID for resources
output "id" {
  description = "The standardized ID for resources"
  value       = module.labels.id
}

# Standardized name for resources
output "name" {
  description = "The standardized name for resources"
  value       = module.labels.name
}

# Standardized name with environment for resources
output "name_with_env" {
  description = "The standardized name with environment for resources"
  value       = module.labels.name_with_env
}

# Standardized tags for resources
output "tags" {
  description = "The standardized tags for resources"
  value       = module.labels.tags
}

# Standardized context for resources
output "context" {
  description = "Context of the label module containing all standard label values"
  value       = module.labels.context
}