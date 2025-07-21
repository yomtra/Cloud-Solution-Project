# S3 Module

This Terraform module creates an AWS S3 bucket with KMS encryption and configurable permissions.

## Features

- S3 Bucket: Creates a single S3 bucket with customizable name
- KMS Encryption: Bucket encrypted with customer-managed KMS key
- Versioning: Optional bucket versioning (enabled by default)
- Public Access Block: Blocks public access by default for security
- Bucket Policy: Configurable IAM-based access permissions
- Tagging: Consistent resource tagging

## Usage

### Basic Usage

```hcl
module "s3_bucket" {
  source = "./modules/s3"

  bucket_name  = "my-secure-bucket-12345"
  environment  = "prod"
  project_name = "cloud-solution-project"
}
```

### Advanced Usage with Custom Permissions

```hcl
module "s3_bucket" {
  source = "./modules/s3"

  bucket_name       = "my-application-bucket-67890"
  environment       = "prod"
  project_name      = "my-project"
  enable_versioning = true
  
  # KMS settings
  kms_deletion_window = 15
  
  # IAM permissions
  enable_bucket_policy = true
  allowed_iam_roles = [
    "arn:aws:iam::123456789012:role/MyApplicationRole",
    "arn:aws:iam::123456789012:role/BackupRole"
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| project_name | Name of the project for tagging purposes | `string` | `"cloud-solution-project"` | no |
| enable_versioning | Enable versioning for the S3 bucket | `bool` | `true` | no |
| kms_deletion_window | Number of days before KMS key is deleted (7-30 days) | `number` | `10` | no |
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket | `bool` | `true` | no |
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket | `bool` | `true` | no |
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket | `bool` | `true` | no |
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket | `bool` | `true` | no |
| enable_bucket_policy | Enable custom bucket policy | `bool` | `true` | no |
| allowed_iam_roles | List of IAM role ARNs allowed to access the bucket | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The ID of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The bucket regional domain name |
| bucket_hosted_zone_id | The Route 53 Hosted Zone ID for this bucket's region |
| bucket_region | The AWS region this bucket resides in |
| kms_key_id | The KMS key ID used for encryption |
| kms_key_arn | The KMS key ARN used for encryption |
| kms_key_alias | The KMS key alias |

## Security Features

- Encryption at Rest: All objects are encrypted using customer-managed KMS keys
- Public Access Blocked: All public access is blocked by default
- IAM-based Access: Access controlled through IAM roles and policies
- Versioning: Object versioning enabled for data protection

## Author

Created as part of the Cloud Solution Project group collaboration.
