#
# Vagrant specific resource names
#
# @resource_instance_list: shell_script.vagrant-bastion
# @resource_instance_data_list: shell_script.bastion-data
#

#
# Vagrant specific inputs
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
  default = "vagrant"
}

# The bastion VM's instance memory
#
# @order: 200
# @tags: recipe,target-undeployed,target-deployed
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: Must be a numeric value
#
variable "bastion_memory_size" {
  description = "How much memory in KB to allocate for the bastion instance."
  default = "4096"
}

# The bastion VM's static ip
#
# @order: 201
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^$|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$
# @value_inclusion_filter_message: Must be a valid IPv4 format [i.e. 192.168.1.1] or blank
#
variable "bastion_static_ip" {
  description = "Static IP to assign to the bastion instance. Leave blank to have it auto-assigned"
  default = ""
}

# The MyCS api service port
#
# @order: 202
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^\d+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "bastion_admin_api_port" {
  description = "The port on which the MyCS space service will listen on"
  default = "10443"

  validation {
    condition = (
      can(tonumber(var.bastion_admin_api_port)) && 
      tonumber(var.bastion_admin_api_port) >= 1024 && 
      tonumber(var.bastion_admin_api_port) <= 65535
    )
    error_message = "Invalid port number."
  }
}

# The bastion's SSH port
#
# @order: 203
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^\d+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "bastion_admin_ssh_port" {
  description = "The port on which the SSH service will be available on"
  default = "10022"

  validation {
    condition = (
      can(tonumber(var.bastion_admin_ssh_port)) && 
      tonumber(var.bastion_admin_ssh_port) >= 1024 && 
      tonumber(var.bastion_admin_ssh_port) <= 65535 
    )
    error_message = "Invalid port number."
  }
}

#
# Vagrant common local variables
#

locals {
  public_cloud_provider = "Vagrant"

  configure_dns = false
}
