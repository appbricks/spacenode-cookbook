#
# Output
#

#
# Create help/usage text for the node
#

locals {
  version = reverse(split("_", var.bastion_image_name))[0]
  
  endpoint = local.configure_dns ? module.bootstrap.bastion_fqdn : module.bootstrap.bastion_public_ip
  users    = (length(local.vpn_users) > 0 ? [for u in split(",", local.vpn_users) : 
    "* URL: https://${local.endpoint}/static/~${split("|", u)[0]}\n  User: ${split("|", u)[0]}\n  Password: ${split("|", u)[1]}" 
  ]: [])
  bastion_description_non_wg = <<BASTION_DESCRIPTION
The Bastion instance runs the VPN service that can be used to
securely and anonymously access your cloud space resources and the
internet. You can download the VPN configuration along with the VPN
client software using the CloudBuilder CLI or the password protected
links below. The same user and password used to access the link 
should be used to login to the VPN if required.

${join("\n\n", local.users)}
BASTION_DESCRIPTION
  bastion_description_wg = <<BASTION_DESCRIPTION
The Bastion space node runs the cloud space network mesh control 
services. It also provides a VPN service that can be used to
securely and anonymously connect to your cloud space to manage
cloud resources and applications. You will need to use the Cloud
Builder client to connect and use space resources securely.
BASTION_DESCRIPTION
  bastion_description = var.vpn_type == "wg" ? local.bastion_description_wg : local.bastion_description_non_wg
}

#
# Output metadata for Cloud Builder framework
#

output "cb_managed_instances" {
  sensitive = true
  value = [
    {
      "order": 0
      "id": module.bootstrap.bastion_instance_id
      "name": "bastion"
      "description": local.bastion_description
      "fqdn": module.bootstrap.bastion_fqdn
      "public_ip": module.bootstrap.bastion_public_ip
      "private_ip": module.bootstrap.bastion_admin_ip
      "health_check_port": module.bootstrap.bastion_admin_api_port
      "health_check_type": "tcp"
      "api_port": module.bootstrap.bastion_admin_api_port
      "ssh_port": module.bootstrap.bastion_admin_ssh_port
      "ssh_user": module.bootstrap.bastion_admin_user 
      "ssh_key": module.bootstrap.bastion_admin_sshkey
      "root_user": module.bootstrap.bastion_admin_user 
      "root_passwd": module.bootstrap.bastion_admin_password
      "non_root_user": "mycs-user"
      "non_root_passwd": random_string.non-root-passwd.result
    }
  ]
}

output "cb_node_description" {
  value = <<NODE_DESCRIPTION
This My Cloud Space sandbox has been deployed to the following public
cloud environment. 

Provider: ${local.public_cloud_provider}
Region: ${var.region}
VPN Type: ${local.vpn_type_name}
Version: ${local.version}
NODE_DESCRIPTION
}

output "cb_node_version" {
  value = local.version
}

output "cb_root_ca_cert" {
  value = module.bootstrap.root_ca_cert
}

output "cb_vpc_id" {
  value = module.bootstrap.vpc_id
}

output "cb_vpc_name" {
  value = module.bootstrap.vpc_name
}

output "cb_deployment_networks" {
  value = module.bootstrap.admin_subnetworks
}

output "cb_deployment_security_group" {
  value = module.bootstrap.admin_security_group
}

output "cb_default_ssh_private_key" {
  sensitive = true
  value = module.bootstrap.default_openssh_private_key
}

output "cb_default_ssh_key_pair" {
  value = module.bootstrap.default_ssh_key_pair
}

output "cb_dns_configured" {
  value = local.configure_dns
}

output "cb_internal_domain" {
  value = local.space_internal_domain
}

output "cb_internal_pdns_url" {
  value = module.bootstrap.powerdns_url
}

output "cb_internal_pdns_api_key" {
  value     = module.bootstrap.powerdns_api_key
  sensitive = true
}

output "cb_vpn_type" {
  value = local.vpn_type
}

output "cb_vpn_masking_available" {
  value = var.mask_vpn_traffic
}

output "cb_idle_action" {
  value = var.idle_action
}
