
# S3 MODULE OUTPUTS
# This file exposes important S3 resource identifiers for use by other modules
# Outputs enable integration with other AWS services and modules

output "bucket_id" {
  value       = aws_s3_bucket.bucket.id
  description = "ID of the S3 bucket"
}
# Purpose: Provides the bucket identifier for configuration and integration
# Usage: Required by other services that need to reference this bucket
# Integration: Used in IAM policies, CloudFront distributions, and backup jobs
# Value: Same as bucket name but obtained from the actual created resource
# Applications: Lambda functions, EC2 user data, application configuration files

output "bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "ARN of the S3 bucket"
}
# Purpose: Provides the full Amazon Resource Name for the S3 bucket
# Format: "arn:aws:s3:::bucket-name"
# Usage: Required for IAM policies, resource-based policies, and cross-service integration
# Security: Used in bucket policies and IAM role trust relationships
# Monitoring: CloudWatch metrics and alarms reference this ARN
# Cross-Account: Enables secure cross-account bucket access policies
# Automation: Used in infrastructure automation and deployment scripts

output "kms_key_arn" {
  value       = aws_kms_key.s3_key.arn
  description = "ARN of the KMS key used for encryption"
}
# Purpose: Exposes the KMS key ARN for encryption operations and policies
# Format: "arn:aws:kms:region:account:key/key-id"
# Usage: Required for applications that need to encrypt/decrypt S3 objects
# Integration: Used by Lambda functions, EC2 instances for data processing
# Security: Required in IAM policies for services needing encryption access
# Cross-Service: Other services (RDS, EBS) can use the same key for consistency
# Compliance: Auditors need key ARN to verify encryption implementation
# Key Management: Enables centralized encryption key governance and rotation