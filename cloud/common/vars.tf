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
# DNS
#
variable "dns_zone" {
  type = string
}

#
# VPN Users
#
variable "vpn_users" {
  type = list
}

#
# SSH Key Path
#
variable "ssh_key_file_path" {
  default = ""
}
