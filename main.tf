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
}# main.tf (root)
module "iam" {
  source = "./modules/iam"
}

output "iam_ec2_instance_profile" {
  value = module.iam.ec2_instance_profile_name
}
