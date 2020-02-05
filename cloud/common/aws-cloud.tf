#
# AWS Provider
#
provider "aws" {}

#
# Backend state
#
terraform {
  backend "s3" {}
}
