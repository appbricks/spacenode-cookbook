#
# Output
#

output "dns_configured" {
  value = local.configure_dns
}

output "vpn_type" {
  value = local.vpn_type
}

output "vpn_masking_available" {
  value = var.mask_vpn_traffic
}

output "idle_action" {
  value = var.idle_action
}

#
# Create help/usage text for the node
#

locals {
  version = reverse(split("_", var.bastion_image_name))[0]

  endpoint = local.configure_dns ? module.bootstrap.bastion_fqdn : module.bootstrap.bastion_public_ip
  users    = [for u in split(",", var.vpn_users) : 
    "* URL: https://${local.endpoint}/~${split("|", u)[0]}\n  User: ${split("|", u)[0]}\n  Password: ${split("|", u)[1]}" 
  ]
  bastion_description = <<BASTION_DESCRIPTION
The Bastion instance runs the VPN service that can be used to
securely and anonymously access your cloud space resources and the
internet. You can download the VPN configuration along with the VPN
client software from the password protected links below. The same
user and password used to access the link should be used as the login
credentials for the VPN.

${join("\n\n", local.users)}
BASTION_DESCRIPTION
}

#
# Output metadata for Cloud Builder framework
#

output "cb_managed_instances" {
  value = [
    {
      "order": 0
      "vpc_name": module.bootstrap.vpc_name
      "name": "bastion"
      "description": local.bastion_description
      "id": module.bootstrap.bastion_instance_id
      "fqdn": module.bootstrap.bastion_fqdn
      "public_ip": module.bootstrap.bastion_public_ip
      "ssh_port": module.bootstrap.bastion_admin_ssh_port
      "ssh_user": module.bootstrap.bastion_admin_user 
      "ssh_key": module.bootstrap.bastion_admin_sshkey
      "root_passwd": module.bootstrap.bastion_admin_password
    }
  ]
}

output "cb_node_description" {
  value = <<NODE_DESCRIPTION
This My Cloud Space sandbox has been deployed to the following public
cloud environment. Along with a sandboxed virtual cloud network it
includes a VPN service which allows you to access the internet as
well as your personal cloud space services securely while maintaining
your privacy.

Provider: ${local.public_cloud_provider}
Region: ${var.region}
VPN Type: ${local.vpn_type_name}
Version: ${local.version}
NODE_DESCRIPTION
}

output "cb_vpc_name" {
  value = module.bootstrap.vpc_name
}

output "cb_bastion_version" {
  value = local.version
}
