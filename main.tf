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