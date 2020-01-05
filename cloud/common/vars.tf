# Cloud Builder Bastion service cloud recipe
#
# @is_bastion: true
#

# Cloud region to deploy to
#
# @order: 1
# @accepted_values: +iaas_regions
# @accepted_values_message: Error! not a valid region
# @target_key: true
#
variable "region" {
  description = "The cloud region or location in which to deploy the VPN node."
  type = string
}

# Deployment Name
#
# @order: 2
# @tags: recipe,target-undeployed
# @target_key: true
#
variable "name" {
  description = "Name that uniquely identies your VPN node and resources created for it."
  default = "myvpn"
}

# Whether a DNS zone should be attached
#
# @order: 5
# @tags: recipe
# @accepted_values: false,true
# @accepted_values_message: Please enter 'true' or 'false'.
#
variable "attach_dns_zone" {
  description = "If you own a domain and wish the node to be looked up via that domain then set this value to 'true'."
  default = false
}

# Issue valid letsencrypt certificate to bastion
#
# @order: 10
# @tags: recipe
# @accepted_values: false,true
# @accepted_values_message: Please enter 'true' or 'false'.
#
variable "certify_bastion" {
  description = "Issue a valid certificate for your VPN domain from https://letsencrypt.org/. You will need to provide a domain which you own for this to be successful."
  default = false
}

# VPN Users - list of 'user|password' pairs
#
# @order: 15
# @tags: recipe
# @value_inclusion_filter: ^[a-zA-Z][-a-zA-Z0-9]*|[a-zA-Z0-9!@#%&:;<>_`~{}\^\$\*\+\-\.\?\"\'\[\]\(\)]*,?$
# @value_inclusion_filter_message: User names cannot start with a numeric and must be only apha-numeric with the exception of a '-'. Passwords can contain special characters except for '|' and ','.
# @sensitive: true
#
variable "vpn_users" {
  description = "Initial list of VPN users to create. This should be a comma separated list of 'user|password' pairs."
  default = "user1|p@ssw0rd"
}

# Indicates action when no VPN clients have 
# been connected to a node for some time
#
# @order: 20
# @tags: recipe
# @accepted_values: shutdown,none
# @accepted_values_message: Please provide one of 'shutdown' or 'none'.
#
variable "vpn_idle_action" {
  description = "Action to take when no VPN clients have been connected to the node for some time."
  default = "shutdown"
}

#
# Bastion image
#
variable "bastion_image_name" {
  default = "appbricks-bastion-inceptor_0.0.1"
}

# Attributes for generating self-signed certificates
#
variable "company_name" {
  default = "AppBricks, Inc."
}
variable "organization_name" {
  default = "My Cloud Space"
}
variable "locality" {
  default = "Home"
}
variable "province" {
  default = "Cloud"
}
variable "country" {
  default = "Public"
}
