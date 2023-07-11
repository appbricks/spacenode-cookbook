#
# MyCS Application configuration
#

module "app-config" {
  source = "github.com/appbricks/cloud-inceptor.git/modules/app-config"

  mycs_cloud_public_key_id = var.mycs_cloud_public_key_id
  mycs_cloud_public_key = var.mycs_cloud_public_key
  mycs_app_private_key = var.mycs_app_private_key
  mycs_app_id_key = var.mycs_app_id_key
  mycs_app_version = var.mycs_app_version
  mycs_space_ca_root = var.cb_root_ca_cert

  mycs_app_data_dir = local.mycs_app_data_dir

  advertised_external_networks = (
    length(var.advertised_external_networks) == 0 
    ? [] 
    : split(",", var.advertised_external_networks)
  )
  advertised_external_domain_names = (
    length(var.advertised_external_domain_names) == 0 
    ? [] 
    : split(",", var.advertised_external_domain_names)
  )

  app_description = "${var.description}"
  app_domain_name = "${var.name}.${var.cb_internal_domain}"
}
