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
}

module "ec2" {
  source                 = "./ec2"
  vpc_id                 = module.vpc.vpc_id
  availability_zones     = module.vpc.availability_zones
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  appserver_instance_ids = module.ec2.appserver_instance_ids
}

module "alb" {
  source                 = "./alb"
  vpc_id                 = module.vpc.vpc_id
  appserver_instance_ids = module.ec2.appserver_instance_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_sg_id              = module.vpc.security_group_alb
}

module "s3" {
  source = "./s3"
}