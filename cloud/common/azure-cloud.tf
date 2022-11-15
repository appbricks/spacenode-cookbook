#
# Azure Provider
#
provider "azurerm" {
  features {}
}

#
# Backend state
#
terraform {
  backend "azurerm" {}
}
