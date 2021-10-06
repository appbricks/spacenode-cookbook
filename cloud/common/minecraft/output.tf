#
# Output
#

#
# Create help/usage text for the node
#

locals {

  server_fqdn = "${var.name}.${var.cb_internal_domain}"
  
  minecraft_node_description = <<MINECRAFT_DESCRIPTION
The Minecraft instance runs a Minecraft cloud server within a Cloud
Space. The server is secured behind the Cloud Space's VPN and can 
only be accessed by users that have a Cloud Space account and have 
been granted access to the Minecraft service by the owner of the 
Cloud Space to which the Minecraft instance has been deployed.
The instance will periodically save its state securely to the Cloud. 
This allows the server to be shutdown when not in use and restarted 
without losing any worlds created for gameplay.
MINECRAFT_DESCRIPTION
}

#
# Output metadata for Cloud Builder framework
#

output "cb_managed_instances" {
  value = [
    {
      "order": 0
      "id": aws_instance.minecraft.id
      "name": "minecraft"
      "description": local.minecraft_node_description
      "fqdn": local.server_fqdn
      "public_ip": aws_instance.minecraft.public_ip
      "private_ip": aws_instance.minecraft.private_ip
      "api_port": ""
      "ssh_port": "22"
      "ssh_user": "ubuntu"
      "ssh_key": var.cb_default_openssh_private_key
      "root_user": ""
      "root_passwd": ""
      "non_root_user": ""
      "non_root_passwd": ""
    }
  ]
}

output "cb_node_description" {
  value = <<NODE_DESCRIPTION
This Minecraft instance has been deployed to the Cloud Space. It can
be accessed by logging in to the Cloud Space's VPN and looking up the
server via the private cloud server name given below.

Minecraft Server Network Name: ${local.server_fqdn}
NODE_DESCRIPTION
}

output "cb_node_version" {
  value = var.minecraft_version
}
