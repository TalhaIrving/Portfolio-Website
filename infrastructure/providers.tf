# Terraform provider configuration
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Default provider
provider "aws" {
  region = "eu-west-2"
}

# Provider for ACM certificates (CloudFront requires us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
