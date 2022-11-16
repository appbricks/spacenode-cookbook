#
# Azure Provider
#
provider "azurerm" {
  use_msi = true
  features {}
}

#
# Backend state
#
terraform {
  backend "azurerm" {}
}
