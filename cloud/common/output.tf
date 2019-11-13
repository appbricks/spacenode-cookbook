#
# Output
#
output "bastion_instance_id" {
  value = "${module.bootstrap.bastion_instance_id}"
}

output "bastion_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "bastion_public_ip" {
  value = "${module.bootstrap.bastion_public_ip}"
}

output "bastion_admin_password" {
  value = "${module.bootstrap.bastion_admin_password}"
}

output "bastion_version" {
  value = "${reverse(split("_", var.bastion_image_name))[0]}"
}

output "dns_configured" {
  value = "${local.configure_dns}"
}

output "vpn_idle_action" {
  value = "${var.vpn_idle_action}"
}
