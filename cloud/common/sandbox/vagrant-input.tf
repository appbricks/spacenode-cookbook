#
# Vagrant specific resource names
#
# @resource_instance_list: shell_script.vagrant-bastion
# @resource_instance_data_list: null_resource.bastion-data
#

#
# Vagrant specific inputs
#

# The bastion VM's instance memory
#
# @order: 101
# @tags: recipe,target-undeployed,target-deployed
# @accepted_values: [0-9]+
# @accepted_values_message: Must be a numeric value
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
