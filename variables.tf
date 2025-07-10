variable "aws_region" {
  default     = "us-west-1"
  description = "AWS region to deploy resources"
}

variable "aws_profile" {
  default     = "default"
  description = "AWS CLI named profile"
}
variable "project" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "web_subnet_cidrs" {}
variable "app_subnet_cidrs" {}
variable "db_subnet_cidrs" {}
variable "enable_nat_gateway" {}
variable "tags" {
  type    = map(string)
  default = {}
}