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
      "ssh_user": module.bootstrap.bastion_admin_user 
      "ssh_key": module.bootstrap.bastion_admin_sshkey
      "root_passwd": module.bootstrap.bastion_admin_password
    }
  ]
}

output "cb_recipe_version" {
  value = reverse(split("_", var.bastion_image_name))[0]
}