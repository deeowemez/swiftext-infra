terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source             = "./vpc"
  base_cidr_block    = var.base_cidr_block
  availability_zones = var.availability_zones
}