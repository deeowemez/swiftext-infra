terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.15.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "postgresql" {
  host     = module.rds.rds_instance_address
  port     = 5432
  username = module.rds.rds_instance_username
  password = module.rds.rds_instance_password
  sslmode  = "disable"
}