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
  default = "MyCloudSpace"
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
# @accepted_values: ipsec,ovpn,ovpn-x
# @accepted_values_message: VPN type must be one of ipsec, ovpn or ovpn-x.
#
variable "vpn_type" {
  description = "Type of VPN to deploy for the sandbox."
  default = "ovpn"
}

# VPN Users - list of 'user|password' pairs
#
# @order: 16
# @tags: recipe
# @value_inclusion_filter: ^[a-zA-Z][-a-zA-Z0-9]*|[a-zA-Z0-9!@#%&:;<>_`~{}\^\$\*\+\-\.\?\"\'\[\]\(\)]*,?$
# @value_inclusion_filter_message: User names cannot start with a numeric and must be only apha-numeric with the exception of a '-'. Passwords can contain special characters except for '|' and ','.
# @sensitive: true
#
variable "vpn_users" {
  description = "Initial list of VPN users to create. This should be a comma separated list of 'user|password' pairs."
  default = "user1|p@ssw0rd"
}

# OpenVPN specific inputs
#

# OpenVPN port
#
# @order: 110
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: vpn_type=ovpn|ovpn-x
#
variable "ovpn_server_port" {
  description = "The port on which the OpenVPN service will listen for connections. Applies only when vpn_type is 'ovpn' or 'ovpn-x'."
  default = "4495"
}

# OpenVPN protocol
#
# @order: 111
# @tags: recipe
# @accepted_values: udp,tcp
# @accepted_values_message: The protocol must be one of "udp" or "tcp".
# @depends_on: vpn_type=ovpn|ovpn-x
#
variable "ovpn_protocol" {
  description = "The IP protocol to use for the encrypted VPN tunnel. Applies only when vpn_type is 'ovpn' or 'ovpn-x'."
  default = "udp"
}

# Masked OpenVPN specific inputs
#

# VPN traffic obfuscation tunnel start port
#
# @order: 112
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: vpn_type=ovpn-x
#
variable "tunnel_vpn_port_start" {
  description = "The start port over which an obfuscated Open VPN traffic will be tunnelled. Applies only when vpn_type is 'ovpn-x'."
  default = "4496"
}

# VPN traffic obfuscation tunnel end port
#
# @order: 113
# @tags: recipe
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
# @depends_on: vpn_type=ovpn-x
#
variable "tunnel_vpn_port_end" {
  description = "The end port over which an obfuscated Open VPN traffic will be tunnelled. Applies only when vpn_type is 'ovpn-x'."
  default = "5596"
}

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
# Bastion image
#
variable "bastion_image_name" {
  default = "appbricks-bastion-inceptor_0.0.1"
}

#
# Common local variables
#
locals {
  vpn_type = var.vpn_type == "ipsec" ? "ipsec" : "openvpn"
  vpn_type_name = var.vpn_type == "ipsec" ? "IPSec/IKEv2" : var.vpn_type == "ovpn" ? "OpenVPN" : "OpenVPN-Masked"
}
