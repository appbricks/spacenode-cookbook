#
# AWS Provider
#
provider "aws" {
  # region = var.region
}

#
# Backend state
#
terraform {
  backend "s3" {}
}
