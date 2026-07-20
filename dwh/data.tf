data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

locals {
  public_subnet_map  = { for index, cidr in var.public_subnets : index => cidr }
  private_subnet_map = { for index, cidr in var.private_subnets : index => cidr }
  bucket_prefix      = "${var.name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}
