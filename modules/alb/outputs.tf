# ALB Module - Outputs Configuration
# Define outputs that other modules or root configuration can use

output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = aws_lb.main_alb.id
}

output "alb_name" {
  description = "The name of the Application Load Balancer"
  value       = aws_lb.main_alb.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.main_alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main_alb.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main_alb.zone_id
}

output "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.main_alb.arn_suffix
}

output "web_tier_target_group_id" {
  description = "The ID of the web tier target group"
  value       = aws_lb_target_group.web_tier_tg.id
}

output "web_tier_target_group_arn" {
  description = "The ARN of the web tier target group"
  value       = aws_lb_target_group.web_tier_tg.arn
}

output "web_tier_target_group_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.web_tier_tg.arn_suffix
}

output "app_tier_target_group_id" {
  description = "The ID of the app tier target group (if enabled)"
  value       = var.enable_app_tier ? aws_lb_target_group.app_tier_tg[0].id : null
}

output "app_tier_target_group_arn" {
  description = "The ARN of the app tier target group (if enabled)"
  value       = var.enable_app_tier ? aws_lb_target_group.app_tier_tg[0].arn : null
}

output "app_tier_target_group_arn_suffix" {
  description = "The ARN suffix of the app tier target group for CloudWatch (if enabled)"
  value       = var.enable_app_tier ? aws_lb_target_group.app_tier_tg[0].arn_suffix : null
}

output "http_listener_id" {
  description = "The ID of the HTTP listener"
  value       = aws_lb_listener.http_listener.id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http_listener.arn
}

output "https_listener_id" {
  description = "The ID of the HTTPS listener (if enabled)"
  value       = var.enable_https ? aws_lb_listener.https_listener[0].id : null
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener (if enabled)"
  value       = var.enable_https ? aws_lb_listener.https_listener[0].arn : null
}

output "alb_security_groups" {
  description = "Security groups attached to the ALB"
  value       = aws_lb.main_alb.security_groups
}

output "alb_subnets" {
  description = "Subnets attached to the ALB"
  value       = aws_lb.main_alb.subnets
}

output "target_group_arns" {
  description = "ARNs of all target groups created by this module"
  value = compact([
    aws_lb_target_group.web_tier_tg.arn,
    var.enable_app_tier ? aws_lb_target_group.app_tier_tg[0].arn : ""
  ])
}
