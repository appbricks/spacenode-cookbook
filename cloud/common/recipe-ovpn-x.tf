#
# @recipe_description: My Cloud Space sandbox with OpenVPN based VPN Node with ability obfuscate the VPN tunnel to bypass DPI firewalls.
#

# OpenVPN port
#
# @order: 110
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "ovpn_server_port" {
  description = "The port on which the OpenVPN service will listen for connections."
  default = "4495"
}

# OpenVPN protocol
#
# @order: 111
# @accepted_values: udp,tcp
# @accepted_values_message: The protocol must be one of "udp" or "tcp".
#
variable "ovpn_protocol" {
  description = "The IP protocol to use for the encrypted VPN tunnel."
  default = "udp"
}

# VPN traffic obfuscation tunnel start port
#
# @order: 112
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "tunnel_vpn_port_start" {
  description = "The start port over which obfuscated VPN traffic will be tunnelled."
  default = "4496"
}

# VPN traffic obfuscation tunnel end port
#
# @order: 113
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "tunnel_vpn_port_end" {
  description = "The end port over which obfuscated VPN traffic will be tunnelled."
  default = "5596"
}

#
# OpenVPN Masked common local variables
#

locals {
  vpn_type = "OpenVPN-Masked"
}
