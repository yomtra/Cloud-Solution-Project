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
variable "vpc_id" {
  description = "VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "private_subnet_3_id" {
  description = "Private Subnet ID for RDS Primary (e.g., 10.64.0.0/24)"
  type        = string
}

variable "private_subnet_4_id" {
  description = "Private Subnet ID for RDS Read Replica (e.g., 10.80.0.0/24)"
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