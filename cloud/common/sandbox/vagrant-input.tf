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
  default = "vagrant"
  description = "The provider's cloud type."
}

# The bastion VM's instance memory
#
# @order: 101
# @tags: recipe,target-undeployed,target-deployed
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: Must be a numeric value
#
variable "bastion_memory_size" {
  description = "How much memory in KB to allocate for the bastion instance."
  default = "4096"
}

#
# Vagrant common local variables
#

locals {
  public_cloud_provider = "Vagrant"

  configure_dns = false
}
