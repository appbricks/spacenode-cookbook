#
# AWS specific inputs
#

# The DNS Zone to use
#
# @order: 6
# @value_inclusion_filter: ^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$
# @value_inclusion_filter_message: Entered value does not appear to be a valid DNS name.
# @depends_on: attach_dns_zone=true
#
variable "aws_dns_zone" {
  description = "The DNS Zone to use when naming VPN node's DNS name."
  default = ""
}

# The bastion VM's instance type
#
# @order: 101
#
variable "bastion_instance_type" {
  description = "The EC2 instance type of the VPN node."
  default = "t2.micro"
}

#
# VPN image reference
#
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
  configure_dns = var.attach_dns_zone ? length(var.aws_dns_zone) > 0 : false
}
