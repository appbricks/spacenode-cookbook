# Cloud Builder Bastion service cloud recipe
#
# @recipe_description: My Cloud Space virtual private cloud sandbox.
# @is_bastion: true
#

# Cloud region to deploy to
#
# @order: 1
# @accepted_values: +iaas_regions
# @accepted_values_message: Error! not a valid region
# @target_key: true
#
variable "region" {
  description = "The cloud region or location in which to deploy the VPN node."
  type = string
}

# Deployment Name
#
# @order: 2
# @tags: recipe,target-undeployed
# @target_key: true
#
variable "name" {
  description = "Name that uniquely identies your VPN node and resources created for it."
  default = "MyCS"
}

# Whether a DNS zone should be attached
#
# @order: 5
# @tags: recipe
# @accepted_values: false,true
# @accepted_values_message: Please enter 'true' or 'false'.
#
variable "attach_dns_zone" {
  description = "If you own a domain and wish the node to be looked up via that domain then set this value to 'true'."
  default = false
}

# Whether to deploy an internal admin network
# which can either bridge access to other or
# cloud resources or be used for apps and
# services.
#
# @order: 6
# @tags: recipe,target-undeployed
# @accepted_values: false,true
# @accepted_values_message: Please enter 'true' or 'false'.
#
variable "configure_admin_network" {
  description = "If you want to configure an internal admin network where apps and services can be installed set this value to 'true'."
  default = false
}

# Issue valid letsencrypt certificate to bastion
#
# @order: 10
# @tags: recipe
# @accepted_values: false,true
# @accepted_values_message: Please enter 'true' or 'false'.
#
variable "certify_bastion" {
  description = "Issue a valid certificate for your VPN domain from https://letsencrypt.org/. You will need to provide a domain which you own for this to be successful."
  default = false
}

# VPN Type - type of the VPN
#
# @order: 15
# @tags: recipe
# @accepted_values: wg,ovpn,ipsec
# @accepted_values_message: VPN type must be one of wg (WireGuard), ovpn (OpenVPN) or ipsec (IPSec/IKEv2).
#
variable "vpn_type" {
  description = "Type of VPN to deploy for the sandbox."
  default = "wg"
}

# Indicates action when no VPN clients have 
# been connected to a node for some time
#
# @order: 16
# @tags: recipe,target-undeployed
# @accepted_values: shutdown,none
# @accepted_values_message: Please provide one of 'shutdown' or 'none'.
#
variable "idle_action" {
  description = "Action to take when no VPN clients have been connected to the space for some time."
  default = "shutdown"
}

# Time interval in minutes before node is shut
# as no VPN clients connected during that time.
#
# @order: 17
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The time interval should be a value greater than 0.
# @depends_on: idle_action=shutdown
#
variable "idle_shutdown_time" {
  description = "Time interval after last client disconnects from the space when the space node is shut down."
  default = 10
}

# VPN Users - list of 'user|password' pairs
#
# @order: 18
# @tags: recipe
# @value_inclusion_filter: ^[a-zA-Z][-a-zA-Z0-9]*|[a-zA-Z0-9!@#%&:;<>_`~{}\^\$\*\+\-\.\?\"\'\[\]\(\)]*,?$
# @value_inclusion_filter_message: User names cannot start with a numeric and must be only apha-numeric with the exception of a '-'. Passwords can contain special characters except for '|' and ','.
# @sensitive: true
# @depends_on: vpn_type=ovpn|ipsec
#
variable "vpn_users" {
  description = "List of VPN users that can connect directly to the space node. This is a comma separated list of 'user|password' pairs."
  default = ""
}

# Wireguard specific inputs
#

# Wireguard port
#
# @order: 110
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: vpn_type=wg
#
variable "wireguard_service_port" {
  description = "The port on which the WireGuard service will listen for connections."
  default = "3399"
}

# OpenVPN specific inputs
#

# OpenVPN port
#
# @order: 111
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: vpn_type=ovpn
#
variable "ovpn_service_port" {
  description = "The port on which the OpenVPN service will listen for connections."
  default = "4495"
}

# OpenVPN protocol
#
# @order: 112
# @tags: recipe
# @accepted_values: udp,tcp
# @accepted_values_message: The protocol must be one of "udp" or "tcp".
# @depends_on: vpn_type=ovpn
#
variable "ovpn_protocol" {
  description = "The IP protocol to use for the encrypted VPN tunnel."
  default = "udp"
}

# VPN traffic masking
#

# Mask VPN traffic
#
# @order: 113
# @tags: recipe
# @accepted_values: yes,no
# @accepted_values_message: Please enter 'yes' or 'no'.
# @depends_on: vpn_type=wg|ovpn
#
variable "mask_vpn_traffic" {
  description = "Obfusucate VPN traffic to bypass ISP/Firewall VPN detection."
  default = "no"
}

# VPN traffic obfuscation tunnel start port
#
# @order: 114
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: mask_vpn_traffic=yes
#
variable "tunnel_vpn_port_start" {
  description = "The start port over which an obfuscated VPN traffic will be tunnelled."
  default = "4496"
}

# VPN traffic obfuscation tunnel end port
#
# @order: 115
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: mask_vpn_traffic=yes
#
variable "tunnel_vpn_port_end" {
  description = "The end port over which an obfuscated VPN traffic will be tunnelled."
  default = "5596"
}

# MyCS DERP service STUN port
#
# @order: 116
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "derp_stun_port" {
  description = "The port on which MyCS Node will run the STUN service to discover endpoints of connected devices"
  default = "3478"
}

#
# Attributes for generating self-signed certificates
#
variable "company_name" {
  default = "AppBricks, Inc."
}
variable "organization_name" {
  default = "My Cloud Space"
}
variable "locality" {
  default = "Home"
}
variable "province" {
  default = "Cloud"
}
variable "country" {
  default = "US"
}

#
# Node keys
#
# RSA private key of the MyCS node used for authentication with client devices
variable "mycs_node_private_key" {
  default = ""
}
# The id key identifies this node with MyCS account services
variable "mycs_node_id_key" {
  default = ""
}

#
# Bastion image
#
variable "bastion_image_name" {
  type = string
}

#
# Common local variables
#
locals {
  space_domain = lower("${var.name}-${var.region}")
  space_internal_domain = "${local.space_domain}.mycs"

  vpn_type = (
    var.vpn_type == "wg" 
      ? "wireguard" 
      : var.vpn_type == "ovpn" 
        ? "openvpn" 
        : "ipsec"
  )
  vpn_type_name = (
    var.vpn_type == "wg" 
      ? "WireGuard" 
      : var.vpn_type == "ovpn" 
        ? "OpenVPN" 
        : "IPSec/IKEv2"
  )
  tunnel_vpn_port_start = (
    var.mask_vpn_traffic == "yes" 
      ? var.tunnel_vpn_port_start : ""
  )
  tunnel_vpn_port_end = (
    var.mask_vpn_traffic == "yes" 
      ? var.tunnel_vpn_port_end : ""
  )

  # Add a non-admin VPN user for VPN types other than wireguard
  vpn_users = (length(var.vpn_users) > 0 
    ? join(",", ["mycs-user|${random_string.non-root-passwd.result}", var.vpn_users])
    : var.vpn_type != "wg" ? "mycs-user|${random_string.non-root-passwd.result}" : ""
  )
}

resource "random_string" "non-root-passwd" {
  length           = 32
  special          = true
  override_special = "@#%&*()-_=+[]{}<>:?"
}
