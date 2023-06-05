#
# Azure specific resource names
#
# @resource_instance_list: module.bootstrap.azurerm_linux_virtual_machine.bastion
# @resource_instance_data_list: module.bootstrap.azurerm_managed_disk.bastion-data
#

#
# Azure specific inputs
#

# The provider's cloud type for this recipe. 
# This is a non-input field used for Cloud
# specific conditional input variables and
# is a constant.
#
# @order: 5
#
variable "provider_type" {
  default = "azure"
  description = "The provider's cloud type."
}

# The DNS Zone to use
#
# @order: 9
# @tags: recipe
# @value_inclusion_filter: ^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$
# @value_inclusion_filter_message: Entered value does not appear to be a valid DNS name.
# @depends_on: attach_dns_zone=true
#
variable "azure_dns_zone" {
  description = "The DNS zone to use when naming VPN node's DNS name."
  default = "local"
}

# The dns zone's resource group
#
# @order: 10
# @tags: recipe
# @value_inclusion_filter: ^[-_.()0-9a-zA-Z]*[-_()0-9a-zA-Z]$
# @value_inclusion_filter_message: Entered value does not appear to be a valid Azure resource group name.
# @depends_on: attach_dns_zone=true
#
variable "azure_dns_zone_resource_group" {
  description = "The resource group of the parent DNS zone."
  default = ""
}

# The bastion VM's instance type
#
# @order: 200
# @tags: recipe,target-undeployed,target-deployed
# @accepted_values: Standard_B1s,Standard_B1ms,Standard_B2s,Standard_B2ms,Standard_B4ms
# @accepted_values_message: Not a valid AWS general purpose instance type
#
variable "bastion_instance_type" {
  description = "The Azure instance type of the VPN node."
  default = "Standard_B1s"
}

#
# Microsoft Azure common local variables
#

locals {
  public_cloud_provider = "Microsoft Azure"

  configure_dns = (var.attach_dns_zone 
    ? length(var.azure_dns_zone) > 0 
    : false
  )

  source_resource_group = (length(var.azure_dns_zone_resource_group) == 0 
    ? "default" 
    : var.azure_dns_zone_resource_group
  )
}
