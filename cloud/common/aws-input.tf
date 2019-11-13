#
# AWS specific inputs
#
variable "aws_dns_zone" {
  default = ""
}

variable "attach_dns_zone" {
  default = false
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "bastion_image_name" {
  default = "appbricks-inceptor-bastion_0.0.3"
}

variable "bastion_image_owner" {
  default = "244289018343"
}

#
# Common local variables
#

locals {
  configure_dns = "${length(var.aws_dns_zone) == 0 ? false : var.attach_dns_zone}"
}
