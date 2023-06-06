#
# Output
#

#
# Create help/usage text for the node
#

locals {
  version = reverse(split("_", var.bastion_image_name))[0]
  
  endpoint = "${replace(local.network_env.publicIP, ".", "-")}.mycs.appbricks.org"
  endpoint_port = var.bastion_admin_api_port == "443" ? "" : ":${var.bastion_admin_api_port}"
  users    = (length(local.vpn_users) > 0 ? [for u in split(",", local.vpn_users) : 
    "* URL: https://${local.endpoint}${local.endpoint_port}/static/~${split("|", u)[0]}\n  User: ${split("|", u)[0]}\n  Password: ${split("|", u)[1]}" 
  ]: [])

  vpn_port_forwarding_config = (
    var.vpn_type == "wg" 
      ? "UDP ${var.wireguard_service_port} => ${local.bastion_info.ip}:${var.wireguard_service_port}"
      : var.vpn_type == "ovpn" 
        ? var.ovpn_protocol == "udp"
          ? "UDP ${var.ovpn_service_port} => ${local.bastion_info.ip}:${var.ovpn_service_port}"
          : "TCP ${var.ovpn_service_port} => ${local.bastion_info.ip}:${var.ovpn_service_port}"
        : "UDP 500 => ${local.bastion_info.ip}:500\n               UDP 4500 => ${local.bastion_info.ip}:4500"
  )
  port_forwarding_config = <<PORT_FORWARDING_CONFIG
If port forwarding has not been automatically setup via UPnP 
on your internet facing router then you need to configure the
following port forwarding rules manually.

  * SpaceAPI:  TCP ${var.bastion_admin_api_port} => ${local.bastion_info.ip}:${var.bastion_admin_api_port}
  * SpaceSTUN: UDP ${var.derp_stun_port} => ${local.bastion_info.ip}:${var.derp_stun_port}
  * SpaceVPN:  ${local.vpn_port_forwarding_config}
PORT_FORWARDING_CONFIG

  bastion_description_non_wg = <<BASTION_DESCRIPTION
The Bastion instance runs the VPN service that can be used to
securely and anonymously access your cloud space resources and the
internet. You can download the VPN configuration along with the VPN
client software using the CloudBuilder CLI or the password protected
links below. The same user and password used to access the link 
should be used to login to the VPN if required.

${join("\n\n", local.users)}

${local.port_forwarding_config}
BASTION_DESCRIPTION
  bastion_description_wg = <<BASTION_DESCRIPTION
The Bastion space node runs the cloud space network mesh control 
services. It also provides a VPN service that can be used to
securely and anonymously connect to your cloud space to manage
cloud resources and applications. You will need to use the Cloud
Builder client to connect and use space resources securely.

${local.port_forwarding_config}
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
      "id": var.name
      "name": "bastion"
      "description": local.bastion_description
      "fqdn": local.endpoint
      "public_ip": local.bastion_info.ip # use private IP as instance should be accessed only from within the LAN
      "private_ip": local.bastion_info.ip
      "health_check_port": var.bastion_admin_api_port
      "health_check_type": "tcp"
      "api_port": var.bastion_admin_api_port
      "ssh_port": var.bastion_admin_ssh_port
      "ssh_user": local.bastion_admin_user 
      "ssh_key": module.config.bastion_admin_sshkey
      "root_user": "bastion-admin" 
      "root_passwd": module.config.bastion_admin_password
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
VPN Type: ${local.vpn_type_name}
Version: ${local.version}
NODE_DESCRIPTION
}

output "cb_node_version" {
  value = local.version
}

output "cb_root_ca_cert" {
  value = module.config.root_ca_cert
}

output "cb_vpc_id" {
  value = "" #module.bootstrap.vpc_id
}

output "cb_vpc_name" {
  value = local.space_domain
}

output "cb_deployment_networks" {
  value = [local.network_env.defaultNetwork]
}

output "cb_deployment_security_group" {
  value = "" #module.bootstrap.admin_security_group
}

output "cb_default_ssh_private_key" {
  sensitive = true
  value = "" #module.bootstrap.default_openssh_private_key
}

output "cb_default_ssh_key_pair" {
  value = "" #module.bootstrap.default_ssh_key_pair
}

output "cb_dns_configured" {
  value = local.configure_dns
}

output "cb_internal_domain" {
  value = local.space_internal_domain
}

output "cb_internal_pdns_url" {
  value = "" #module.bootstrap.powerdns_url
}

output "cb_internal_pdns_api_key" {
  value     = module.config.powerdns_api_key
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
