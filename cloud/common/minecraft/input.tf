# Minecraft Cloud Server
#
# @recipe_description: Secure on-demand Minecraft cloud server.
# @is_bastion: false
#

# Minecraft Server name
#
# @order: 1
# @tags: recipe,target-undeployed
# @target_key: true
#
variable "name" {
  description = "The name of the Minecraft server. This must be unique within your cloud space."
  type        = string
  default     = "my-minecraft"
}

# Minecraft distribution type
#
# @order: 2
# @tags: recipe,target-undeployed
# @accepted_values: vanilla,paper,witchcraft-and-wizardry
# @accepted_values_message: Please provide one of 'vanilla', 'paper' or 'witchcraft-and-wizardry'.
#
variable "minecraft_type" {
  description = "Type of Minecraft server distribution - i.e. 'vanilla' is the original untouched distribution."
  type        = string
  default     = "release"
}

# Minecraft Server description
#
# @order: 3
# @tags: recipe,target-undeployed
# @depends_on: minecraft_type=vanilla|paper
#
variable "minecraft_server_description" {
  description = "The description of Minecraft server which will be shown as the server's MOTD."
  type        = string
  default     = "My awesome minecraft worlds in the cloud."
}

# Minecraft version
#
# @order: 4
# @tags: recipe,target-undeployed
# @depends_on: minecraft_type=vanilla|paper
#
variable "minecraft_version" {
  description = "Which version of Minecraft server do you want to install."
  type        = string
  default     = "latest"
}

# Minecraft server port
#
# @order: 5
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The port value must be a number from 1024 to 65535.
#
variable "minecraft_port" {
  description = "The TCP port the Minecraft server will listen on."
  type        = number
  default     = 25565
}

# Minecraft backup frequency
#
# @order: 6
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^[0-9]+$
# @value_inclusion_filter_message: The backup frequency must be a positive value.
#
variable "minecraft_backup_frequency" {
  description = "How often (mins) to backup Minecraft worlds."
  type        = number
  default     = 5
}

# Minecraft JVM initial minimum heap size
#
# @order: 7
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^[0-9]+[kmgKMG]$
# @value_inclusion_filter_message: The heap size must be a positive integer with a suffix (k/m/g) indicating the units.
#
variable "java_ms_mem" {
  description = "Java initial and minimum heap size."
  type        = string
  default     = "2g"
}

# Minecraft JVM maximum heap size
#
# @order: 8
# @tags: recipe,target-undeployed
# @value_inclusion_filter: ^[0-9]+[kmgKMG]$
# @value_inclusion_filter_message: The heap size must be a positive integer with a suffix (k/m/g) indicating the units.
#
variable "java_mx_mem" {
  description = "Java maximum heap size."
  type        = string
  default     = "2g"
}

#
# Inputs from MySpace node
#

variable "cb_vpc_id" {
  type = string
}

variable "cb_vpc_name" {
  type = string
}

variable "cb_deployment_networks" {
  type = list(string)
}

variable "cb_deployment_security_group" {
  type = string
}

variable "cb_default_openssh_private_key" {
  type = string
}

variable "cb_default_ssh_key_pair" {
  type = string
}

variable "cb_internal_pdns_url" {
  type = string
}

variable "cb_internal_pdns_api_key" {
  type = string
}

variable "cb_internal_domain" {
  default  = "local"
}

# Common local variables

locals {
  minecraft_root = "/opt/minecraft"
}
