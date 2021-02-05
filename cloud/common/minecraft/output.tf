#
# Output
#

#
# Create help/usage text for the node
#

locals {
  
  minecraft_node_description = <<MINECRAFT_DESCRIPTION
The Minecraft instance runs a Minecraft server that periodically
saves its state to s3. This allows the server to be shutdown when
not in use and restarted without losing any worlds created for
gameplay.
MINECRAFT_DESCRIPTION
}

#
# Output metadata for Cloud Builder framework
#

output "cb_managed_instances" {
  value = [
    {
      "order": 0
      "vpc_name": var.cb_vpc_name
      "name": "minecraft"
      "description": local.minecraft_node_description
      "id": module.minecraft.instance_id
      "fqdn": ""
      "public_ip": ""
      "private_ip": module.minecraft.private_ip
      "ssh_port": "22"
      "ssh_user": "ec2-user"
      "ssh_key": module.minecraft.ssh_key
      "root_passwd": ""
    }
  ]
}

output "mc_port" {
  value = module.minecraft.port
}
