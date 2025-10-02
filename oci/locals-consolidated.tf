# =============================================================================
# CONSOLIDATED LOCALS - VS CODE REMOTE DEVELOPMENT
# =============================================================================
# Single consolidated locals file combining all local values
# =============================================================================

locals {
  # =============================================================================
  # BASIC NAMING AND TAGGING
  # =============================================================================
  
  resource_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
    "Purpose"     = "RemoteDevelopment"
  }

  # =============================================================================
  # AVAILABILITY DOMAIN SELECTION
  # =============================================================================
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  # =============================================================================
  # IMAGE SELECTION
  # =============================================================================
  
  selected_image_id = var.os_type == "ubuntu" ? data.oci_core_images.ubuntu.images[0].id : data.oci_core_images.oracle_linux.images[0].id

  # =============================================================================
  # SSH PUBLIC KEY HANDLING
  # =============================================================================
  
  ssh_public_key_content = var.ssh_public_key_path != null ? (
    fileexists(pathexpand(var.ssh_public_key_path)) ? file(pathexpand(var.ssh_public_key_path)) : var.ssh_public_key_path
  ) : ""

  # =============================================================================
  # RESOURCE NAMES
  # =============================================================================
  
  resource_names = {
    instance        = "${local.resource_prefix}-instance"
    workspace       = "${local.resource_prefix}-workspace"
    vcn            = "${local.resource_prefix}-vcn"
    subnet         = "${local.resource_prefix}-subnet"
    igw            = "${local.resource_prefix}-igw"
    route_table    = "${local.resource_prefix}-rt"
    security_list  = "${local.resource_prefix}-sl"
    nsg            = "${local.resource_prefix}-nsg"
    reserved_ip    = "${local.resource_prefix}-ip"
  }

  # Display names for resources
  display_names = {
    instance       = "VS Code Remote Dev Instance (${var.environment})"
    workspace      = "Persistent Workspace Volume (${var.environment})"
    vcn           = "VS Code Remote Dev VCN (${var.environment})"
    subnet        = "VS Code Remote Dev Subnet (${var.environment})"
    igw           = "${local.resource_prefix}-igw"
    route_table   = "${local.resource_prefix}-rt"
    security_list = "${local.resource_prefix}-sl"
    nsg           = "${local.resource_prefix}-nsg"
    reserved_ip   = "${local.resource_prefix}-reserved-ip"
  }

  # =============================================================================
  # NETWORK CONFIGURATION
  # =============================================================================
  
  network_config = {
    vcn_cidr_block    = var.vcn_cidr_block
    subnet_cidr_block = var.subnet_cidr_block
    
    # Security rules
    ssh_source_cidr     = var.allowed_ssh_cidr
    dev_access_cidr     = var.allowed_dev_access_cidr
    dev_ports          = var.dev_server_ports
  }

  # =============================================================================
  # INSTANCE CONFIGURATION
  # =============================================================================
  
  instance_config = {
    shape                = var.instance_shape
    image_id            = local.selected_image_id
    boot_volume_size    = var.boot_volume_size_in_gbs
    
    # Shape configuration for Flex instances
    shape_config = contains(["VM.Standard.A1.Flex"], var.instance_shape) ? {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_in_gbs
    } : null

    # Source details
    source_details = {
      source_type             = "image"
      image_id               = local.selected_image_id
      boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    }
    
    # Metadata for cloud-init and SSH
    metadata = {
      ssh_authorized_keys = local.ssh_public_key_content
      user_data          = base64encode(templatefile("${path.module}/scripts/cloud-init-remote-dev.yaml", local.cloud_init_vars))
    }
    
    # Feature flags
    use_reserved_ip     = var.use_reserved_ip
    enable_monitoring   = var.enable_monitoring
    enable_backup       = var.enable_workspace_backup
  }

  # =============================================================================
  # CLOUD-INIT TEMPLATE VARIABLES
  # =============================================================================
  
  cloud_init_vars = {
    # SSH Configuration
    ssh_port       = var.ssh_port
    ssh_public_key = local.ssh_public_key_content
    
    # Development Tools Versions
    nodejs_version = var.nodejs_version
    python_version = var.python_version
    go_version    = var.go_version
    java_version  = var.java_version
    
    # User Configuration
    dev_username  = var.dev_username
    git_username  = var.git_username
    git_email     = var.git_email
    
    # VS Code Configuration
    vscode_password = var.vscode_password
    vscode_web_port = var.vscode_web_port
    
    # Feature Flags
    install_docker      = var.install_docker
    install_code_server = var.install_code_server
    setup_zsh          = var.setup_zsh
    install_cloud_tools = var.install_cloud_tools
    enable_firewall    = var.enable_firewall
    enable_vscode_web  = var.enable_vscode_web
    
    # Workspace Configuration
    workspace_path = "/workspace"
    
    # Development ports for firewall configuration
    dev_ports = join(" ", [for port in var.dev_server_ports : tostring(port)])
  }

  # =============================================================================
  # DEVELOPMENT ENVIRONMENT SUMMARY
  # =============================================================================
  
  dev_environment = {
    # Programming languages and versions
    languages = {
      nodejs  = var.nodejs_version
      python  = var.python_version
      go      = var.go_version
      java    = var.java_version
      rust    = "latest"
    }
    
    # Development tools
    tools = {
      docker      = var.install_docker
      code_server = var.install_code_server
      zsh         = var.setup_zsh
      cloud_tools = var.install_cloud_tools
    }
    
    # User and security
    security = {
      dev_username           = var.dev_username
      ssh_port              = var.ssh_port
      disable_password_auth = var.disable_password_auth
      enable_firewall       = var.enable_firewall
      allowed_ssh_cidr      = var.allowed_ssh_cidr
    }
    
    # VS Code configuration
    vscode = {
      web_enabled = var.enable_vscode_web
      web_port   = var.vscode_web_port
      password   = var.vscode_password
    }
    
    # Development server ports
    dev_ports = var.dev_server_ports
  }

  # =============================================================================
  # ACCESS INFORMATION FOR OUTPUTS
  # =============================================================================
  
  access_info = {
    ssh_user    = var.dev_username
    ssh_port    = var.ssh_port
    workspace   = "/workspace"
    
    # SSH command template (IP will be filled in outputs)
    ssh_command_template = "ssh ${var.ssh_port != 22 ? "-p ${var.ssh_port} " : ""}${var.dev_username}@"
    
    # VS Code Remote Development instructions
    vscode_instructions = [
      "1. Install 'Remote - SSH' extension in VS Code",
      "2. Add SSH host configuration",
      "3. Connect via SSH and open /workspace folder",
      "4. Start developing with full remote environment!"
    ]
    
    # Available development tools
    installed_tools = compact([
      "Docker & Docker Compose",
      "Node.js ${var.nodejs_version}",
      "Python ${var.python_version}",
      "Go ${var.go_version}",
      "Java ${var.java_version}",
      "Rust (latest stable)",
      "Git with enhanced configuration",
      var.setup_zsh ? "Zsh with Oh My Zsh" : "Bash shell",
      var.install_cloud_tools ? "Cloud CLI tools (kubectl, terraform)" : null,
      var.install_code_server ? "VS Code Server (web interface)" : null
    ])
  }

  # =============================================================================
  # RESOURCE USAGE SUMMARY (FOR COST TRACKING)
  # =============================================================================
  
  resource_usage = {
    compute = {
      shape      = var.instance_shape
      ocpus      = var.instance_ocpus
      memory_gb  = var.instance_memory_in_gbs
    }
    
    storage = {
      boot_volume_gb      = var.boot_volume_size_in_gbs
      workspace_volume_gb = var.workspace_volume_size_in_gbs
      total_storage_gb    = var.boot_volume_size_in_gbs + var.workspace_volume_size_in_gbs
    }
    
    network = {
      vcn_count          = 1
      subnet_count       = 1
      igw_count         = 1
      reserved_ip_count = var.use_reserved_ip ? 1 : 0
    }
    
    # Always Free tier limits
    free_tier_limits = {
      max_arm_ocpus    = 4
      max_arm_memory   = 24
      max_storage_gb   = 200
      max_amd_instances = 2
    }
    
    # Usage against limits
    usage_summary = {
      ocpus_used      = var.instance_ocpus
      memory_used     = var.instance_memory_in_gbs
      storage_used    = var.boot_volume_size_in_gbs + var.workspace_volume_size_in_gbs
      within_free_tier = (
        var.instance_ocpus <= 4 &&
        var.instance_memory_in_gbs <= 24 &&
        (var.boot_volume_size_in_gbs + var.workspace_volume_size_in_gbs) <= 200
      )
    }
  }
}