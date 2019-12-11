#
# Bootstrap VPN server
#

module "bootstrap" {
  source = "github.com/appbricks/cloud-inceptor.git/modules/bootstrap/google"

  #
  # Company information used in certificate creation
  #
  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  #
  # VPC details
  #
  region = "${var.region}"

  # Name of VPC will be used to identify 
  # VPC specific cloud resources
  vpc_name = "${var.name}-ovpn-${var.region}"

  # DNS Name for VPC
  vpc_dns_zone    = "${var.name}-ovpn-${var.region}.${var.google_dns_zone}"
  attach_dns_zone = "${local.configure_dns}"

  # Name of parent zone 'gcp.appbricks.cloud' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "${length(var.google_dns_managed_zone_name) == 0
    ? replace(var.google_dns_zone, ".", "-")
    : var.google_dns_managed_zone_name }"

  # Local DNS zone. This could also be the same as the public
  # which will enable setting up a split DNS of the public zone
  # for names to map to external and internal addresses.
  vpc_internal_dns_zones = ["local"]

  # Local file path to write SSH private key for bastion instance
  ssh_key_file_path = "${length(var.ssh_key_file_path) > 0 ? var.ssh_key_file_path : path.cwd}"

  # VPN
  vpn_users = "${var.vpn_users}"

  vpn_type               = "openvpn"
  vpn_tunnel_all_traffic = "yes"

  ovpn_server_port = "4495"
  ovpn_protocol    = "udp"

  vpn_idle_action = "${var.vpn_idle_action}"

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = true

  bastion_host_name = "vpn"
  bastion_use_fqdn  = "${local.configure_dns}"

  bastion_instance_type = "${var.bastion_instance_type}"

  # Issue certificates from letsencrypt.org
  certify_bastion = "${var.certify_bastion}"

  # Whether to deploy a jumpbox in the admin network. The
  # jumpbox will be deployed only if a local DNS zone is
  # provided and the DNS will be jumpbox.[first local zone].
  deploy_jumpbox = false
}

#
# Backend state
#
terraform {
  backend "gcs" {}
}
