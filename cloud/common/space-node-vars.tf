#
# MyCS app registration keys
#

variable "mycs_cloud_public_key_id" {
  default = "NA"
}

variable "mycs_cloud_public_key" {
  default = "NA"
}

variable "mycs_app_private_key" {
  default = "NA"
}

variable "mycs_app_id_key" {
  default = "NA"
}

variable "mycs_app_version" {
  default = "dev"
}

#
# Inputs from the MyCS Space node app is deployed to
#

variable "cb_local_state_path" {
  type = string
}

variable "cb_root_ca_cert" {
  type = string
}

variable "cb_vpc_id" {
  type = string
}

variable "cb_vpc_name" {
  type = string
}

variable "cb_deployment_networks" {
  type = list(string)

  validation {
    condition     = length(var.cb_deployment_networks) > 0
    error_message = "No deployment networks found in space. Make sure the space being deployed to has at least one admin network."
  }
}

variable "cb_deployment_security_group" {
  type = string
}

variable "cb_default_ssh_private_key" {
  type = string
}

variable "cb_default_ssh_key_pair" {
  type = string
}

variable "cb_dns_configured" {
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
