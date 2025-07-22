# versions.tf
# Jurabek: Added to properly define required providers and versions

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"  # Jurabek: Changed from ~> 5.0 to >= 5.0 to allow version 6.x
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
