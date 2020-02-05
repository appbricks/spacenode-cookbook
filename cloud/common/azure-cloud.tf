#
# Azure Provider
#
provider "azurerm" {}

#
# Backend state
#
terraform {
  backend "azurerm" {}
}
