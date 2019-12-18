#
# AWS Provider
#
provider "google" {}

#
# Backend state
#
terraform {
  backend "gcs" {}
}
