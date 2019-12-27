#
# Google Cloud Platform specific inputs
#

# The DNS Zone to use
#
# @order: 6
# @tags: recipe
# @value_inclusion_filter: ^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$
# @value_inclusion_filter_message: Entered value does not appear to be a valid DNS name.
# @depends_on: attach_dns_zone=true
#
variable "google_dns_zone" {
  description = "The DNS Zone to use when naming VPN node's DNS name."
  default = ""
}

# The GCP Managed DNS zone name to register the DNS zone in
#
# @order: 7
# @tags: recipe
# @depends_on: attach_dns_zone=true
#
variable "google_dns_managed_zone_name" {
  description = "The Google Cloud Platform managed DNS Zone name to register the DNS zone in."
  default = ""
}

# The bastion VM's instance type
#
# @order: 101
# @accepted_values: n1-standard-1,n1-standard-2,n2-standard-2,n1-standard-4,n2-standard-4
# @accepted_values_message: Not a valid AWS general purpose instance type
# @tags: recipe,target-deployed
#
variable "bastion_instance_type" {
  description = "The Google Cloud Platform instance type of the VPN node."
  default = "n1-standard-1"
}

#
# Common local variables
#

locals {
  configure_dns = var.attach_dns_zone ? length(var.google_dns_managed_zone_name) > 0 && length(var.dns_zone) : false
}
