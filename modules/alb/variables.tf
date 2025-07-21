# ALB Module - Variables Configuration
# Define all input variables for the ALB module

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.alb_name))
    error_message = "ALB name must be alphanumeric and can contain hyphens, but cannot start or end with a hyphen."
  }
}

variable "internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to the ALB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ALB will be deployed"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "ALB requires at least 2 subnets in different Availability Zones."
  }
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target groups will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project for tagging purposes"
  type        = string
  default     = "cloud-solution-project"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Deletion Protection
variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

# Access Logs Configuration
variable "enable_access_logs" {
  description = "Enable access logs for the ALB"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 bucket prefix for ALB access logs"
  type        = string
  default     = "alb-access-logs"
}

# Web Tier Configuration
variable "web_tier_port" {
  description = "Port for the web tier target group"
  type        = number
  default     = 80
}

variable "web_tier_protocol" {
  description = "Protocol for the web tier target group"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.web_tier_protocol)
    error_message = "Web tier protocol must be HTTP or HTTPS."
  }
}

# App Tier Configuration
variable "enable_app_tier" {
  description = "Enable app tier target group and routing"
  type        = bool
  default     = false
}

variable "app_tier_port" {
  description = "Port for the app tier target group"
  type        = number
  default     = 8080
}

variable "app_tier_protocol" {
  description = "Protocol for the app tier target group"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.app_tier_protocol)
    error_message = "App tier protocol must be HTTP or HTTPS."
  }
}

variable "app_tier_path_patterns" {
  description = "Path patterns for app tier routing"
  type        = list(string)
  default     = ["/api/*", "/app/*"]
}

variable "app_tier_rule_priority" {
  description = "Priority for app tier listener rule"
  type        = number
  default     = 100
}

variable "app_health_check_path" {
  description = "Health check path for app tier"
  type        = string
  default     = "/health"
}

# Health Check Configuration
variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required"
  type        = number
  default     = 2
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
}

variable "health_check_interval" {
  description = "Interval between health checks (in seconds)"
  type        = number
  default     = 30
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout (in seconds)"
  type        = number
  default     = 5
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
}

variable "health_check_path" {
  description = "Health check path for web tier"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP status codes that indicate a healthy target"
  type        = string
  default     = "200"
}

# Stickiness Configuration
variable "enable_stickiness" {
  description = "Enable session stickiness"
  type        = bool
  default     = false
}

variable "stickiness_duration" {
  description = "Duration of session stickiness (in seconds)"
  type        = number
  default     = 86400
  validation {
    condition     = var.stickiness_duration >= 1 && var.stickiness_duration <= 604800
    error_message = "Stickiness duration must be between 1 and 604800 seconds (7 days)."
  }
}

# HTTPS/SSL Configuration
variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}
