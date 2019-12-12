#
# Azure specific inputs
#

# The DNS Zone to use
#
# @order: 6
# @value_inclusion_filter: ^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$
# @value_inclusion_filter_message: Entered value does not appear to be a valid DNS name.
# @depends_on: attach_dns_zone=true
#
variable "azure_dns_zone" {
  description = "The DNS Zone to use when naming VPN node's DNS name."
  default = ""
}

# The bastion VM's instance type
#
# @order: 101
#
variable "bastion_instance_type" {
  description = "The Azure instance type of the VPN node."
  default = "Standard_DS2_v2"
}

#
# Common local variables
#

locals {
  configure_dns = var.attach_dns_zone ? length(var.dns_zone) > 0 : false
}
