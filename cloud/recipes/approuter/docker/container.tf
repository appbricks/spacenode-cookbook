#
# Deploy MyCS app container with app routes
#

locals {
  approuter_name = random_id.mycs-app.hex
  
  mycs_app_data_dir = (local.is_windows
    ? "${local.paths_env.globalDataDir}\\mycs\\approuter\\${var.name}"
    : "${local.paths_env.globalDataDir}/mycs/approuter/${var.name}"
  )
}

resource "docker_container" "mycs-app" {
  name  = local.approuter_name
  image = docker_image.mycs-app.image_id

  privileged = true
  restart    = "on-failure"

  volumes {
    container_path = "/var/lib/mycs/apps/${var.name}"
    host_path = local.mycs_app_data_dir
  }

  # upload mycs-app config files to container
  dynamic "upload" {
    for_each = module.app-config.app_config_files
    content {
      file    = upload.key
      content = upload.value
    }
  }  
}

resource "docker_image" "mycs-app" {
  name = "appbricks/mycs-node:${var.mycs_node_version}"
  keep_locally = true
}

resource "random_id" "mycs-app" {
  prefix      = "${var.name}-"
  byte_length = 8
}

resource "local_file" "mycs-app" {
  content  = <<EOT
  MyCS Application Router
  =======================
  
  Name: ${var.name}
  Description: ${var.description}
  Container: ${local.approuter_name}
  EOT

  filename = "${local.mycs_app_data_dir}/README"
}
