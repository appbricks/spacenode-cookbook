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

#
# MyCS container image version
#
variable "mycsnode_version" {
  type = string
}
