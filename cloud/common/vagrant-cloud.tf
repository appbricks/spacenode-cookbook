#
# Shell Provider for shell commands 
# to create configs and run vagrant 
#
provider "shell" {}

terraform {
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
  }
  backend "local" {}
}

data "shell_script" "system-env" {
  lifecycle_commands {
    read = "${local.system_env_cli}"
  }
} 

locals {
  # directories start with "C:..." on Windows; All other OSs use "/" for root.
  is_windows_fs = substr(pathexpand("~"), 0, 1) == "/" ? false : true

  abs_module_path = local.is_windows_fs ? replace(abspath(path.module), "/", "\\") : abspath(path.module)
  local_state_path = local.is_windows_fs ? replace(var.cb_local_state_path, "/", "\\") : var.cb_local_state_path

  system_env_cli = local.is_windows_fs ? "${local.abs_module_path}\\system-env.exe" : "${local.abs_module_path}/system-env"
  vagrant_exec_cli = local.is_windows_fs ? "${local.abs_module_path}\\vagrant-exec.exe" : "${local.abs_module_path}/vagrant-exec"
  vboxmanage_exec_cli = local.is_windows_fs ? "${local.abs_module_path}\\vboxmanage-exec.exe" : "${local.abs_module_path}/vboxmanage-exec"

  is_windows  = data.shell_script.system-env.output.os == "windows"
  network_env = jsondecode(data.shell_script.system-env.output.network)
  tools_env   = jsondecode(data.shell_script.system-env.output.tools)
  vbox_env    = jsondecode(data.shell_script.system-env.output.vbox)
  system_msgs = jsondecode(data.shell_script.system-env.output.msgs)
}
