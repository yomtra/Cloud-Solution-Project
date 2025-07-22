# S3 Module - Main Configuration
# This module creates an S3 bucket with KMS encryption and proper permissions

# Create KMS key for S3 encryption
resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = var.kms_deletion_window

  tags = {
    Name        = "${var.bucket_name}-encryption-key"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create KMS key alias for easier identification
resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/${var.bucket_name}-encryption-key"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

# Create S3 bucket
resource "aws_s3_bucket" "main_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# Configure S3 bucket versioning
resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  bucket = aws_s3_bucket.main_bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Configure S3 bucket encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "main_bucket_encryption" {
  bucket = aws_s3_bucket.main_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "main_bucket_pab" {
  bucket = aws_s3_bucket.main_bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# S3 bucket policy for additional permissions
resource "aws_s3_bucket_policy" "main_bucket_policy" {
  count  = var.enable_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.main_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowRootUserFullAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.root_user_arn
        }
        Action   = "s3:*"
        Resource = [
          aws_s3_bucket.main_bucket.arn,
          "${aws_s3_bucket.main_bucket.arn}/*"
        ]
      },
      {
        Sid    = "AllowSpecificIAMRoleAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_iam_roles
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main_bucket.arn,
          "${aws_s3_bucket.main_bucket.arn}/*"
        ]
      }
    ]
  })
}
