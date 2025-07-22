# provider.tf
provider "aws" {
  region = var.aws_region  # Jurabek: Use variable instead of hardcoded region
}

# Random provider for generating unique identifiers
# Jurabek: Added for S3 bucket naming uniqueness
provider "random" {}
