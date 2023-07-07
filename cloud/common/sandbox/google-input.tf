#
# Google specific resource names
#
# @resource_instance_list: module.bootstrap.google_compute_instance.bastion
# @resource_instance_data_list: module.bootstrap.google_compute_disk.bastion-data
#

#
# Google Cloud Platform specific inputs
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
  default = "google"
}

# The DNS Zone to use
#
# @order: 9
# @tags: recipe
# @value_inclusion_filter: ^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$
# @value_inclusion_filter_message: Entered value does not appear to be a valid DNS name.
# @depends_on: attach_dns_zone=true
#
variable "google_dns_zone" {
  description = "The DNS Zone to use when naming VPN node's DNS name."
  default = "local"
}

# The GCP Managed DNS zone name to register the DNS zone in
#
# @order: 10
# @tags: recipe
# @depends_on: attach_dns_zone=true
#
variable "google_dns_managed_zone_name" {
  description = "The Google Cloud Platform managed DNS Zone name to register the DNS zone in."
  default = ""
}

# The bastion VM's instance type
#
# @order: 200
# @accepted_values: n1-standard-1,n1-standard-2,n2-standard-2,n1-standard-4,n2-standard-4
# @accepted_values_message: Not a valid AWS general purpose instance type
# @tags: recipe,target-undeployed,target-deployed
#
variable "bastion_instance_type" {
  description = "The Google Cloud Platform instance type of the VPN node."
  default = "n1-standard-1"
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
# Google Cloud Platform common local variables
#

locals {
  public_cloud_provider = "Google Cloud Platform"

  configure_dns = var.attach_dns_zone ? length(var.google_dns_managed_zone_name) > 0 && length(var.google_dns_zone) > 0 : false
}
