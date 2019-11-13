#
# Azure specific inputs
#
variable "azure_dns_zone" {
  type = string
}

variable "attach_dns_zone" {
  default = false
}

variable "bastion_instance_type" {
  default = "Standard_DS2_v2"
}

#
# Common local variables
#

locals {
  configure_dns = "${length(var.aws_dns_zone) == 0 ? false : var.attach_dns_zone}"
}
