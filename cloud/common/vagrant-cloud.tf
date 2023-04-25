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
    read = "${path.module}/system-env"
  }
} 

locals {
  is_windows  = data.shell_script.system-env.output.os == "windows"
  network_env = jsondecode(data.shell_script.system-env.output.network)
  tools_env   = jsondecode(data.shell_script.system-env.output.tools)
  vbox_env    = jsondecode(data.shell_script.system-env.output.vbox)
  system_msgs = jsondecode(data.shell_script.system-env.output.msgs)
}
