module "network" {
  source = "../../modules/network"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
  availability_zones  = var.availability_zones
}

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.network.vpc_id
  admin_cidr  = var.admin_cidr
}

module "data" {
  source = "../../modules/data"

  environment       = var.environment
  db_subnet_ids     = module.network.db_subnet_ids
  db_sg_id          = module.security.db_sg_id
  db_instance_class = var.db_instance_class
  db_name           = var.db_name
}

module "compute" {
  source = "../../modules/compute"

  environment        = var.environment
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  app_subnet_ids     = module.network.app_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  app_sg_id          = module.security.app_sg_id
  bastion_sg_id      = module.security.bastion_sg_id
  instance_type      = var.instance_type
  key_pair_name      = var.key_pair_name
  s3_bucket_name     = var.s3_bucket_name
  asg_min_size       = var.asg_min_size
  asg_desired_size   = var.asg_desired_size
  asg_max_size       = var.asg_max_size
  asg_cpu_target     = var.asg_cpu_target
}
