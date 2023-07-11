#
# Docker Provider
#
provider "docker" {}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.25.0"
    }
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
  }
  backend "local" {}
}
