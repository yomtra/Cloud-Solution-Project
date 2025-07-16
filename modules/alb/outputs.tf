output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}
# Purpose: Provides the unique Amazon Resource Name (ARN) for the ALB
# Usage: Used by other AWS services and modules that need to reference this ALB
# Integration: Required for auto-scaling groups, CloudWatch alarms, and IAM policies
# Format: "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/name/id"

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}
# Purpose: Provides the public DNS name users can use to access the application
# Usage: This is the URL customers will use to reach the GoGreen Insurance website
# Example: "gogreen-alb-123456789.us-west-1.elb.amazonaws.com"
# Integration: Can be used with Route 53 for custom domain mapping
# Accessibility: This is the primary entry point for all user traffic

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.this.zone_id
}
# Purpose: Provides the AWS Route 53 hosted zone ID for the ALB
# Usage: Required for creating Route 53 alias records pointing to the ALB
# DNS Integration: Enables custom domain names (e.g., www.gogreeninsurance.com)
# Performance: Alias records provide better performance than CNAME records
# Automation: Allows programmatic DNS configuration with custom domains

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.this.arn
}
# Purpose: Provides the ARN of the target group for integration with other services
# Usage: Required by auto-scaling groups to automatically register/deregister instances
# Integration: Used by EC2 instances, ECS services, or Lambda functions as targets
# Monitoring: CloudWatch metrics and alarms reference this ARN for target health
# Automation: Enables dynamic scaling and deployment automation

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (if enabled)"
  value       = var.enable_https && var.ssl_certificate_arn != "" ? aws_lb_listener.https_frontend[0].arn : null
}
# Purpose: Provides the ARN of the HTTPS listener when SSL is enabled
# Usage: Required for advanced routing rules and listener rule configuration
# Conditional: Only returns value when HTTPS is actually configured
# Integration: Used by WAF, listener rules, and security configurations
# Automation: Enables programmatic SSL configuration management
