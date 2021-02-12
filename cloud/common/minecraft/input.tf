#
# Inputs for Minecraft Server
#

variable "minecraft_root" {
  description = "Where to install minecraft on your instance"
  type        = string
  default     = "/opt/minecraft"
}

variable "minecraft_version" {
  description = "Which version of minecraft to install"
  type        = string
  default     = "latest"
}

variable "minecraft_type" {
  description = "Type of minecraft distribution - snapshot or release"
  type        = string
  default     = "release"
}

variable "minecraft_port" {
  description = "TCP port for minecraft"
  type        = number
  default     = 25565
}

variable "minecraft_backup_frequency" {
  description = "How often (mins) to sync to S3"
  type        = number
  default     = 5
}

variable "java_ms_mem" {
  description = "Java initial and minimum heap size"
  type        = string
  default     = "2G"
}

variable "java_mx_mem" {
  description = "Java maximum heap size"
  type        = string
  default     = "2G"
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

variable "cb_internal_pdns_api_key" {
  type = string
}
