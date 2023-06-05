#
# AWS specific resource names
#
# @resource_instance_list: module.bootstrap.aws_instance.bastion
# @resource_instance_data_list: module.bootstrap.aws_ebs_volume.bastion-data
#

#
# AWS specific inputs
#

# The provider's cloud type for this recipe. 
# This is a non-input field used for Cloud
# specific conditional input variables and
# is a constant.
#
# @order: 5
#
variable "provider_type" {
  default = "aws"
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
variable "aws_dns_zone" {
  description = "The DNS Zone to use when naming VPN node's DNS name."
  default = "mycs"
}

# The bastion VM's instance type
#
# @order: 200
# @tags: recipe,target-undeployed,target-deployed
# @accepted_values: t4g.nano,t4g.micro,t4g.small,t4g.medium,t4g.large,t4g.xlarge,t4g.2xlarge
# @accepted_values_message: Not a valid AWS general purpose ARM t4g.* instance type
#
variable "bastion_instance_type" {
  description = "The AWS EC2 instance type of the VPN node."
  default = "t4g.micro"
}

#
# Amazon Web Services common local variables
#

locals {
  public_cloud_provider = "Amazon Web Services"

  configure_dns = var.attach_dns_zone ? length(var.aws_dns_zone) > 0 : false
}
