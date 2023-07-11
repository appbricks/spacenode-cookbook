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
    macaddress = {
      source = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
  backend "local" {}
}
