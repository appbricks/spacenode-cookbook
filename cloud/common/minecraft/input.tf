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

variable "cb_internal_pdns_api_key" {
  type = string
}
