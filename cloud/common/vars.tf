#
# Deployment Identifier
#
variable "name" {
  type = string
}

#
# Cloud region to deploy to
#
variable "region" {
  type = string
}

#
# Used for generating self-signed certificates
#
variable "company_name" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "locality" {
  type = string
}

variable "province" {
  type = string
}

variable "country" {
  type = string
}

#
# VPN Users - list of 'user|password' pairs
#
variable "vpn_users" {
  type = list
}

#
# Indicates action when no VPN clients have 
# been connected to a node for some time
#
variable "vpn_idle_action" {
  type = string
}

#
# SSH Key Path
#
variable "ssh_key_file_path" {
  default = ""
}
