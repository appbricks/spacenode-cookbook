module "config" {
  source = "github.com/appbricks/cloud-inceptor.git/modules/bastion-config"

  mycs_node_private_key = var.mycs_node_private_key
  mycs_node_id_key      = var.mycs_node_id_key

  company_name      = var.company_name
  organization_name = var.organization_name
  locality          = var.locality
  province          = var.province
  country           = var.country

  root_ca_key  = ""
  root_ca_cert = ""

  cert_domain_names = local.cert_domain_names

  vpc_name                 = local.space_domain
  vpc_cidr                 = local.network_env.defaultNetwork
  vpc_dns_zone             = lower("${local.space_domain}.mycs")
  vpc_internal_dns_zones   = ["mycs", local.space_internal_domain]
  vpc_internal_dns_records = []

  bastion_use_fqdn  = true
  bastion_fqdn      = "vagrant"
  bastion_public_ip = local.network_env.publicIP

  certify_bastion = false
  
  bastion_dns = join(",", local.network_env.nameservers)

  bastion_dmz_itf_ip   = local.network_env.gatewayIP
  bastion_admin_itf_ip = ""

  bastion_nic_config = (
    length(var.bastion_static_ip) > 0 
      ? [ 
          "x", // exclude the first interface which is the vagrant NAT interface
          join("|", 
            tolist([
              var.bastion_static_ip,
              local.network_env.defaultNetwork,
              "0.0.0.0/0",
              local.network_env.gatewayIP
            ]),
          )
        ]
      : [ 
          "x", // exclude the first interface which is the vagrant NAT interface
          join("|", 
            tolist([
              "", // IP assigned via DHCP
              local.network_env.defaultNetwork,
              "0.0.0.0/0"
            ]),
          )
        ]
  )

  data_volume_name = "sdc"
  shared_external_folder = "/vagrant"

  bastion_admin_api_port = var.bastion_admin_api_port
  bastion_admin_ssh_port = var.bastion_admin_ssh_port
  bastion_admin_user     = local.bastion_admin_user
  squidproxy_server_port = ""

  vpn_type               = local.vpn_type
  vpn_network            = local.vpn_network
  vpn_restricted_network = local.vpn_restricted_network
  vpn_tunnel_all_traffic = "yes"
  vpn_idle_action        = var.idle_action
  vpn_idle_shutdown_time = var.idle_shutdown_time
  vpn_users              = local.vpn_users

  ovpn_service_port = local.vpn_type == "openvpn" ? var.ovpn_service_port : ""
  ovpn_protocol     = local.vpn_type == "openvpn" ? var.ovpn_protocol : ""

  tunnel_vpn_port_start = local.tunnel_vpn_port_start
  tunnel_vpn_port_end   = local.tunnel_vpn_port_end

  wireguard_service_port = var.wireguard_service_port
  wireguard_subnet_ip    = local.wireguard_subnet_ip

  derp_stun_port = var.derp_stun_port

  smtp_relay_host    = ""
  smtp_relay_port    = ""
  smtp_relay_api_key = ""

  concourse_server_port    = ""
  concourse_admin_password = ""
  bootstrap_pipeline_file  = ""

  pipeline_automation_path = ""
  notification_email       = ""

  bootstrap_pipeline_vars = ""

  compress_cloudinit = false
}

locals {
  # Bastion config
  bastion_admin_user = "mycs-admin"

  # VPN network attribs
  vpn_network             = "192.168.111.0/24"
  vpn_protected_sub_range = 2
  wireguard_mesh_network  = "192.168.112.0/24"
  wireguard_mesh_node     = 1
  # Partitioning the vpn range into a range of ips that 
  # are protected by the DNS sink hole vs ips that are 
  # in open can only be done for the wireguard vpn type.
  vpn_restricted_network = (
    local.vpn_type == "wireguard" 
      ? cidrsubnet(
          local.vpn_network, 
          local.vpn_protected_sub_range, 
          pow(2, local.vpn_protected_sub_range)-1
        )
      : local.vpn_network
  )

  # Wireguard will be configured for use as a mesh between
  # peered VPC if VPN type to connected client is different.
  # For such cases wireguard must have network range that
  # is separate from the vpn range.
  #
  # TBD - this does not allow a wireguard client VPN to be 
  # setup alongside the mesh. To allow a mesh configuration
  # the mesh setup needs to be separate from the vpn config
  #
  # https://github.com/appbricks/cloud-inceptor/issues/1
  #
  # This featue may be discontinued as space nodes should 
  # be linked via the tailscale net.
  #
  #
  wireguard_subnet_ip = (
    local.vpn_type == "wireguard" 
      ? "${cidrhost(local.vpn_network, 1)}/${split("/", local.vpn_network)[1]}"
      : "${cidrhost(local.wireguard_mesh_network, local.wireguard_mesh_node)}/${split("/", local.wireguard_mesh_network)[1]}"
  )
  # If the bastion has been allocated an elastic IP then 
  # return that. Otherwise pass an indicator in the field
  # so the bastion startup script can attempt to introspect
  # its externally facing Ip.
  cert_domain_names = [
    "*.mycloudspace.io",    // <spaceid>.mycloudspace.io
    "*.mycs.appbricks.org", // lookup ip by IP DNS - 1-1-1-1.mycs.appbricks.org        
    local.space_internal_domain
  ]
}
