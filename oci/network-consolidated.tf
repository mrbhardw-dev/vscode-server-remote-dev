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
  display_name   = local.display_names.igw
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
  display_name   = local.display_names.route_table

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
  display_name        = local.display_names.subnet
  cidr_block          = local.network_config.subnet_cidr_block
  dns_label           = "subnet"
  availability_domain = local.availability_domain
  route_table_id      = oci_core_route_table.rt.id
  security_list_ids   = [oci_core_security_list.sl.id]

  # Enable public IP assignment for instances
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# SECURITY LIST (LEGACY - FOR COMPATIBILITY)
# =============================================================================

resource "oci_core_security_list" "sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = local.display_names.security_list

  # Outbound traffic - Allow all
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }

  # SSH access
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "SSH access"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP access (for potential web interfaces)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "HTTP access"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS access (for potential web interfaces)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "HTTPS access"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # ICMP traffic for ping
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    description = "ICMP traffic"

    icmp_options {
      type = 3
      code = 4
    }
  }

  # ICMP Echo Request
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    description = "ICMP Echo Request"

    icmp_options {
      type = 8
    }
  }

  freeform_tags = local.common_tags
  defined_tags = var.defined_tags
}

# =============================================================================
# NETWORK SECURITY GROUP (ENHANCED SECURITY)
# =============================================================================

resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = local.display_names.nsg

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

# Custom development port range
resource "oci_core_network_security_group_security_rule" "nsg_dev_ports" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Development ports access (3000-9999)"

  tcp_options {
    destination_port_range {
      min = 3000
      max = 9999
    }
  }
}

# ICMP rules for connectivity testing
resource "oci_core_network_security_group_security_rule" "nsg_icmp" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "1" # ICMP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "ICMP for ping and path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_icmp_echo" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "1" # ICMP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "ICMP Echo Request (ping)"

  icmp_options {
    type = 8
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