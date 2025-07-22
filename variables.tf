variable "aws_region" {
  default     = "us-west-1"
  description = "AWS region to deploy resources"
}



variable "ami" {
  description = "AMI used for all ec2 instances"
  type = string
}
variable "aws_profile" {
  default     = "default"
  description = "AWS CLI named profile"
}
variable "project" {
  description = "project_name"
  type = string
}
variable "environment" {
  description = "Deployment environment"
  type = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}
variable "web_subnet_cidrs" {
  description = "list of CIDRs for web subnets"
  type = list(string)
}
variable "app_subnet_cidrs" {
   description = "list of CIDRs for app subnets"
  type = list(string)
}
variable "db_subnet_cidrs" { 
  description = "list of CIDRs for db subnets"
  type = list(string)
  
}


variable "enable_nat_gateway" {}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "name" {
  description = "RDS instance name prefix"
  type        = string
}

variable "instance_class" {
  description = "The instance class of the RDS"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., mysql)"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
}

variable "username" {
  description = "Master username for RDS"
  type        = string
}

variable "password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}

 