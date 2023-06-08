#
# Launch bastion vm on virtualbox using vagrant 
#

locals {
  # vagrant file path
  vagrant_file = (local.is_windows
    ? "${var.cb_local_state_path}\\bastion\\Vagrantfile"
    : "${var.cb_local_state_path}/bastion/Vagrantfile"
  )
  cloud_config_file = (local.is_windows
    ? "${var.cb_local_state_path}\\bastion\\cloud-config.dat"
    : "${var.cb_local_state_path}/bastion/cloud-config.dat"
  )

  # split image name into name and version and determine vagrant image src an version
  image_name_parts = split("_", var.bastion_image_name)
  bastion_box_name = "appbricks/${element(local.image_name_parts, 0)}"
  bastion_box_version = (startswith(element(local.image_name_parts, 1), "D.") 
    ? "0.0.${element(split(".", element(local.image_name_parts, 1)), 1)}"
    : element(local.image_name_parts, 1)
  )

  # data disk path
  data_disk_path = (local.is_windows
    ? "${local.local_state_path}\\bastion\\data.vdi"
    : "${var.cb_local_state_path}/bastion/data.vdi"
  )

  # host network info file path
  host_network_path = (local.is_windows_fs 
    ? "${local.local_state_path}\\bastion\\host_network.json" 
    : "${var.cb_local_state_path}/bastion/host_network.json"
  )

  # bastion vm info
  bastion_info = jsondecode(shell_script.vagrant-bastion.output.vminfo)
}

resource "shell_script" "vagrant-bastion" {
  lifecycle_commands {
    create = "${local.vagrant_exec_cli} -info=${local.host_network_path} -timeout=1800 up"
    delete = "${local.vagrant_exec_cli} destroy -f"
  }
  lifecycle {
    precondition {
      condition     = length(data.shell_script.system-env.output.error) == 0
      error_message = "Error retrieving system information: ${data.shell_script.system-env.output.error}"
    }
    precondition {
      condition     = local.tools_env.vboxInstalled == "true"
      error_message = "VirtualBox (https://www.virtualbox.org/wiki/Downloads) needs to be installed:\n  ${join("\n  *", local.system_msgs)}"
    }
    precondition {
      condition     = local.tools_env.vagrantInstalled == "true"
      error_message = "Vagrant (https://developer.hashicorp.com/vagrant/docs/installation) need needs to be installed:\n  ${join("\n  *", local.system_msgs)}"
    }    
  }

  working_directory = dirname(local_file.vagrant-file.filename)

  environment = {
    VAGRANT_EXPERIMENTAL = "cloud_init,disks"
  }

  triggers = {
    when_value_changed = local_file.vagrant-file.content_sha1
  }

  depends_on = [
    local_file.cloud-config-file,
    shell_script.bastion-data
  ]
}

resource "local_file" "vagrant-file" {
  content  = templatefile(
    "${path.module}/Vagrantfile",
    {
      bastion_box_name = local.bastion_box_name
      bastion_box_version = local.bastion_box_version
      def_bridge_name = local.vbox_env.defaultBridge
      data_disk_path = local.data_disk_path
      cloud_config_path = local.cloud_config_file
      bastion_vm_name = var.name
      bastion_memory_size = var.bastion_memory_size
      bastion_admin_ssh_port = var.bastion_admin_ssh_port

      vboxmanage_exec_cli = local.vboxmanage_exec_cli
    }
  )

  filename = local.vagrant_file

  lifecycle {
    precondition {
      condition     = length(data.shell_script.system-env.output.error) == 0
      error_message = "Error retrieving system information: ${data.shell_script.system-env.output.error}"
    }
    precondition {
      condition     = local.tools_env.vboxInstalled == "true"
      error_message = "VirtualBox (https://www.virtualbox.org/wiki/Downloads) needs to be installed:\n  ${join("\n  *", local.system_msgs)}"
    }
    precondition {
      condition     = length(local.vbox_env.defaultBridge) > 0
      error_message = "Unable to determine default bridge for Virtual Box."
    }
  }

  depends_on = [
    shell_script.bastion-data
  ]
}

resource "local_file" "cloud-config-file" {
  content  = module.config.bastion_cloud_init_config_raw
  filename = local.cloud_config_file
}

resource "shell_script" "bastion-data" {

  lifecycle_commands {
    create = "${local.vboxmanage_exec_cli} createmedium disk --filename ${local.data_disk_path} --size 20000 --format vdi"
    delete = "${local.vboxmanage_exec_cli} closemedium disk ${local.data_disk_path} --delete"
  }
}
