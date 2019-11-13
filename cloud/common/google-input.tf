#
# Google Cloud Platform specific inputs
#
variable "google_dns_managed_zone_name" {
  default = ""
}

variable "google_dns_zone" {
  type = string
}

variable "attach_dns_zone" {
  default = false
}

variable "bastion_instance_type" {
  default = "n1-standard-1"
}

#
# Common local variables
#

locals {
  configure_dns = "${length(var.aws_dns_zone) == 0 ? false : var.attach_dns_zone}"
}
