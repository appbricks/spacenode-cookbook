#
# Azure Provider
#
# Limit version of Azure provider to avoid image copy issue
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/4361
#
provider "azurerm" {
  # version = "< 1.34.0"
}

#
# Backend state
#
terraform {
  backend "azurerm" {}
}
