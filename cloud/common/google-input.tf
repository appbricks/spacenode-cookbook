#
# Google Cloud Platform specific inputs
#

# The DNS Zone to use
#
# @order: 6
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
# @depends_on: attach_dns_zone=true
#
variable "google_dns_managed_zone_name" {
  description = "The Google Cloud Platform managed DNS Zone name to register the DNS zone in."
  default = ""
}

# The bastion VM's instance type
#
# @order: 101
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
