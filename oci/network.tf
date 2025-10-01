# =============================================================================
# NETWORK INFRASTRUCTURE - ORACLE CLOUD
# =============================================================================
# This file defines the Virtual Cloud Network (VCN) and related networking
# resources for the VS Code Server deployment on OCI.
#
# Resources Created (All Always Free):
# - Virtual Cloud Network (VCN)
# - Internet Gateway
# - Route Table
# - Security List
# - Public Subnet
# =============================================================================

# =============================================================================
# VIRTUAL CLOUD NETWORK (VCN)
# =============================================================================

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  display_name   = local.display_names.vcn
  dns_label      = local.vcn_dns_label
  cidr_blocks    = [local.vcn_cidr]

  freeform_tags = merge(
    local.common_tags,
    {
      "Name" = local.resource_names.vcn
      "Type" = "VCN"
    }
  )
  defined_tags = var.defined_tags
}

# =============================================================================
# INTERNET GATEWAY
# =============================================================================

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = local.resource_names.internet_gateway
  enabled        = true

  freeform_tags = merge(
    local.common_tags,
    {
      "Name" = local.resource_names.internet_gateway
      "Type" = "InternetGateway"
    }
  )
  defined_tags = var.defined_tags
}

# =============================================================================
# ROUTE TABLE
# =============================================================================

resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = local.resource_names.route_table

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
    description       = "Route all traffic to Internet Gateway"
  }

  freeform_tags = merge(
    local.common_tags,
    {
      "Name" = local.resource_names.route_table
      "Type" = "RouteTable"
    }
  )
  defined_tags = var.defined_tags
}

# =============================================================================
# SECURITY LIST
# =============================================================================

resource "oci_core_security_list" "sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = local.resource_names.security_list

  # Ingress Rules
  # SSH Access
  ingress_security_rules {
    protocol    = local.ingress_rules.ssh.protocol
    source      = local.ingress_rules.ssh.source
    source_type = local.ingress_rules.ssh.source_type
    description = local.ingress_rules.ssh.description

    tcp_options {
      min = local.ingress_rules.ssh.tcp_options.min
      max = local.ingress_rules.ssh.tcp_options.max
    }
  }

  # HTTP Access
  ingress_security_rules {
    protocol    = local.ingress_rules.http.protocol
    source      = local.ingress_rules.http.source
    source_type = local.ingress_rules.http.source_type
    description = local.ingress_rules.http.description

    tcp_options {
      min = local.ingress_rules.http.tcp_options.min
      max = local.ingress_rules.http.tcp_options.max
    }
  }

  # HTTPS Access
  ingress_security_rules {
    protocol    = local.ingress_rules.https.protocol
    source      = local.ingress_rules.https.source
    source_type = local.ingress_rules.https.source_type
    description = local.ingress_rules.https.description

    tcp_options {
      min = local.ingress_rules.https.tcp_options.min
      max = local.ingress_rules.https.tcp_options.max
    }
  }

  # VS Code Server Access
  ingress_security_rules {
    protocol    = local.ingress_rules.vscode.protocol
    source      = local.ingress_rules.vscode.source
    source_type = local.ingress_rules.vscode.source_type
    description = local.ingress_rules.vscode.description

    tcp_options {
      min = local.ingress_rules.vscode.tcp_options.min
      max = local.ingress_rules.vscode.tcp_options.max
    }
  }

  # Egress Rules
  # Allow all outbound traffic
  egress_security_rules {
    protocol         = local.egress_rules.all.protocol
    destination      = local.egress_rules.all.destination
    destination_type = local.egress_rules.all.destination_type
    description      = local.egress_rules.all.description
  }

  freeform_tags = merge(
    local.common_tags,
    {
      "Name" = local.resource_names.security_list
      "Type" = "SecurityList"
    }
  )
  defined_tags = var.defined_tags
}

# =============================================================================
# PUBLIC SUBNET
# =============================================================================

resource "oci_core_subnet" "subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = local.display_names.subnet
  dns_label                  = local.subnet_dns_label
  cidr_block                 = local.subnet_cidr
  route_table_id             = oci_core_route_table.rt.id
  security_list_ids          = [oci_core_security_list.sl.id]
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false

  freeform_tags = merge(
    local.common_tags,
    {
      "Name" = local.resource_names.subnet
      "Type" = "Subnet"
    }
  )
  defined_tags = var.defined_tags
}

# =============================================================================
# NETWORK SECURITY GROUP (OPTIONAL - For additional security)
# =============================================================================

resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.resource_prefix}-nsg"

  freeform_tags = merge(
    local.common_tags,
    {
      "Name" = "${local.resource_prefix}-nsg"
      "Type" = "NetworkSecurityGroup"
    }
  )
  defined_tags = var.defined_tags
}

# NSG Rules for SSH
resource "oci_core_network_security_group_security_rule" "nsg_ssh" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP
  source                    = var.allowed_ssh_cidr
  source_type               = "CIDR_BLOCK"
  description               = "Allow SSH from specified CIDR"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# NSG Rules for VS Code Server
resource "oci_core_network_security_group_security_rule" "nsg_vscode" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP
  source                    = var.allowed_https_cidr
  source_type               = "CIDR_BLOCK"
  description               = "Allow VS Code Server access"

  tcp_options {
    destination_port_range {
      min = var.vscode_port
      max = var.vscode_port
    }
  }
}

# NSG Rules for HTTPS
resource "oci_core_network_security_group_security_rule" "nsg_https" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP
  source                    = var.allowed_https_cidr
  source_type               = "CIDR_BLOCK"
  description               = "Allow HTTPS access"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

# NSG Rules for Egress
resource "oci_core_network_security_group_security_rule" "nsg_egress" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all outbound traffic"
}
