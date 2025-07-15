variable "project" {
  description = "Name of the project"
  type        = string
  default     = "go-green"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}



variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}



variable "availability_zones" {
  description = "List of availability zones to use (optional override)"
  type        = list(string)
  default     = []

}

variable "web_subnet_cidrs" {
  description = "List of CIDRs for web/public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "List of CIDRs for application/private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  description = "List of CIDRs for database/private subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}



variable "create_nat_gateway" {
  description = "Set to true to create a NAT Gateway for private subnets"
  type        = bool
  default     = true
}


variable "enable_default_sg_rules" {
  description = "Set to true to create basic SG rules for app and DB tiers"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
 