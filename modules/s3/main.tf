# S3 MODULE - SECURE STORAGE CONFIGURATION
# This module provides encrypted S3 storage for the GoGreen Insurance application
# Implements security best practices with KMS encryption and access controls
# Purpose: Stores application data, documents, and backups securely

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
# Purpose: Creates a customer-managed KMS key for S3 bucket encryption
# Security: Provides encryption at rest with customer-controlled key management
# Key Rotation: Automatically rotates encryption keys annually for enhanced security
# Deletion Protection: 10-day window prevents accidental key deletion
# Compliance: Meets regulatory requirements for data encryption
# Performance: Minimal impact on S3 read/write operations
# Cost: More expensive than default S3 encryption but provides greater control

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-encryption-key"
  target_key_id = aws_kms_key.s3_key.key_id
}
# Purpose: Creates a human-readable alias for the KMS encryption key
# Management: Easier to reference in policies and configurations
# Naming: Uses descriptive alias instead of complex key ID
# Integration: Simplifies key management across multiple AWS services
# Audit Trail: Easier to track key usage in CloudTrail logs
# Best Practice: Always use aliases for better operational management

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}
# Purpose: Creates the main S3 bucket for application data storage
# Naming: Uses variable for flexible bucket naming across environments
# Global Namespace: S3 bucket names must be globally unique across AWS
# Tagging: Applies consistent tags for cost allocation and management
# Availability: Multiple availability zone replication for high availability
# Use Cases: Application files, user uploads, backups, and static assets

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
# Purpose: Enforces encryption for all objects stored in the S3 bucket
# Algorithm: Uses AWS KMS (SSE-KMS) for server-side encryption
# Default Encryption: All new objects automatically encrypted
# Bucket Key: Reduces KMS API calls and costs for large numbers of objects
# Data Protection: Ensures data is encrypted at rest in S3
# Compliance: Required for handling sensitive insurance data
# Performance: Transparent encryption/decryption with minimal latency

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = length(var.allowed_principals) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSpecificPermissions"
        Effect    = "Allow"
        Principal = {
          AWS = var.allowed_principals
        }
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}
# Purpose: Defines fine-grained access control for the S3 bucket
# Conditional: Only creates policy if principals are specified
# Principle of Least Privilege: Only specified principals can access bucket
# Allowed Actions: Read (GetObject), Write (PutObject), Delete (DeleteObject)
# Principal Control: Restricts access to specific IAM users, roles, or accounts
# Resource Scope: Applies permissions to all objects within the bucket
# Security Layer: Additional protection beyond IAM policies
# Business Context: Ensures only authorized application components access data
# Audit Support: All access attempts logged in CloudTrail for compliance

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
# Purpose: Configures S3 bucket versioning based on variable setting
# Data Protection: Multiple versions of objects stored automatically
# Recovery: Enables restoration of deleted or modified objects
# Compliance: Required for regulatory frameworks like SOX, GDPR
# Cost Management: Lifecycle policies can manage old versions
# Business Value: Protects against human error and malicious changes

resource "aws_s3_bucket_public_access_block" "bucket_pab" {
  count  = var.enable_public_access_block ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Purpose: Implements comprehensive public access blocking for enhanced security
# Security: Prevents accidental public exposure of sensitive data
# Compliance: Required for handling insurance customer data
# Protection: Works even if bucket policies are misconfigured
# Best Practice: Always enable for buckets containing sensitive information