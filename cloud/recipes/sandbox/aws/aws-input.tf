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
  description = "The provider's cloud type."
  default = "aws"
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

# The MyCS api service port
#
# @order: 201
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^\d+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "bastion_admin_api_port" {
  description = "The port on which the MyCS space service will listen on"
  default = "443"

  validation {
    condition = (
      can(tonumber(var.bastion_admin_api_port)) &&
      ( tonumber(var.bastion_admin_api_port) == 443 ||
        ( tonumber(var.bastion_admin_api_port) >= 1024 &&
          tonumber(var.bastion_admin_api_port) <= 65535 ) )
    )
    error_message = "Invalid port number."
  }
}

# The bastion's SSH port
#
# @order: 202
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^\d+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "bastion_admin_ssh_port" {
  description = "The port on which the SSH service will be available on"
  default = "22"

  validation {
    condition = (
      can(tonumber(var.bastion_admin_ssh_port)) &&
      ( tonumber(var.bastion_admin_ssh_port) == 22 ||
        ( tonumber(var.bastion_admin_ssh_port) >= 1024 &&
          tonumber(var.bastion_admin_ssh_port) <= 65535 ) )
    )
    error_message = "Invalid port number."
  }
}

#
# Amazon Web Services common local variables
#

locals {
  public_cloud_provider = "Amazon Web Services"

  configure_dns = var.attach_dns_zone ? length(var.aws_dns_zone) > 0 : false
}
