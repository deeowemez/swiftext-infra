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
  appserver_sg_id        = module.vpc.security_group_appserver
  bastion_sg_id          = module.vpc.security_group_bastion
  # iam_instance_profile   = module.iam.iam_instance_profile
}

module "alb" {
  source                 = "./alb"
  vpc_id                 = module.vpc.vpc_id
  appserver_instance_ids = module.ec2.appserver_instance_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_sg_id              = module.vpc.security_group_alb
}

module "efs" {
  source                 = "./efs"
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
}


module "rds" {
  source                    = "./rds"
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  security_group_dataserver = module.vpc.security_group_dataserver
  availability_zones        = module.vpc.availability_zones
}

module "s3" {
  source = "./s3"
}

# module "iam" {
#   source = "./iam"
# }
