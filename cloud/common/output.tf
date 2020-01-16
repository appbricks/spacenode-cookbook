#
# Output
#

output "dns_configured" {
  value = local.configure_dns
}

output "vpn_idle_action" {
  value = var.vpn_idle_action
}

#
# Create help/usage text for the node
#

locals {
  endpoint = local.configure_dns ? module.bootstrap.bastion_fqdn : module.bootstrap.bastion_public_ip
  users    = [for u in split(",", var.vpn_users) : 
    "* url: https://${local.endpoint}/${split("|", u)[0]}\n  user: ${split("|", u)[0]}\n  password: ${split("|", u)[1]}" 
  ]
  help = <<HELP

This My Cloud Space VPN service allows you to securely connect to
your cloud space in the following provider region.

provider: ${local.public_cloud_provider}
region: '${var.region}'

You can download the VPN configuration from the password protected
links below. The same user and password used to access the link
should be used as the login credentials for the VPN.

${join("\n\n", local.users)}
HELP
}

#
# Output metadata for Cloud Builder framework
#

output "cb_managed_instances" {
  value = [
    {
      "order": 0
      "name": "bastion"
      "id": module.bootstrap.bastion_instance_id
      "fqdn": module.bootstrap.bastion_fqdn
      "public_ip": module.bootstrap.bastion_public_ip
      "ssh_port": module.bootstrap.bastion_admin_ssh_port
      "ssh_user": module.bootstrap.bastion_admin_user 
      "ssh_key": module.bootstrap.bastion_admin_sshkey
      "root_passwd": module.bootstrap.bastion_admin_password
      "help": local.help
    }
  ]
}

output "cb_bastion_version" {
  value = reverse(split("_", var.bastion_image_name))[0]
}