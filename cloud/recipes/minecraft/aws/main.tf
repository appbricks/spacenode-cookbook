#
# Lookup deployment resources
#

data "aws_vpc" "deployment" {
  id = var.cb_vpc_id
}

data "aws_subnet" "deployment" {
  id = var.cb_deployment_networks[0]
  vpc_id = data.aws_vpc.deployment.id
}
