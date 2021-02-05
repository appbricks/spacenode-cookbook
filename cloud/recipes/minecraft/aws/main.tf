#
# Minecraft server
#

module "minecraft" {
  # source = "github.com/appbricks/terraform-aws-minecraft"
  source = "../../../../../../../../vpn/modules/terraform-aws-minecraft"

  associate_public_ip_address = false

  vpc_id        = var.cb_vpc_id
  instance_type = "t4g.medium"
  subnet_id     = var.cb_deployment_networks[0]

  bucket_name = "${var.cb_vpc_name}_games_minecraft"

  tags = {
    Name = "${var.cb_vpc_name}: minecraft"
  }
}
