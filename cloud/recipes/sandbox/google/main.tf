#
# Bootstrap VPN server
#

module "bootstrap" {
  source = "github.com/appbricks/cloud-inceptor.git/modules/bootstrap/google"

  #
  # Company information used in certificate creation
  #
  company_name      = var.company_name
  organization_name = var.organization_name
  locality          = var.locality
  province          = var.province
  country           = var.country

  #
  # MyCS node keys
  #
  mycs_node_private_key = var.mycs_node_private_key
  mycs_node_id_key = var.mycs_node_id_key

  #
  # VPC details
  #
  region = var.region

  # Name of VPC will be used to identify 
  # VPC specific cloud resources
  vpc_name = lower("${var.name}-${var.region}")

  # DNS Name for VPC
  vpc_dns_zone    = lower("${var.name}-${var.vpn_type}-${var.region}.${var.google_dns_zone}")
  attach_dns_zone = local.configure_dns

  # Name of parent zone 'gcp.appbricks.cloud' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "${length(var.google_dns_managed_zone_name) == 0
    ? replace(var.google_dns_zone, ".", "-")
    : var.google_dns_managed_zone_name }"

  # Local DNS zone. This could also be the same as the public
  # which will enable setting up a split DNS of the public zone
  # for names to map to external and internal addresses.
  vpc_internal_dns_zones = ["local"]

  # VPN
  vpn_users = split(",", var.vpn_users)

  vpn_type               = local.vpn_type
  vpn_idle_action        = var.idle_action  
  vpn_idle_shutdown_time = var.idle_shutdown_time
  vpn_tunnel_all_traffic = "yes"

  ovpn_service_port = local.vpn_type == "openvpn" ? var.ovpn_service_port : ""
  ovpn_protocol     = local.vpn_type == "openvpn" ? var.ovpn_protocol : ""

  # Tunnel for VPN to handle situations where 
  # OpenVPN is blocked or throttled by ISP.
  tunnel_vpn_port_start = local.tunnel_vpn_port_start
  tunnel_vpn_port_end   = local.tunnel_vpn_port_end

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = true

  bastion_host_name = "vpn"
  bastion_use_fqdn  = local.configure_dns

  bastion_admin_user = "mycs-admin"

  bastion_instance_type = var.bastion_instance_type

  bastion_use_project_image = false
  bastion_image_name        = var.bastion_image_name

  # Issue certificates from letsencrypt.org
  certify_bastion = var.certify_bastion

  # Whether to deploy a jumpbox in the admin network. The
  # jumpbox will be deployed only if a local DNS zone is
  # provided and the DNS will be jumpbox.[first local zone].
  deploy_jumpbox = false
}
