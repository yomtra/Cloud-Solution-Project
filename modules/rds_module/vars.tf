# Jurabek: Added missing app_subnet_cidrs variable for RDS security group
variable "app_subnet_cidrs" {
  description = "List of app tier subnet CIDRs for RDS access"
  type        = list(string)
}

# Jurabek: Added missing region variable for RDS module
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "name" {
  description = "Name prefix for RDS resources"
  type        = string
  #value = "Gafur_test"
}

 
variable "engine" {
  default     = "mysql"
  type        = string
}
 
variable "engine_version" {
  default     = "8.0"
  type        = string
}
 
variable "instance_class" {
  description = "DB instance type (e.g., db.t3.micro)"
  type        = string
}
 
variable "allocated_storage" {
  default = 20
  type    = number
}
 
variable "username" {
  type        = string
}
 
variable "password" {
  type        = string
  sensitive   = true
}
 
variable "tags" {
  type    = map(string)
  default = {}
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}