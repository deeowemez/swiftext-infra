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
  source = "./vpc"
  availability_zones = var.availability_zones
}

module "ec2" {
  source = "./ec2"
  availability_zones = var.availability_zones
}

module "s3" {
  source = "./s3"
}
