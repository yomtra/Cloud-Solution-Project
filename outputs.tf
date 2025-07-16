output "vpc_id" {
  value = module.vpc.vpc_id
}

output "web_subnet_ids" {
  value = module.vpc.web_subnet_ids
}

output "app_subnet_ids" {
  value = module.vpc.app_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "web_nacl_id" {
  value = module.vpc.web_nacl_id
}

output "app_nacl_id" {
  value = module.vpc.app_nacl_id
}

output "db_nacl_id" {
  value = module.vpc.db_nacl_id
}

# S3 bucket outputs
output "s3_bucket_id" {
  value = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_bucket.bucket_arn
}

# ALB outputs
output "alb_dns_name" {
  value = module.application_load_balancer.alb_dns_name
}

output "alb_arn" {
  value = module.application_load_balancer.alb_arn
}

output "target_group_arn" {
  value = module.application_load_balancer.target_group_arn
}

# CloudWatch monitoring outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = module.cloudwatch_monitoring.sns_topic_arn
}
