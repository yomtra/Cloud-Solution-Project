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

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_read_replica_endpoint" {
  value = module.rds.rds_read_replica_endpoint
}

output "rds_username" {
  value = module.rds.rds_username
}

output "rds_port" {
  value = module.rds.rds_port
}

# S3 Module Outputs
output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.s3_storage.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_storage.bucket_arn
}

output "s3_kms_key_id" {
  description = "The KMS key ID used for S3 encryption"
  value       = module.s3_storage.kms_key_id
}

# ALB Module Outputs
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.application_load_balancer.alb_dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = module.application_load_balancer.alb_arn
}

output "web_tier_target_group_arn" {
  description = "The ARN of the web tier target group"
  value       = module.application_load_balancer.web_tier_target_group_arn
}

output "app_tier_target_group_arn" {
  description = "The ARN of the app tier target group"
  value       = module.application_load_balancer.app_tier_target_group_arn
}
