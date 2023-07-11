# Application router
#
# @recipe_description: Space application router node.
# @is_bastion: false
#

# Application router name
#
# @order: 1
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^[a-zA-Z0-9][-a-zA-Z0-9]*$
# @value_inclusion_filter_message: The time interval should be a value greater than 0.
# @target_key: true
#
variable "name" {
  description = "The name of the application router. This must be unique within your cloud space."
  type        = string
  default     = "my-app-router"
}

# Application router description
#
# @order: 2
# @tags: recipe,target-undeployed
#
variable "description" {
  description = "A description for the application router. This can be the applications that this router advertises to the space network."
  type        = string
  default     = "My MyCS space application router node"
}

# External networks to advertise
#
# @order: 3
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^(([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,3},?)*$
# @value_inclusion_filter_message: Must be a comma separated list of IPv4 CIDR. For single IP append /32 to it.
#
variable "advertised_external_networks" {
  description = "List of comma separated external networks that to be routed via this app node."
  type        = string
  default     = ""
}

# External domain names to advertise
#
# @order: 4
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^(([-a-zA-Z]+\.)+[-a-zA-Z]+,?)*$
# @value_inclusion_filter_message: Must be a comma separated list of domain names.
#
variable "advertised_external_domain_names" {
  description = "List of comma separated external domain names to be routed via this app node."
  type        = string
  default     = ""
}

#
# MyCS container image version
#
variable "mycs_node_version" {
  type = string
}
