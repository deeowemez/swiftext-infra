resource "aws_vpc" "main" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}
