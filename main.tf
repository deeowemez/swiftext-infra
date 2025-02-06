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
  efs_id                 = module.efs.aws_efs_file_system_id
  rds_instance_endpoint  = module.rds.rds_instance_endpoint
  git_username           = var.git_username
  git_pat                = var.git_pat
  db_password            = var.db_password
  jwt_secret             = var.jwt_secret
  depends_on             = [module.efs, module.rds]
  # depends_on            = [module.rds]
}

module "alb" {
  source                 = "./alb"
  vpc_id                 = module.vpc.vpc_id
  appserver_instance_ids = module.ec2.appserver_instance_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_sg_id              = module.vpc.security_group_alb
  depends_on             = [module.ec2, module.vpc]
}

module "efs" {
  source                 = "./efs"
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  efsmount_sg_id         = module.vpc.security_group_efsmount
}

module "rds" {
  source                    = "./rds"
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  security_group_dataserver = module.vpc.security_group_dataserver
  availability_zones        = module.vpc.availability_zones
}

# module "s3" {
#   source = "./s3"
# }

# module "iam" {
#   source = "./iam"
# }
