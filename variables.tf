variable "aws_region" {
  default     = "us-west-1"
  description = "AWS region to deploy resources"
}

variable "aws_profile" {
  default     = "default"
  description = "AWS CLI named profile"
}
variable "project" {
  description = "Project name"
  type        = string
  default     = "gogreen-insurance"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidrs" {
  description = "Web subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "App subnet CIDR blocks" 
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}
variable "notification_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = "admin@example.com" 
}