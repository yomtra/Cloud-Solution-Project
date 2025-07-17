provider "aws" {
  region = "us-west-1"
}
module "vpc" {
  source           = "./modules/vpc"
  project          = var.project
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  web_subnet_cidrs = var.web_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  notification_emails = [] 
  web_instance_ids = [] 
  alb_name_ids = [] 
}

module "rds" {
  source              = "./modules/rds_module"
  name                = var.name
  instance_class      = var.instance_class
  engine              = var.engine
  engine_version      = var.engine_version
  allocated_storage   = var.allocated_storage
  username            = var.username
  password            = var.password
  db_subnet_ids       = module.vpc.db_subnet_ids
  vpc_id              = module.vpc.vpc_id
  environment         = var.environment
  project             = var.project
  tags                = var.tags
}
