#
# Minecraft Instance
#

resource "aws_instance" "minecraft" {

  instance_type = var.minecraft_instance_type
  ami           = data.aws_ami.ubuntu.id
  key_name      = var.cb_default_ssh_key_pair
  subnet_id     = data.aws_subnet.deployment.id

  vpc_security_group_ids = [var.cb_deployment_security_group]

  iam_instance_profile = aws_iam_instance_profile.minecraft.id

  tags = {
    Name = "${var.cb_vpc_name}: ${var.name} server"
  }

  user_data = <<USERDATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.minecraft-install.rendered)}
  path: /tmp/install.sh
  permissions: '0744'

- encoding: b64
  content: ${base64encode(data.template_file.minecraft-idle-shutdown.rendered)}
  path: /tmp/idle_shutdown.sh
  permissions: '0744'

- encoding: b64
  content: ${base64encode(data.template_file.minecraft-update-dns.rendered)}
  path: /tmp/update_dns.sh
  permissions: '0744'  

runcmd: 
- /tmp/install.sh

USERDATA
}

#
# IAM Role for Minecraft server
#

resource "aws_iam_role" "minecraft" {
  name   = "${var.cb_vpc_name}-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "minecraft" {
  name = "${var.cb_vpc_name}-${var.name}"
  role = aws_iam_role.minecraft.name
}

#
# Ubuntu AMI
#

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#
# Scripts
#

data "template_file" "minecraft-install" {
  template = file("${path.module}/install.sh")

  vars = {
    mc_description = var.minecraft_server_description

    mc_root        = local.minecraft_root
    mc_version     = var.minecraft_version
    mc_type        = var.minecraft_type
    mc_port        = var.minecraft_port
    mc_backup_freq = var.minecraft_backup_frequency

    java_mx_mem    = var.java_mx_mem
    java_ms_mem    = var.java_ms_mem

    mc_bucket      = aws_s3_bucket.minecraft.bucket
  }
}

data "template_file" "minecraft-idle-shutdown" {
  template = file("${path.module}/idle_shutdown.sh")

  vars = {
    mc_root = local.minecraft_root
  }
}

data "template_file" "minecraft-update-dns" {
  template = file("${path.module}/update_dns.sh")

  vars = {
    mc_dns_name    = "${var.name}.${var.cb_internal_domain}"
    dns_zone       = var.cb_internal_domain
    pdns_url       = var.cb_internal_pdns_url
    pdns_api_key   = var.cb_internal_pdns_api_key
  }
}
