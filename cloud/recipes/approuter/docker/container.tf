#
# Deploy MyCS app container with app routes
#

locals {
  approuter_name = random_id.mycsnode.hex
}

resource "docker_container" "mycsnode" {
  name  = local.approuter_name
  image = docker_image.mycsnode.image_id

  privileged = true
  restart    = "on-failure"

  # upload mycs-app config files to container
  dynamic "upload" {
    for_each = module.app-config.app_config_files
    content {
      file    = upload.key
      content = upload.value
    }
  }  
}

resource "docker_image" "mycsnode" {
  name = "appbricks/mycs-node:${var.mycsnode_version}"
  keep_locally = true
}

resource "random_id" "mycsnode" {
  prefix      = "${var.name}-"
  byte_length = 8
}
