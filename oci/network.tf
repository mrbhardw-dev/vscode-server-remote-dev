# =============================================================================
# CONSOLIDATED NETWORK CONFIGURATION - REMOTE DEVELOPMENT
# =============================================================================
# Single network configuration supporting both basic and enhanced setups
# =============================================================================

# =============================================================================
# VIRTUAL CLOUD NETWORK (VCN)
# =============================================================================

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  display_name   = local.display_names.vcn
  cidr_blocks    = [local.network_config.vcn_cidr_block]
  dns_label      = "vscodeprod"

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# INTERNET GATEWAY
# =============================================================================
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.resource_prefix}-igw"
  enabled        = true

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# ROUTE TABLE
# =============================================================================
resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.resource_prefix}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# SUBNET
# =============================================================================
resource "oci_core_subnet" "subnet" {
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.vcn.id
  display_name        = "${local.resource_prefix}-subnet"
  cidr_block          = local.network_config.subnet_cidr_block
  dns_label           = "subnet"
  availability_domain = local.availability_domain
  route_table_id      = oci_core_route_table.rt.id

  # Enable public IP assignment for instances
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# NETWORK SECURITY GROUP
# =============================================================================
resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.resource_prefix}-nsg"

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# NSG SECURITY RULES
# =============================================================================
# SSH access rule
resource "oci_core_network_security_group_security_rule" "nsg_ssh" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "SSH access from allowed CIDR"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# HTTP Port for Caddy/Let's Encrypt
resource "oci_core_network_security_group_security_rule" "nsg_http" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP for Let's Encrypt certificate validation"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# HTTPS Port for Caddy
resource "oci_core_network_security_group_security_rule" "nsg_https" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTPS for Caddy/code-server access"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

# VS Code Server port
resource "oci_core_network_security_group_security_rule" "nsg_vscode" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "VS Code Server access"

  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
}

# Outbound traffic rule (allow all)
resource "oci_core_network_security_group_security_rule" "nsg_egress" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all outbound traffic"
}

# =============================================================================
# DATA SOURCES
# =============================================================================
# Find the VNIC attachment for the primary VNIC created with the instance.
data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.vscode_server.id
}

# Find the private IP object associated with the primary VNIC.
# This is required to attach the reserved public IP.
data "oci_core_private_ip" "primary_vnic_private_ip" {
  # The first VNIC attachment is the primary one.
  vnic_id = data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0].vnic_id

  # The IP address is known from the instance resource.
  ip_address = oci_core_instance.vscode_server.private_ip
}