# S3 Module - Outputs Configuration

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.main_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.main_bucket.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.main_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name"
  value       = aws_s3_bucket.main_bucket.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.main_bucket.hosted_zone_id
}

output "bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.main_bucket.region
}

output "kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = aws_kms_key.s3_encryption_key.key_id
}

output "kms_key_arn" {
  description = "The KMS key ARN used for encryption"
  value       = aws_kms_key.s3_encryption_key.arn
}

output "kms_key_alias" {
  description = "The KMS key alias"
  value       = aws_kms_alias.s3_encryption_key_alias.name
}
