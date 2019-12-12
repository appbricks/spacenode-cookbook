#
# Azure specific inputs
#
variable "azure_dns_zone" {
  default = ""
}

variable "bastion_instance_type" {
  default = "Standard_DS2_v2"
}

#
# Common local variables
#

locals {
  configure_dns = var.attach_dns_zone ? length(var.azure_dns_zone) > 0 : false
}
