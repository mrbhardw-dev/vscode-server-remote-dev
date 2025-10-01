# =============================================================================
# LOCAL VALUES - ORACLE CLOUD INFRASTRUCTURE
# =============================================================================
# This file defines local values for the OCI VS Code Server deployment.
# Optimized for OCI Always Free Tier resources.
#
# Organization:
# 1. Core Configuration
# 2. Naming & Labels
# 3. Network Configuration
# 4. Compute Configuration
# 5. Security Configuration
# =============================================================================

# =============================================================================
# 1. CORE CONFIGURATION
# =============================================================================

locals {
  # Base configuration
  region      = var.region
  environment = var.environment
  name_prefix = var.project_name
  
  # Timestamp for unique resource naming
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
  
  # Availability domain
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_number - 1].name
  
  # Common freeform tags for all resources
  common_tags = merge(
    {
      "Project"     = var.project_name
      "Environment" = var.environment
      "ManagedBy"   = "Terraform"
      "CreatedBy"   = "Terraform"
      "Application" = "vscode-server"
      "Tier"        = "Free"
    },
    var.freeform_tags
  )
}

# =============================================================================
# 2. NAMING & LABELS
# =============================================================================

locals {
  # Resource prefix for consistent naming
  resource_prefix = "${local.name_prefix}-${local.environment}"
  
  # Standardized resource names
  resource_names = {
    vcn                = "${local.resource_prefix}-vcn"
    subnet             = "${local.resource_prefix}-subnet"
    internet_gateway   = "${local.resource_prefix}-igw"
    route_table        = "${local.resource_prefix}-rt"
    security_list      = "${local.resource_prefix}-sl"
    instance           = "${local.resource_prefix}-vm"
    boot_volume        = "${local.resource_prefix}-boot"
    public_ip          = "${local.resource_prefix}-ip"
  }
  
  # Display names with environment
  display_names = {
    vcn      = "VS Code Server VCN (${local.environment})"
    subnet   = "VS Code Server Subnet (${local.environment})"
    instance = "VS Code Server Instance (${local.environment})"
  }
}

# =============================================================================
# 3. NETWORK CONFIGURATION
# =============================================================================

locals {
  # Network configuration
  vcn_cidr    = var.vcn_cidr_block
  subnet_cidr = var.subnet_cidr_block
  
  # DNS configuration
  vcn_dns_label    = replace(local.resource_prefix, "-", "")
  subnet_dns_label = "subnet${local.environment}"
  
  # Security list rules
  ingress_rules = {
    ssh = {
      protocol    = "6"  # TCP
      source      = var.allowed_ssh_cidr
      source_type = "CIDR_BLOCK"
      tcp_options = {
        min = 22
        max = 22
      }
      description = "Allow SSH access"
    }
    http = {
      protocol    = "6"  # TCP
      source      = var.allowed_https_cidr
      source_type = "CIDR_BLOCK"
      tcp_options = {
        min = 80
        max = 80
      }
      description = "Allow HTTP access"
    }
    https = {
      protocol    = "6"  # TCP
      source      = var.allowed_https_cidr
      source_type = "CIDR_BLOCK"
      tcp_options = {
        min = 443
        max = 443
      }
      description = "Allow HTTPS access"
    }
    vscode = {
      protocol    = "6"  # TCP
      source      = var.allowed_https_cidr
      source_type = "CIDR_BLOCK"
      tcp_options = {
        min = var.vscode_port
        max = var.vscode_port
      }
      description = "Allow VS Code Server access"
    }
  }
  
  egress_rules = {
    all = {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    }
  }
}

# =============================================================================
# 4. COMPUTE CONFIGURATION
# =============================================================================

locals {
  # Instance configuration
  instance_config = {
    shape       = var.instance_shape
    display_name = local.resource_names.instance
    
    # Shape configuration for Flex shapes
    shape_config = var.instance_shape == "VM.Standard.A1.Flex" ? {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_in_gbs
    } : null
    
    # Source details
    source_details = {
      source_type             = "image"
      boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
      image_id                = var.os_type == "ubuntu" ? data.oci_core_images.ubuntu.images[0].id : data.oci_core_images.oracle_linux.images[0].id
    }
    
    # Metadata
    metadata = {
      ssh_authorized_keys = file(var.ssh_public_key_path)
      user_data          = base64encode(local.cloud_init_script)
    }
  }
  
  # Cloud-init script for VS Code Server installation
  cloud_init_script = templatefile("${path.module}/scripts/cloud-init.yaml", {
    vscode_password = var.vscode_password
    vscode_port     = var.vscode_port
    enable_https    = var.enable_https
  })
}

# =============================================================================
# 5. SECURITY CONFIGURATION
# =============================================================================

locals {
  # SSH configuration
  ssh_public_key = fileexists(var.ssh_public_key_path) ? file(var.ssh_public_key_path) : ""
  
  # Firewall ports
  allowed_ports = {
    ssh    = 22
    http   = 80
    https  = 443
    vscode = var.vscode_port
  }
  
  # Security recommendations
  security_notes = {
    ssh_access    = "SSH access is allowed from: ${var.allowed_ssh_cidr}"
    https_access  = "HTTPS access is allowed from: ${var.allowed_https_cidr}"
    vscode_port   = "VS Code Server will run on port: ${var.vscode_port}"
    recommendation = "For production, restrict allowed_ssh_cidr to your specific IP address"
  }
}

# =============================================================================
# 6. FREE TIER CONFIGURATION
# =============================================================================

locals {
  # Free Tier limits and recommendations
  free_tier_config = {
    # Always Free Compute
    max_amd_instances = 2  # VM.Standard.E2.1.Micro
    max_arm_ocpus     = 4  # VM.Standard.A1.Flex
    max_arm_memory    = 24 # GB for VM.Standard.A1.Flex
    
    # Always Free Storage
    max_boot_volume   = 200 # GB total across all instances
    max_block_storage = 200 # GB total
    
    # Current usage
    current_ocpus  = var.instance_shape == "VM.Standard.A1.Flex" ? var.instance_ocpus : 1
    current_memory = var.instance_shape == "VM.Standard.A1.Flex" ? var.instance_memory_in_gbs : 1
    current_storage = var.boot_volume_size_in_gbs
    
    # Recommendations
    recommended_shape = "VM.Standard.A1.Flex"
    recommended_ocpus = 2
    recommended_memory = 12
    recommended_storage = 100
  }
  
  # Cost optimization notes
  cost_notes = {
    shape   = var.instance_shape == "VM.Standard.A1.Flex" ? "Using ARM-based Always Free instance (recommended)" : "Using AMD-based Always Free instance"
    storage = var.boot_volume_size_in_gbs <= 100 ? "Storage within recommended limits" : "Storage usage is high but within Free Tier limits"
    network = "Network egress up to 10 TB/month is Always Free"
  }
}
