#
# Azure specific inputs
#

# The DNS Zone to use
#
# @order: 6
# @tags: recipe
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
# @tags: recipe,target-configure
# @accepted_values: Standard_B1ls,Standard_B1s,Standard_B1ms,Standard_B2s,Standard_B2ms,Standard_B4ms
# @accepted_values_message: Not a valid AWS general purpose instance type
#
variable "bastion_instance_type" {
  description = "The Azure instance type of the VPN node."
  default = "Standard_B1ls"
}

#
# Common local variables
#

locals {
  configure_dns = var.attach_dns_zone ? length(var.dns_zone) > 0 : false
}
