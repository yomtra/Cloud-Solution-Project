# S3 Module - Variables Configuration
# Define all input variables for the S3 module

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, start and end with alphanumeric characters, and can contain hyphens."
  }
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

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "kms_deletion_window" {
  description = "Number of days before KMS key is deleted (7-30 days)"
  type        = number
  default     = 10
  validation {
    condition     = var.kms_deletion_window >= 7 && var.kms_deletion_window <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "enable_bucket_policy" {
  description = "Enable custom bucket policy"
  type        = bool
  default     = true
}

variable "allowed_iam_roles" {
  description = "List of IAM role ARNs allowed to access the bucket"
  type        = list(string)
  default     = []
}

variable "root_user_arn" {
  description = "Account root user ARN"
  type = string
}
