#
# Google Cloud Platform specific inputs
#
variable "google_dns_managed_zone_name" {
  default = ""
}

variable "google_dns_zone" {
  type = string
}

variable "bastion_instance_type" {
  default = "n1-standard-1"
}

#
# Common local variables
#

locals {
  configure_dns = var.attach_dns_zone ? length(var.google_dns_managed_zone_name) > 0 && length(var.google_dns_zone) : false
}
